<p align="center">
  <img width="400" height="343" src="https://github.com/smutiah48/Project_MDS6/blob/main/scr/logo.jpeg">
</p>

<div align="center">

# ELIT (Electronic Literartur)

[Tentang](#scroll-tentang)
•
[Screenshot](#rice_scene-screenshot)
•
[Demo](#dvd-demo)
•
[Dokumentasi](#blue_book-dokumentasi)
  
</div>

## :bookmark_tabs: Menu
- [Tentang](#scroll-tentang) 📖
- [Screenshot](#rice_scene-screenshot) 📸
- [Demo](#dvd-demo) 🎬
- [Dokumentasi](#blue_book-dokumentasi) 📚
- [Requirements](#exclamation-requirements) ❗
- [Skema Database](#floppy_disk-skema-database) 💾
- [ERD](#rotating_light-erd) 📈
- [Deskripsi Data](#heavy_check_mark-deskripsi-data) 📋
- [Struktur Folder](#open_file_folder-struktur-folder) 📁
- [Tim Pengembang](#smiley_cat-tim-pengembang) 👨‍💻

  ## 📖 Tentang
Project akhir mata kuliah Manajemen Data Statistika mengambil topik tentang buku pada website googel books. Project ini mengspesifikasikan pencarian buku secara umum. Hasil yang diharapkan adalah terbentuknya sebuah platform manajemen database berupa web application yang dapat memudahkan user dalam mencari referensi buku beserta linknya untuk sebuah pembelajaran. User dapat mencari berdasarkan berdasarkan kategori yang di inginkan, misalnya pencarian berdasarkan penulis, penerbit, kategori, dan tahun terbit.

## :📸 Screenshot

<p align="center">
  <img width="900" height="420" src="https://github.com/smutiah48/Project_MDS6/blob/main/scr/Tampilan%20awal.png">
</p>

## 🎬 Demo

Berikut merupakan link untuk shinnyapps atau dashboard dari project kami:
...........

## :📚 Dokumentasi 

Dokumentasi penggunaan aplikasi database. ..........

## :❗ Requirements

- Scrapping data menggunakan package R yaitu `rvest` dengan pendukung package lainnya seperti `tidyverse`,`rio`,`kableExtra` dan `stingr`  
- RDBMS yang digunakan adalah PostgreSQL dan ElephantSQL
- Dashboard menggunakan `shinny`, `shinnythemes`, `bs4Dash`, `DT`, dan `dplyr` dari package R

  ## :💾 Skema Database

Menggambarkan struktur *primary key* **buku**, **penulis**, **penerbit** dan **kategori** dengan masing-masing *foreign key* dalam membangun relasi antara tabel atau entitas.
<p align="center">
  <img width="600" height="400" src="https://github.com/smutiah48/Project_MDS6/blob/main/Skema.jpg">
</p>

## 📈 ERD

ERD (Entity Relationship Diagram) menampilkan hubungan antara entitas dengan atribut. Pada project ini, entitas buku terdapat tiga atribut yang berhubungan dengan atribut pada entitas lain, yaitu id_penulis berhubungan dengan entitas penulis, id_penerbit berhubungan dengan entitas penerbit, dan id_kategori berhubungan dengan entitas kategori.

Selanjutnya, entitas penulis terdapat dua atribut yang berhubungan dengan atribut pada entitas lain, yaitu id_penerbit berhubungan dengan entitas penerbit, id_penulis bergubungan dengan entitas buku.

Selain itu, entitas penerbit terdiri dari dua atribut yang berhubungan yaitu id_penerbit dengan atribut penulis dan buku. Untuk entitas kategori saling berhubungan pada entitas buku yaitu atribut id_kategori.

<p align="center">
  <img width="600" height="400" src="https://github.com/smutiah48/Project_MDS6/blob/main/ERD%20Elit.png">
</p>

## 📋 Deskripsi Data

Berisi tentang tabel-tabel yang digunakan berikut dengan sintaks SQL DDL (CREATE).

### Create Database
ELIT (Electronic Literatur) menyimpan informasi yang mewakili atribut data yang saling berhubungan untuk kemudian dianalisis.
```sql

```
### Create Table penerbit
Table penerbit memberikan informasi kepada user mengenai lembaga penerbit buku, sehingga user dapat mengetahui id penerbit, nama penerbit, dan lokasi penerbit tersebut. Berikut deskripsi untuk setiap tabel penerbit.
| Attribute          | Type                   | Description                     |
|:-------------------|:-----------------------|:--------------------------------|
| id_penerbit        | character varying(10)  | Id Penerbit                     |
| nama_penerbit      | character varying(100) | Nama Penerbit                   |
| tempat_penerbit    | character varying(100) | Lokasi                          |

dengan script SQL sebagai berikut:
```sql
CREATE TABLE IF NOT EXISTS penerbit (
    id_penerbit VARCHAR(10) PRIMARY KEY,
    nama_penerbit VARCHAR(100) NOT NULL,
    tempat_penerbit VARCHAR(100)
);
select * from penerbit
```
### Create Table Kategori
Table kategori memberikan informasi yang memudahkan user mengetahui tentang kategori yang dicari. ELIT menyediakan 14 kategori buku diantaranya ilmu alam,kesehatan, hukum dan tata negara, dan pengembangan diri. Pada tabel kategori berisi id kategori dan nama kategori. Id kategori adalah kode yang digunakan untuk membedakan kategori yang satu dengan yang lainnya. Berikut deskripsi untuk setiap tabel kategori.
| Attribute          | Type                   | Description                     |
|:-------------------|:-----------------------|:--------------------------------|
| id_kategori        | character varying(10)  | Id kategori                     |
| nama_kategori      | character varying(100) | Nama kategori                   |

dengan script SQL sebagai berikut:
```sql
CREATE TABLE IF NOT EXISTS kategori (
    id_kategori VARCHAR(10) PRIMARY KEY,
    nama_kategori VARCHAR(100) NOT NULL
);
select * from kategori
```
### Create Table Penulis
Table penulis memberikan informasi kepada user mengenai beberapa identitas penulis buku. User dapat mengetahui id buku dari penulis, nama penulis jurnal, id penerbit dan deskripsi buku. Berikut deskripsi untuk setiap tabel penulis.
| Attribute                  | Type                   | Description                     		      |
|:---------------------------|:-----------------------|:------------------------------------------|
| id_penulis                 | character varying(10)  | Id Penulis                       		      |
| nama_penulis               | character varying(100) | Nama Penulis                   		        |
| id_penerbit                | character varying(10)  | Id Penerbit                    		        |	
| deskripsi                  | character varying(500) | Deskripsi Buku                 		        |


dengan script SQL sebagai berikut:
```sql
CREATE TABLE IF NOT EXISTS penulis (
    id_penulis VARCHAR(10) PRIMARY KEY,
    nama_penulis VARCHAR(100) NOT NULL,
    id_penerbit VARCHAR(10) NOT NULL,
    FOREIGN KEY (id_penerbit) REFERENCES penerbit(id_penerbit)
);
select * from penulis
```

### Create Table Buku
Table buku menyajikan informasi lengkap mengenai sebuah buku. Selain dapat mengetahui judul, user juga akan mendapatkan informasi isbn dan tahun terbit sebuah buku. id penulis, id penerbit, dan id kategori tersaji pada table ini. Berikut deskripsi untuk setiap tabel buku.
| Attribute                  | Type                   | Description                     		       |
|:---------------------------|:-----------------------|:-------------------------------------------|
| id_buku                    | character varying(10)  | Id Buku                       	  	       |
| judul_buku                 | character varying(200) | Judul Buku                  		           |
| isbn                       | character varying(20)  | ISBN                   		                 |	
| tahun_terbit               | character varying(20)  | Tahun terbit buku                	         |
| id_penulis                 | character varying(10)  | Id penulis                                 |
| id_penerbit    	           | character varying(10)  | Id Penerbit                                |
| id_kategori                | character varying(10)  | Id Kategori     			                     |

dengan script SQL sebagai berikut:              
```sql
CREATE TABLE IF NOT EXISTS buku (
    id_buku VARCHAR(10) PRIMARY KEY,
    judul_buku VARCHAR(200) NOT NULL,
    ISBN VARCHAR(20) NOT NULL,
    tahun_terbit VARCHAR(50) NOT NULL,
    id_penulis VARCHAR(10) NOT NULL,
    id_penerbit VARCHAR(10) NOT NULL,
    id_kategori VARCHAR(10) NOT NULL,
	jumlah_halaman VARCHAR(10) NOT NULL,
	link_buku VARCHAR(300) NOT NULL,
	deskripsi TEXT NOT NULL,
    FOREIGN KEY (id_penulis) REFERENCES penulis(id_penulis),
    FOREIGN KEY (id_penerbit) REFERENCES penerbit(id_penerbit),
    FOREIGN KEY (id_kategori) REFERENCES kategori(id_kategori)
);
select * from buku
```
## 📁 Struktur Folder

```

```

## 👨‍💻 Tim Pengembang

- Frontend Developer: [Siti Mutiah](https://github.com/smutiah48/Project_MDS6) (G1501231027)
- Backend Developer: [Rizka Yulianti](https://github.com/riskaayulian17) (G1501231058)
- Technical Writer: [Meisyatul Ilma](https://github.com/meisyatulilma) (G1501231073)
- Database Manager: [Abd. Rahman](https://github.com/ibnuysf) (G1501231055)
