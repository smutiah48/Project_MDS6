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

# Konfigurasi koneksi ke database
db <- dbConnect(RPostgres::Postgres(), dbname = 'kelompok6', host = 'localhost', 
                port = 5433, user = 'postgres', password = 'Rahman0140')

# Function to read data from the database
readData <- function(query) {
  dbGetQuery(db, query)
}

# Function to get choices from the database with a placeholder for the empty option
getChoices <- function(query) {
  res <- readData(query)
  return(c("", res[[1]]))
}

# UI
ui <- dashboardPage(
  dashboardHeader(
    title = span(
      img(src = "https://github.com/smutiah48/Project_MDS6/blob/main/scr/logo.jpeg?raw=true",
          style = "height:45px; width:auto; vertical-align:middle; padding-right: 15px;"),
      "Electronic Literatur", 
      style = "color: black; vertical-align:middle; font-size: 15px; padding-left: 5px; font-weight: bold;"
    )
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Beranda", tabName = "home", icon = icon("home")),
      menuItem("Cari Buku", tabName = "searchBooks", icon = icon("search")),
      menuItem("Cari Penulis", tabName = "searchAuthors", icon = icon("feather")),
      menuItem("Detail Buku", tabName = "bookDetails", icon = icon("book")),
      menuItem("Statistik", tabName = "statistik", icon = icon("chart-bar")),
      menuItem("Tim Kami", tabName = "team", icon = icon("users"))
    )
  ),
  dashboardBody(
    tags$head(
      tags$link(href="https://fonts.googleapis.com/css?family=Roboto:400,700&display=swap", rel="stylesheet"),
      tags$style(HTML("
      .content-wrapper, .right-side, .main-footer, .main-header .logo, .main-header .navbar, .sidebar-menu > li.active > a {
        background-color: #00477f; 
      }
      .box {
        border-top-color: #00477f; 
      }
      h1, h2, h3, h4, h5, h6, .h1, .h2, .h3, .h4, .h5, .h6 {
        font-family: 'Roboto', sans-serif; 
      }
      h1 {
        font-size: 36px; 
        font-weight: 700; 
      }
      .welcome-box {
        background-color: #FFD700; 
        color: #000000; 
        display: flex; 
        align-items: center; 
        justify-content: start; 
        padding: 40px; 
        margin-bottom: 20px;
        min-height: 200px;
      }
      .welcome-box h1 {
        font-size: 48px; 
        margin: 0; 
      }
      .welcome-box img {
        height: auto; 
        width: auto; 
        max-height: 150px;
        max-width: 150px; 
        margin-right: 20px; 
      }
      .welcome-box h1, .welcome-box p {
        margin-left: 20px;
      }
      .welcome-box p {
        font-size: 20px; 
        margin: 0; 
      }
      @media (max-width: 991px) {
        .welcome-box {
          flex-direction: column; 
          text-align: center; 
        }
        .welcome-box img {
          margin-bottom: 20px; 
        }
      }
      
      .dataTables_wrapper {
        background-color: #f8f9fa; 
        border-radius: 4px;
        padding: 10px;
      }

      .dataTables_wrapper .dataTables_processing {
        z-index: 1;
      }

      table.dataTable {
        border-collapse: separate;
        margin: 0 0 20px;
        background-color: #FFFFFF; 
        color: #212529; 
        border-radius: 4px;
        box-shadow: 0 2px 3px rgba(0,0,0,0.1); 
      }

      table.dataTable thead {
        background-color: #00477f; 
        color: #FFFFFF; 
      }

      table.dataTable thead th {
        background-color: #007bff;
        color: white;
      }

      table.dataTable tbody tr {
        background-color: white; 
      }

      .input-group .form-control {
        border: 1px solid #ced4da; 
        color: #495057;
      }
      
      .input-group-btn .btn {
        background-color: #007bff; 
        color: white;
      }
      
      table.dataTable tbody tr:nth-child(odd) {
        background-color: #F9F9F9; 
      }
      .dataTables_paginate .pagination li a {
        color: #007bff; 
      }

      @media (max-width: 767px) {
        .dataTables_wrapper .dataTables_paginate {
          float: none;
          text-align: center;
        }
      }
    "))
    ),
    tabItems(
      tabItem(tabName = "home", 
              fluidRow(
                box(
                  width = 12,
                  div(class = "welcome-box",
                      img(src = "https://img.pikbest.com/origin/10/09/61/33IpIkbEsTUXg.png!sw800", height = "100px"),
                      div(
                        h2("Selamat Datang Di Dashboard Electronic Literatur!", style = "margin: 0;"), 
                        p("Kelompok 6", style = "margin: 0;") 
                      )
                  )
                )
              ),
              fluidRow(
                box(
                  title = "Buku Rating Tertinggi", status = "primary", solidHeader = TRUE, 
                  collapsible = TRUE, width = 12,
                  div(
                    class = "container-fluid",
                    # Use a loop to render books
                    uiOutput("top_books")
                  )
                )
              ),
              fluidRow(
                box(
                  title = "Tentang Electronic Literatur", status = "warning", solidHeader = TRUE, 
                  collapsible = TRUE, width = 6,
                  "Elit menyediakan database komprehensif untuk memudahkan para pembaca dan cendekiawan menemukan buku yang dibutuhkan hanya dengan ujung jari Anda."
                ),
                box(
                  title = "Manfaat dari Membaca", status = "info", solidHeader = TRUE, 
                  collapsible = TRUE, width = 6,
                  "Membaca dapat meningkatkan pengetahuan, meningkatkan konsentrasi, dan memupuk imajinasi. Selami dunia buku dan biarkan pikiran Anda menjelajahi batas-batas realitas."
                )
              ),
              fluidRow(
                box(
                  title = "Cara Penggunaan", status = "success", solidHeader = TRUE, 
                  collapsible = TRUE, width = 12,
                  "Cukup masukkan judul, penulis, atau kata kunci ke dalam kolom pencarian untuk memulai pencarian Anda melalui koleksi literatur kami yang luas."
                )
              ),
              fluidRow(
                box(
                  title = "Ulasan Pengguna", status = "danger", solidHeader = TRUE, 
                  collapsible = TRUE, width = 12,
                  tags$ul(
                    tags$li(
                      tags$div(
                        "“membantu saya menemukan buku untuk penelitian saya!” - Meisya",
                        tags$div(class = "star-rating",
                                 icon("star"), icon("star"), icon("star"), icon("star"), icon("star")
                        )
                      )
                    ),
                    tags$li(
                      tags$div(
                        "“Penyelamat untuk pencarian dan referensi buku dengan cepat.” - Riska",
                        tags$div(class = "star-rating",
                                 icon("star"), icon("star"), icon("star"), icon("star"), icon("star")
                                 
                        )
                      )
                    )
                  )
                )
              )
      ),
      tabItem(tabName = "searchBooks",
              fluidRow(
                box(title = "Filter Pencarian", status = "primary", solidHeader = TRUE, collapsible = TRUE, width = 12,
                    selectInput("authorInput", "Masukkan Nama Penulis", choices = getChoices("SELECT DISTINCT nama_penulis FROM penulis ORDER BY nama_penulis")),
                    selectInput("publisherInput", "Masukkan Nama Penerbit", choices = getChoices("SELECT DISTINCT nama_penerbit FROM penerbit ORDER BY nama_penerbit")),
                    selectInput("categoryInput", "Masukkan Kategori", choices = getChoices("SELECT DISTINCT nama_kategori FROM kategori ORDER BY nama_kategori")),
                    actionButton("searchButton", "Cari", icon = icon("search"))
                )
              ),
              fluidRow(
                box(title = "Hasil Pencarian", status = "primary", solidHeader = TRUE, width = 12, 
                    DTOutput("searchResultsTable")
                )
              )
      ),
      tabItem(tabName = "searchAuthors",
              fluidRow(
                box(title = "Cari Penulis", status = "primary", solidHeader = TRUE, collapsible = TRUE, width = 12,
                    selectInput("publisherInputAuthors", "Pilih Penerbit", choices = getChoices("SELECT DISTINCT nama_penerbit FROM penerbit ORDER BY nama_penerbit")),
                    numericRangeInput("pageRange", "Pilih Jangkauan Halaman", min = 0, max = 1000, value = c(50, 200)),
                    actionButton("searchAuthorsButton", "Cari", icon = icon("search")),
                    DTOutput("authorSearchResults")
                )
              )
      ),
      tabItem(tabName = "bookDetails",
              tabItem(
                tabName = "daftar_buku",
                fluidRow(
                  tags$h1("jangan hanya dilihat, silahkan klik untuk membaca", style = "text-align: center; font-weight: bold;color: white;")
                ),
                fluidRow(
                  style = "display: flex; justify-content: center; align-items: center;",
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/content/images/frontcover/KElYAPJMy88C?fife=w240-h345", height = 150, width = 100),
                         h6("BISNIS Bulletin: Volume 61", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=KElYAPJMy88C&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/content/images/frontcover/uAVGOPm1MkgC?fife=w240-h345", height = 150, width = 100),
                         h6("BISNIS Bulletin", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=uAVGOPm1MkgC&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/content/images/frontcover/QVqoSDzIAbkC?fife=w240-h345", height = 150, width = 100),
                         h6("BISNIS Search for Partners", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=QVqoSDzIAbkC&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/publisher/content/images/frontcover/UH3zEAAAQBAJ?fife=w240-h345", height = 150, width = 100),
                         h6("MODEL BISNIS KEWIRAUSAHAAN", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=UH3zEAAAQBAJ&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.co.id/googlebooks/images/no_cover_thumb.gif", height = 150, width = 100),
                         h6("BISNIS bulletin", style = "text-align: center;color: white;"),
                         tags$a(href = "http://books.google.com/books?id=qCwhzwEACAAJ&dq=Bisnis&hl=&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/publisher/content/images/frontcover/91HAEAAAQBAJ?fife=w240-h345", height = 150, width = 100),
                         h6("Great Family Business", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=91HAEAAAQBAJ&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  )
                ),
                tags$br(),
                fluidRow(
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/publisher/content/images/frontcover/RNlMDwAAQBAJ?fife=w240-h345", height = 150, width = 100),
                         h6("Meretas Sejuta Saudagar: How to Turn a Great Idea into a Reality", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=RNlMDwAAQBAJ&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/publisher/content/images/frontcover/DRpbDwAAQBAJ?fife=w240-h345", height = 150, width = 100),
                         h6("Corporate Culture - Challenge to Excellence", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=DRpbDwAAQBAJ&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.co.id/googlebooks/images/no_cover_thumb.gif", height = 150, width = 100),
                         h6("Bai bisnis i helpim yumi olsem wanem?", style = "text-align: center;color: white;"),
                         tags$a(href = "http://books.google.com/books?id=HjtkHQAACAAJ&dq=Bisnis&hl=&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.co.id/books/content?id=QRUoAAAAMAAJ&printsec=frontcover&img=1&zoom=1&imgtk=AFLRE70AO_zdBj2j1gM-7uOFFt88a_lD35s3ewTb7TNuHY_N_Vv_nyYbxDcGWBHtcCNQTxRyAq4BRfP3X_ToJcqUHPOt_LtDZXthgFJoDfIr7aXZYOmVchp1jF1DBHyW5Wu1b3-D3HCO", height = 150, width = 100),
                         h6("Andalan dalam bisnis Indonesia-Jerman", style = "text-align: center;color: white;"),
                         tags$a(href = "http://books.google.com/books?id=QRUoAAAAMAAJ&dq=Bisnis&hl=&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/publisher/content/images/frontcover/IMzJEAAAQBAJ?fife=w240-h345", height = 150, width = 100),
                         h6("BUSINESS ENGLISH 1 Bahasa Inggris Bisnis I", style = "text-align: center;color: white;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=IMzJEAAAQBAJ&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/publisher/content/images/frontcover/6WGhDwAAQBAJ?fife=w240-h345", height = 150, width = 100),
                         h6("Think and Grow Rich", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=6WGhDwAAQBAJ&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  )
                ),
                tags$br(),
                fluidRow(
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/content/images/frontcover/iahJAAAAIAAJ?fife=w240-h345", height = 150, width = 100),
                         h6("The Young Man Entering Business", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=iahJAAAAIAAJ&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/content/images/frontcover/1iYZAAAAYAAJ?fife=w240-h345", height = 150, width = 100),
                         h6("Store Management--complete", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=1iYZAAAAYAAJ&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.co.id/books/content?id=5HV44_tnmc8C&printsec=frontcover&img=1&zoom=1&imgtk=AFLRE73XteukYAOwVGLaqzbpcDbvAYNOcegSXOHeA9xJFCj8xDaIIiUyNxnjNg1CpJlq7gutyd3wTE1yjxO8VVclFsmYAg0k3fQB7z3cszOwTrkQLs2u7_dw2KvyMAfG2khuhk0-Jtk5", height = 150, width = 100),
                         h6("How to Start a Bankruptcy Forms Processing Service", style = "text-align: center;color: white;"),
                         tags$a(href = "http://books.google.com/books?id=5HV44_tnmc8C&dq=Bisnis&hl=&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/publisher/content/images/frontcover/P4b4DwAAQBAJ?fife=w240-h345", height = 150, width = 100),
                         h6("Business Organizations Law in Focus: Edition 2", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=P4b4DwAAQBAJ&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/publisher/content/images/frontcover/QZ5GEAAAQBAJ?fife=w240-h345", height = 150, width = 100),
                         h6("SELLING is EVERYBODY BUSINESS: A Total Solution Approach", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=QZ5GEAAAQBAJ&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.co.id/books/publisher/content?id=ELt0AgAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&imgtk=AFLRE73czCTGfq53oPBlbl-96cEd3VtOZgvRhDrpsOmLeTcyQNX5wzsppv6qvn68WhLDCcXxBT9WMIaTJdom5rzV8k57am9ZIjZx67Yb64xsITI8XFNXaFNokil1eFX9G9bqll-dDzCU", height = 150, width = 100),
                         h6("Mobile Hot Dog Cart Company", style = "text-align: center;color: white;"),
                         tags$a(href = "http://books.google.com/books?id=ELt0AgAAQBAJ&dq=Bisnis&hl=&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  )
                ),
                tags$br(),
                fluidRow(
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.co.id/books/content?id=9EETAQAAIAAJ&printsec=frontcover&img=1&zoom=1&imgtk=AFLRE729mqa9H3l1puJ-LoGKZqvcSvK92iv337U0w-2tL81cAX-kK0oxlBG-BxZz9tFGkguHXth_N-1xNkxsbfFNTODZXkoUje1JIU2UxHvaUdMgsey5hs1y8TblhA6puUL1S-yRn9wg", height = 150, width = 100),
                         h6("Journal, Volume 5-6", style = "text-align: center;color: white;"),
                         tags$a(href = "http://books.google.com/books?id=9EETAQAAIAAJ&dq=Bisnis&hl=&source=gbs_api ", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/publisher/content/images/frontcover/10uHDwAAQBAJ?fife=w240-h345", height = 150, width = 100),
                         h6("Information Technology Business Start-up; Kedua; & Ketiga", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=10uHDwAAQBAJ&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.co.id/books/content?id=5m8RAQAAMAAJ&printsec=frontcover&img=1&zoom=1&imgtk=AFLRE72ikTJzM8V5DcH8WiD7GqMut4OxnRZjnWAHrg4DD7YGI1wrEQNGCZoBHcxNqU6ljnduzSiz4Uyq008BIgmPNVAom6bwoIyRm3jqFUyQW_Fel8fNf_hbP4JFQ2uHD8HVBwLgAbNs", height = 150, width = 100),
                         h6("The Journal of the Papua and New Guinea Society", style = "text-align: center;color: white;"),
                         tags$a(href = "http://books.google.com/books?id=5m8RAQAAMAAJ&dq=Bisnis&hl=&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/content/images/frontcover/uRsMAAAAYAAJ?fife=w240-h345", height = 150, width = 100),
                         h6("As You Were, Bill!", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=uRsMAAAAYAAJ&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/content/images/frontcover/E6w5Sp6zsLEC?fife=w240-h345", height = 150, width = 100),
                         h6("Testosterone Inc: Tales of CEOs Gone Wild", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=E6w5Sp6zsLEC&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.co.id/books/content?id=KuEJAQAAMAAJ&printsec=frontcover&img=1&zoom=1&imgtk=AFLRE73htnc4UTDeABPTyIRfTMZsgsB6FAPm1YAlBt6RxKR-Jdzbb32O8cyNCasLe69-qTcJgRxrSA0NNGTKjx61Tibo2uqZ-kbJpU5CMt4GxHyp_2wXTav33Xjpvt5iOKibM0vbINCD", height = 150, width = 100),
                         h6("Doing Business in Russia", style = "text-align: center;color: white;"),
                         tags$a(href = "http://books.google.com/books?id=KuEJAQAAMAAJ&dq=Bisnis&hl=&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  )
                ),
                tags$br(),
                fluidRow(
                  
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/publisher/content/images/frontcover/xVmeEAAAQBAJ?fife=w240-h345", height = 150, width = 100),
                         h6("Hook Point", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=xVmeEAAAQBAJ&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.co.id/books/content?id=hswqAAAAMAAJ&printsec=frontcover&img=1&zoom=1&imgtk=AFLRE71UEUsLXF-rVWvjtc_-T9WDX1C728swsO7Q4yQa0Jdp9_msAdakELJLlTeKqMkWfTAx2yQh9HjuyPWtRRO6vbrX2p8B2rcf93U1svasp-GQv6N9TeWbQUBtjZMJdTr3D1_eqSQ6", height = 150, width = 100),
                         h6("Directory of Central Java & Yogyakarta", style = "text-align: center;color: white;"),
                         tags$a(href = "http://books.google.com/books?id=hswqAAAAMAAJ&dq=Bisnis&hl=&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.co.id/books/content?id=LfPntAEACAAJ&printsec=frontcover&img=1&zoom=1&imgtk=AFLRE72L-FQSTLsE2muMBiBJMI1ScTvxC-32SOS1h3HwioRFlsD2Wz6roTPmfrtPXnIYYtcB8RF677__-5XgQIpY111rzNtOoulJNwGJ8zhe92gJYC9iNta5sL-mBAyISEGbhaqKuk5R", height = 150, width = 100),
                         h6("Getting the Most Out of Business", style = "text-align: center;color: white;"),
                         tags$a(href = "http://books.google.com/books?id=LfPntAEACAAJ&dq=Bisnis&hl=&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.co.id/books/publisher/content?id=li9zAwAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&imgtk=AFLRE73WstTYyVUyXw6YJ3-ILqQFm_Qv48p3VtWbg_DBcTYmiHdhkxPWLZGKSnjam-X21R8y_PYarNwvkOO2Lin9gwbx7vJZjWQ8rshZqHbn1hxZvZOY6zIoOXHOBLePiu34KTrCBiBp", height = 150, width = 100),
                         h6("Entrepreneurial Marketing", style = "text-align: center;color: white;"),
                         tags$a(href = "http://books.google.com/books?id=li9zAwAAQBAJ&dq=Bisnis&hl=&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.co.id/books/content?id=kkgXAQAAMAAJ&printsec=frontcover&img=1&zoom=1&imgtk=AFLRE72QVfny1DAnbekOAUocttsMFWSCBNQiE_paP0EyO1fRaVzLOVOXtSbftF6JUrI7T0o6jwlcRU4p5D6azoPA6i1EKshEgrIpKf1BsFgPMTv_FEEwofW5n9cKh1P_hswu1--prWJB", height = 150, width = 100),
                         h6("Indonesia Bank Directory", style = "text-align: center;color: white;"),
                         tags$a(href = "http://books.google.com/books?id=kkgXAQAAMAAJ&dq=Bisnis&hl=&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.co.id/books/publisher/content?id=5IQrDwAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&imgtk=AFLRE73JrDvWbWnZKiZ5BfZ7T-rLcUPlaBwZTsueXasqpfz9E2XCE6r-CR-Dd3RM0XOSQDsQx0r_EmrOzHLUOLP8YrqzjU3GWNKMbvbCqJ8Cyiz2UX87k2y1J2T-3id4FQjjrOYp8xXm", height = 150, width = 100),
                         h6("A Coach's Guide to Developing Exemplary Leaders", style = "text-align: center;color: white;"),
                         tags$a(href = "http://books.google.com/books?id=5IQrDwAAQBAJ&dq=Bisnis&hl=&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  )
                ),
                tags$br(),
                fluidRow(
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/publisher/content/images/frontcover/fiVtDwAAQBAJ?fife=w240-h345", height = 150, width = 100),
                         h6("Investing in Digital Startups", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=fiVtDwAAQBAJ&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.co.id/books/content?id=lSfFswEACAAJ&printsec=frontcover&img=1&zoom=1&imgtk=AFLRE70KFUux5wKOd4ywAtV3Sc7aPB6c2TOIyJgnwVgsnK9iAfujKCjez_Lwc5sCVicuSvBNNL5jx4OcDgnNw5B8qd-8lQ4Dxr_AhEtCBwmaVHdnqpWFr-FFcj_lf4xgSC9Mzz8YlOYq", height = 150, width = 100),
                         h6("5 Keys To Success in Todays Market Learn the Difference in Prospecting and M", style = "text-align: center;color: white;"),
                         tags$a(href = "http://books.google.com/books?id=lSfFswEACAAJ&dq=Bisnis&hl=&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/publisher/content/images/frontcover/sh1MBAAAQBAJ?fife=w240-h345", height = 150, width = 100),
                         h6("The Bank for International Ideas - from Intellectual Capital to Intellectual Property", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=sh1MBAAAQBAJ&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/publisher/content/images/frontcover/hY9FDAAAQBAJ?fife=w240-h345", height = 150, width = 100),
                         h6("Business Trends in the Digital Era", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=hY9FDAAAQBAJ&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.co.id/books/content?id=0ZNHAAAAMAAJ&printsec=frontcover&img=1&zoom=1&imgtk=AFLRE71GDnKOpKiTJpagRi6nYKSJDnYChemcPAdTb2fjJ_BgGhvqmn2PAPbWAvaJSCKJpbwgCzYRR2bBpZPvQJoqhcf8-TDOLalEXM4Z5RUlH2HSoMwFjxvs8tsfay2zh--dPDYwFPq8", height = 150, width = 100),
                         h6("The Student's Guide to Doing Research on the Internet", style = "text-align: center;color: white;"),
                         tags$a(href = "http://books.google.com/books?id=0ZNHAAAAMAAJ&dq=Bisnis&hl=&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.co.id/books/content?id=lDDPAAAAIAAJ&printsec=frontcover&img=1&zoom=1&imgtk=AFLRE72DleVRbVy7Wgu4JOASn0N3Q1SbzST8JuoK4jATGRg94bJVInuOrAr8QGCLLAxH9HXMeboZrqEunfKHAjpmByMAkre__aYH8YLM1MP2BPq5Yq3zuuJWumjKLAFGFa5BTSaqnU71", height = 150, width = 100),
                         h6("Internet Resources and Services for International Finance and Investment", style = "text-align: center;color: white;"),
                         tags$a(href = "http://books.google.com/books?id=lDDPAAAAIAAJ&dq=Bisnis&hl=&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  )
                ),
                tags$br(),
                fluidRow(
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.co.id/books/content?id=u4wQAQAAMAAJ&printsec=frontcover&img=1&zoom=1&imgtk=AFLRE71uZiNfYimajkUMNKX0lZEp0GsiieOU6d7oAc3ZxPjBY9oSWKK6N2Ht_UaPWDi4GyxdVetQVIDrcuQ5hLgvQ8g2HWGgCYYxGuIf61F9B_RQQQ87m3mqrmAfyt9_HKOcPYNNCgx_", height = 150, width = 100),
                         h6("Petrominer", style = "text-align: center;color: white;"),
                         tags$a(href = "http://books.google.com/books?id=u4wQAQAAMAAJ&dq=Bisnis&hl=&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.co.id/books/content?id=KIgrAQAAMAAJ&printsec=frontcover&img=1&zoom=1&imgtk=AFLRE70Mkc7NdvG4TqDbMWMha5zAOLfJZGi9fO1LyIllgGX3211Hp7m1a_5Undy1p1xhpm1kCJ0sjZq-PV1cj5HBE0bADoKWEYTO-jcxN5EIAJME-UkagveXSY9NLiuSjWDM1UpDQ3y5", height = 150, width = 100),
                         h6("The Washington Almanac of International Trade & Business", style = "text-align: center;color: white;"),
                         tags$a(href = "http://books.google.com/books?id=KIgrAQAAMAAJ&dq=Bisnis&hl=&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.co.id/books/publisher/content?id=KSg3DgAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&imgtk=AFLRE70rs92K9MMtkYFyjsHXyRq7FImaipi3PrFvKmx0QFeNtOw6ppLstTezHE2IiFaQ_j6IraJGFhmqjyXhuddJnKvWbf1QtBnrnmsw0_u-8jCJ63Xj0kw5EWSuyOwnM1UGgdkcQQhf", height = 150, width = 100),
                         h6("Ekonomi dan Bisnis", style = "text-align: center;color: white;"),
                         tags$a(href = "http://books.google.com/books?id=KSg3DgAAQBAJ&dq=Ekonomi+bisnis&hl=&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/publisher/content/images/frontcover/EiyxDwAAQBAJ?fife=w240-h345", height = 150, width = 100),
                         h6("Ekonomi Bisnis Peternakan", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=EiyxDwAAQBAJ&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/publisher/content/images/frontcover/qy0MEAAAQBAJ?fife=w240-h345", height = 150, width = 100),
                         h6("Statistika untuk Ekonomi, Bisnis, & Sosial", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=qy0MEAAAQBAJ&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  ),
                  column(width = 2,
                         style = "display: flex; flex-direction: column; align-items: center;",
                         img(src = "https://books.google.com/books/publisher/content/images/frontcover/P28LEAAAQBAJ?fife=w240-h345", height = 150, width = 100),
                         h6("Ekonomi Bisnis untuk SMK/MAK Kelas X", style = "text-align: center;color: white;"),
                         tags$a(href = "https://play.google.com/store/books/details?id=P28LEAAAQBAJ&source=gbs_api", style = "text-align: center; display:block;", "mari membaca")
                  )
                )
              )
      ),
      tabItem(
        tabName = "statistik",
        tabsetPanel(
          type = "tabs",
          tabPanel(
            title = "tanggal buku",
            fluidRow(
              tags$h2("10 buku terbaru", style = "text-align: center; font-weight: bold;color: white;"),
              tags$br()
            ),
            fluidRow(
              box(
                tags$h4("buku terbaru"),
                tags$p("Peringkat diurutkan berdasarkan tanggal dalam database", style = "text-align: center; font-weight: bold;"),
                tableOutput("out_tbl3"),
                width = 6
              )
            )
          ),
          tabPanel(
            title = "halaman",
            fluidRow(
              tags$br(),
              tags$ h2("10 buku dengan halaman terbanyak", style = "text-align: center; font-weight: bold;color: white;"),
              tags$br(),
            ),
            fluidRow(
              box(
                h4("jumlah halaman"),
                p("Peringkat diurutkan berdasarkan jumlah halaman dalam database", style = "text-align: center; font-weight: bold;"),
                tableOutput("out_tbl4"),
                width = 6
              )
            )
          ),
          tabPanel(
            title = "Grafik Halaman",
            fluidRow(
              tags$h2("Distribusi Jumlah Halaman Buku", style = "text-align: center; font-weight: bold;color: white;"),
              tags$br()
            ),
            fluidRow(
              box(
                plotOutput("plotHalaman"),
                width = 12
              )
            )
          ),
          tabPanel(
            title = "Word Cloud Penerbit",
            fluidRow(
              tags$h2("Penerbit dengan Publikasi Terbanyak", style = "text-align: center; font-weight: bold;color: white;"),
              tags$br()
            ),
            fluidRow(
              box(
                plotOutput("wordcloudPenerbit", height = "400px"),
                width = 12
              )
            )
          )
        )
      ),
      tabItem(tabName = "team",
              fluidRow(
                box(title = "Tim Kami", status = "primary", solidHeader = TRUE, collapsible = TRUE, width = 12,
                    div(class = "team-section",
                        h2("Tim Pengembang Kami"),
                        p("Kami adalah grup yang bersemangat yang terdiri dari profesional yang berdedikasi. Berikut adalah beberapa wajah di balik Electronic Literatur."),
                        div(class = "team-member",
                            img(src = "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/B._J._Habibie%2C_President_of_Indonesia_portrait.jpg/330px-B._J._Habibie%2C_President_of_Indonesia_portrait.jpg", class = "team-photo"),
                            h3("Abd. Rahman (G1501231055)"),
                            h4("Database Manager"),
                            p("moto hidup: gak apa pelan asal selamat.")
                        ),
                        div(class = "team-member",
                            img(src = "link_ke_foto_anggota_2", class = "team-photo"),
                            h3("Meisyatul Ilma, S.Si (G1501231073)"),
                            h4("Technical Writer"),
                            p("moto hidup: Sebaik-baiknya manusia adalah yang paling bermanfaat.")
                        ),
                        div(class = "team-member",
                            img(src = "link_ke_foto_anggota_2", class = "team-photo"),
                            h3("Riska Yulianti, S.Stat (G1501231058)"),
                            h4("Backend Developer"),
                            p("moto hidup: Everything will be okay in the end, if its not okay, its not the end.")
                        ),
                        div(class = "team-member",
                            img(src = "link_ke_foto_anggota_2", class = "team-photo"),
                            h3("Siti Mutiah, S.Pd (G1501231027)"),
                            h4("Frontend Developer"),
                            p("moto hidup: Wa ilaa rabbika farghab")
                        )
                    )
                )
              )
      )
    ),
    tags$footer(
      tags$div(
        class = "footer",
        style = "text-align: center; padding: 10px; color: white; background-color: #00477f;",
        "Hak Cipta © 2024 Electronic Literatur - Dikembangkan oleh Kelompok 6"
      )
    )
  )
)