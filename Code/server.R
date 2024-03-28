library(shiny)
library(shinydashboard)
library(DT)
library(RPostgreSQL)
library(DBI)
library(shiny)
library(RPostgreSQL) 
library(DT)
library(rsconnect)
library(shinydashboard)
library(dygraphs)
library(fmsb)
library(modules)
library(rworldmap)
library(shiny.fluent)
library(shiny.router)
library(shinythemes)
library(echarts4r.maps)

library(ggplot2)
library(bs4Dash)
library(googlesheets4)
library(tidyverse)
library(highcharter)
library(waiter)
library(DT)
library(tidytext)
library(ggwordcloud)
library(jsonlite)
library(hackeRnews)
library(urltools)
library(shiny)
library(wordcloud)
library(tm)
library(dplyr)
library(shinyWidgets)
library(stopwords)
library(RColorBrewer)


# Server logic
server <- function(input, output, session) {
  # Render data tables
  output$top_books <- renderUI({
    books_data <- data.frame(
      title = c("Buku Ajar Statistik Deskriptif", "Kesehatan Perkotaan di Indonesia", "Filsafat Etika"),
      author = c("Asnidar.", "Charles Surjadi", "Ahmad Mahmud"),
      rating = c(4.5, 4.6, 4.6),
      image = c(
        "https://books.google.com/books/publisher/content/images/frontcover/jHUqEAAAQBAJ?fife=w240-h345", 
        "https://books.google.com/books/publisher/content/images/frontcover/EWGwDwAAQBAJ?fife=w240-h345", 
        "https://books.google.com/books/publisher/content/images/frontcover/7TlpCgAAQBAJ?fife=w240-h345"
      )
    )
    
    book_panels <- lapply(1:nrow(books_data), function(i) {
      # Jumlah bintang penuh berdasarkan pembulatan ke bawah dari rating
      bintang_penuh <- floor(books_data$rating[i])
      # Menentukan apakah ada setengah bintang
      setengah_bintang <- ifelse((books_data$rating[i]*2) %% 2 != 0, 1, 0)
      # Menghitung jumlah bintang kosong
      bintang_kosong <- 5 - bintang_penuh - setengah_bintang
      
      # Membangun HTML untuk bintang-bintang
      stars_html <- paste0(
        strrep('<i class="fa fa-star"></i>', bintang_penuh),
        ifelse(setengah_bintang > 0, '<i class="fa fa-star-half-o"></i>', ''),
        strrep('<i class="fa fa-star-o"></i>', bintang_kosong),
        collapse = ""
      )
      
      column(4, class = "top-book-panel",
             tags$img(src = books_data$image[i], height = "150px"),
             tags$p(strong(books_data$title[i]), 
                    tags$br(), 
                    "by ", books_data$author[i]),
             tags$div(class = "rating", 
                      HTML(stars_html)
             )
      )
    })
    
    do.call(fluidRow, book_panels)
  })
  
  # Awalnya, kita perlu memuat pilihan awal untuk semua input
  observe({
    # Perlu query untuk mengambil semua nama penulis, penerbit, dan kategori
    penulis_data <- readData("SELECT DISTINCT nama_penulis FROM penulis ORDER BY nama_penulis")
    penerbit_data <- readData("SELECT DISTINCT nama_penerbit FROM penerbit ORDER BY nama_penerbit")
    kategori_data <- readData("SELECT DISTINCT nama_kategori FROM kategori ORDER BY nama_kategori")
    
    updateSelectInput(session, "authorInput", choices = c("", penulis_data$nama_penulis))
    updateSelectInput(session, "publisherInput", choices = c("", penerbit_data$nama_penerbit))
    updateSelectInput(session, "categoryInput", choices = c("", kategori_data$nama_kategori))
  })
  
  # Ketika nama penulis dipilih, perbarui pilihan penerbit dan kategori
  observeEvent(input$authorInput, {
    if (input$authorInput != "") {
      query <- sprintf(
        "SELECT DISTINCT penerbit.nama_penerbit, kategori.nama_kategori 
       FROM buku 
       JOIN penulis ON buku.id_penulis = penulis.id_penulis
       JOIN penerbit ON buku.id_penerbit = penerbit.id_penerbit
       JOIN kategori ON buku.id_kategori = kategori.id_kategori
       WHERE penulis.nama_penulis = '%s'", input$authorInput
      )
      related_data <- readData(query)
      
      # Cek apakah pilihan penerbit sebelumnya masih relevan
      if (!input$publisherInput %in% related_data$nama_penerbit) {
        updateSelectInput(session, "publisherInput", selected = NULL)
      }
      
      # Cek apakah pilihan kategori sebelumnya masih relevan
      if (!input$categoryInput %in% related_data$nama_kategori) {
        updateSelectInput(session, "categoryInput", selected = NULL)
      }
    } else {
      # Jika penulis dikosongkan, reset pilihan penerbit dan kategori
      updateSelectInput(session, "publisherInput", selected = NULL)
      updateSelectInput(session, "categoryInput", selected = NULL)
    }
  })
  
  
  # Fungsi untuk membangun query SQL berdasarkan input filter
  constructQuery <- function(author, publisher, category) {
    queryParts <- list()
    
    if (author != "") {
      queryParts <- c(queryParts, sprintf("penulis.nama_penulis ILIKE '%%%s%%'", author))
    }
    if (publisher != "") {
      queryParts <- c(queryParts, sprintf("penerbit.nama_penerbit ILIKE '%%%s%%'", publisher))
    }
    if (category != "") {
      queryParts <- c(queryParts, sprintf("kategori.nama_kategori ILIKE '%%%s%%'", category))
    }
    
    # Jika tidak ada filter, gunakan query default untuk memilih semua data
    if (length(queryParts) == 0) {
      return("SELECT judul_buku, ISBN, tahun_terbit, link_buku, deskripsi FROM buku")
    } else {
      whereClause <- paste("WHERE", paste(queryParts, collapse = " OR "))
      return(paste(
        "SELECT buku.judul_buku, buku.ISBN, buku.tahun_terbit, buku.link_buku, buku.deskripsi FROM buku
         JOIN penulis ON buku.id_penulis = penulis.id_penulis
         JOIN penerbit ON buku.id_penerbit = penerbit.id_penerbit
         JOIN kategori ON buku.id_kategori = kategori.id_kategori",
        whereClause
      ))
    }
  }
  
  # Awalnya memuat semua buku
  output$searchResultsTable <- renderDT({
    datatable(readData(constructQuery("", "", "")), options = list(
      lengthChange = TRUE, 
      pageLength = 10, 
      lengthMenu = list(c(10, 25, 50, 100), c('10', '25', '50', '100')), 
      searching = TRUE, 
      info = TRUE,
      autoWidth = TRUE,
      columnDefs = list(
        list(
          targets = 4, # Angka ini mengacu pada kolom link_buku yang mana harus disesuaikan dengan posisi kolom link_buku dalam data Anda
          render = JS(
            "function(data, type, row, meta) {
              if(type === 'display' && data != null && data != '') {
                return '<a href=\"' + data + '\" target=\"_blank\">' + data + '</a>';
              } else {
                return data;
              }
            }"
          )
        )
      )
    ), escape = FALSE # Memastikan bahwa HTML pada link tidak di-escape
    )
  }, server = FALSE) # Menonaktifkan processing server-side untuk fitur DT
  
  # Membangun dan menjalankan query baru ketika tombol "Cari" diklik
  observeEvent(input$searchButton, {
    withProgress(message = 'Mohon tunggu...', value = 0, {
      # Setel ulang indikator pemuatan ke nilai 0
      setProgress(value = 0, message = "Sedang memuat data...")
      
      query <- constructQuery(input$authorInput, input$publisherInput, input$categoryInput)
      output$searchResultsTable <- renderDT({
        datatable(readData(query), options = list(
          lengthChange = TRUE, 
          pageLength = 10, 
          lengthMenu = list(c(10, 25, 50, 100), c('10', '25', '50', '100')), 
          searching = TRUE, 
          info = TRUE,
          autoWidth = TRUE,
          columnDefs = list(
            list(
              targets = 4, # Sesuaikan indeks ini jika struktur tabel Anda berubah
              render = JS(
                "function(data, type, row, meta) {
                if(type === 'display' && data != null && data != '') {
                  return '<a href=\"' + data + '\" target=\"_blank\">' + data + '</a>';
                } else {
                  return data;
                }
              }"
              )
            )
          )
        ), escape = FALSE
        )
      }, server = FALSE) # Menonaktifkan processing server-side
      # Selesaikan indikator pemuatan
      setProgress(value = 1)
    })
  })
  
  #Fngsi menu cari penulis
  # Fungsi untuk membangun query berdasarkan input dari pengguna
  constructAuthorQuery <- function(publisher, pageRange, selectedBook) {
    queryParts <- list()
    
    if (publisher != "") {
      queryParts <- c(queryParts, sprintf("penerbit.nama_penerbit = '%s'", publisher))
    }
    
    if (!is.null(pageRange)) {
      queryParts <- c(queryParts, sprintf("CAST(buku.jumlah_halaman AS INTEGER) BETWEEN %d AND %d", pageRange[1], pageRange[2]))
    }
    
    if (selectedBook != "") {
      queryParts <- c(queryParts, sprintf("buku.judul_buku = '%s'", selectedBook))
    }
    
    whereClause <- paste(queryParts, collapse = " AND ")
    if (whereClause != "") {
      whereClause <- paste("WHERE", whereClause)
    }
    
    query <- paste(
      "SELECT buku.judul_buku, penulis.nama_penulis, buku.tahun_terbit, buku.link_buku, buku.deskripsi",
      "FROM buku",
      "JOIN penulis ON buku.id_penulis = penulis.id_penulis",
      "JOIN penerbit ON buku.id_penerbit = penerbit.id_penerbit",
      whereClause
    )
    
    return(query)
  }
  
  # Update observeEvent untuk tombol cari
  observeEvent(input$searchAuthorsButton, {
    query <- constructAuthorQuery(input$publisherInputAuthors, input$pageRange, input$bookInput) # Tambahkan parameter baru input$bookInput
    data <- readData(query)
    
    output$authorSearchResults <- DT::renderDT({
      DT::datatable(data, options = list(
        pageLength = 25,
        autoWidth = TRUE,
        columnDefs = list(
          list(
            targets = 4, # Kolom link_buku adalah kolom kelima, sehingga indeksnya adalah 4
            render = JS(
              "function(data, type, full, meta) {
              if(type === 'display' && data != null && data != '') {
                data = '<a href=\"' + data + '\" target=\"_blank\">' + data + '</a>';
              }
              return data;
            }"
            )
          )
        )
      ), escape = FALSE) # Escape FALSE agar bisa render HTML
    })
  })
  
  # Query untuk mendapatkan 10 buku terbaru berdasarkan tahun terbit
  output$out_tbl3 <- renderTable({
    query <- "
  SELECT judul_buku, tahun_terbit
  FROM buku
  WHERE tahun_terbit <> 'Tanggal terbit tidak tersedia'
    AND tahun_terbit ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' -- menambahkan regex untuk memastikan format tanggal adalah dd/mm/yyyy
  ORDER BY CAST(SPLIT_PART(tahun_terbit, '/', 3) AS INTEGER) DESC
  LIMIT 10
  "
    readData(query)
  })
  
  
  # Query untuk mendapatkan 10 buku dengan jumlah halaman terbanyak
  output$out_tbl4 <- renderTable({
    query <- "
    SELECT judul_buku, CAST(jumlah_halaman AS INTEGER)
    FROM buku
    ORDER BY CAST(jumlah_halaman AS INTEGER) DESC
    LIMIT 10
    "
    readData(query)
  })
  
  # Query untuk mendapatkan data jumlah halaman buku
  dfHalaman <- reactive({
    query <- "
      SELECT judul_buku, CAST(jumlah_halaman AS INTEGER) AS jumlah_halaman
      FROM buku
    "
    readData(query)
  })
  
  # Plot untuk distribusi jumlah halaman buku
  output$plotHalaman <- renderPlot({
    data <- dfHalaman()
    
    # Potong judul buku jika terlalu panjang
    data$judul_buku <- sapply(data$judul_buku, function(x) substr(x, 1, 30))
    
    # Hitung rata-rata jumlah halaman tanpa NA
    avg_halaman <- mean(data$jumlah_halaman, na.rm = TRUE)
    
    ggplot(data, aes(x = judul_buku, y = jumlah_halaman)) +
      geom_point() +  # Membuat grafik titik-titik
      geom_hline(yintercept = avg_halaman, color = "blue", linetype = "dashed", size = 1) +  # Garis rata-rata
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) + # Putar teks sumbu x
      labs(x = "Judul Buku", y = "Jumlah Halaman", 
           title = "Distribusi Jumlah Halaman Buku") +
      theme(plot.title = element_text(hjust = 0.5)) # Pusatkan judul plot
  })
  
  
  # Query untuk mendapatkan jumlah buku yang diterbitkan oleh setiap penerbit
  dfPenerbit <- reactive({
    query <- "
      SELECT p.nama_penerbit, COUNT(b.id_buku) as jumlah_buku
      FROM penerbit p
      JOIN buku b ON p.id_penerbit = b.id_penerbit
      GROUP BY p.nama_penerbit
      ORDER BY jumlah_buku DESC
    "
    readData(query)
  })
  
  # Word cloud untuk penerbit
  output$wordcloudPenerbit <- renderPlot({
    data <- dfPenerbit()
    
    # Membuat word cloud
    if(nrow(data) > 0){
      # Menggunakan term frequency dari nama_penerbit sebagai bobot
      wordcloud(words = data$nama_penerbit, freq = data$jumlah_buku, min.freq = 1,
                max.words = 100, random.order = FALSE, rot.per = 0.35, 
                colors = brewer.pal(8, "Dark2"))
    }
  })
  
  # Query untuk distribusi buku per kategori
  output$distribusiBukuPerKategori <- renderPlot({
    query <- "
    SELECT k.nama_kategori, COUNT(*) AS jumlah_buku
    FROM buku b
    JOIN kategori k ON b.id_kategori = k.id_kategori
    GROUP BY k.nama_kategori
    ORDER BY jumlah_buku DESC
  "
    data <- readData(query)
    
    ggplot(data, aes(x = reorder(nama_kategori, jumlah_buku), y = jumlah_buku)) +
      geom_bar(stat = "identity", fill = 'steelblue') +
      coord_flip() +
      labs(x = "Jumlah Buku", y = "Kategori", title = "Distribusi Buku per Kategori") +
      theme_minimal()
  })
  
  # Query untuk tren penerbitan buku per tahun
  output$trenPenerbitanBuku <- renderPlot({
    query <- "
    SELECT EXTRACT(YEAR FROM TO_DATE(tahun_terbit, 'MM/DD/YYYY')) AS tahun, COUNT(*) AS jumlah_buku
    FROM buku
    WHERE tahun_terbit ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
    GROUP BY tahun
    ORDER BY tahun
  "
    data <- readData(query)
    
    ggplot(data, aes(x = tahun, y = jumlah_buku)) +
      geom_line() +
      geom_point(size = 3, color = 'blue') +
      labs(x = "Tahun", y = "Jumlah Buku", title = "Tren Penerbitan Buku") +
      theme_minimal()
  })
  
  # Rata-rata Halaman Buku per Kategori
  output$avgPagesPerCategory <- renderTable({
    query <- "
    SELECT k.nama_kategori, AVG(CAST(b.jumlah_halaman AS INTEGER)) AS avg_pages
    FROM buku b
    JOIN kategori k ON b.id_kategori = k.id_kategori
    GROUP BY k.nama_kategori
    ORDER BY avg_pages DESC
  "
    readData(query)
  })
  
  # Grafik Interaktif untuk Eksplorasi Data
  output$interactivePlot <- renderPlotly({
    # Anda dapat memodifikasi query ini untuk mengambil data yang diinginkan
    query <- "
    SELECT k.nama_kategori, COUNT(*) AS jumlah_buku, AVG(CAST(b.jumlah_halaman AS INTEGER)) AS avg_pages
    FROM buku b
    JOIN kategori k ON b.id_kategori = k.id_kategori
    GROUP BY k.nama_kategori
    ORDER BY jumlah_buku DESC
  "
    data <- readData(query)
    
    plot_ly(data, x = ~nama_kategori, y = ~jumlah_buku, type = 'bar', name = 'Jumlah Buku') %>%
      add_trace(y = ~avg_pages, name = 'Rata-rata Halaman', mode = 'lines+markers') %>%
      layout(yaxis2 = list(overlaying = "y", side = "right"))
  })
}