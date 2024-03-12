library(shiny)
library(DT)
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
  constructAuthorQuery <- function(publisher, pageRange) {
    queryParts <- list()
    
    if (publisher != "") {
      queryParts <- c(queryParts, sprintf("penerbit.nama_penerbit = '%s'", publisher))
    }
    
    if (!is.null(pageRange)) {
      # Lakukan casting tipe data jumlah_halaman ke integer sebelum membandingkannya
      queryParts <- c(queryParts, sprintf("CAST(buku.jumlah_halaman AS INTEGER) BETWEEN %d AND %d", pageRange[1], pageRange[2]))
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
  
  # Reaksi terhadap tombol cari
  observeEvent(input$searchAuthorsButton, {
    query <- constructAuthorQuery(input$publisherInputAuthors, input$pageRange)
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
    WHERE tahun_terbit <> 'Tanggal terbit tidak tersedia' -- memastikan bahwa hanya entri dengan tahun yang valid yang dipertimbangkan
    ORDER BY CAST(SPLIT_PART(tahun_terbit, '/', 3) AS INTEGER) DESC -- mengambil bagian tahun dan mengubahnya menjadi integer untuk sorting
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
    ggplot(data, aes(x = judul_buku, y = jumlah_halaman)) +
      geom_point() +  # Membuat grafik titik-titik
      geom_hline(aes(yintercept = mean(jumlah_halaman, na.rm = TRUE)), 
                 color = "blue", linetype = "dashed", size = 1) +  # Garis rata-rata
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) + # Putar teks sumbu x
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
}