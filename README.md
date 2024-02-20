# Project_MDS6
Repository ini merupakan peoject tugas akhir UTS STA1562

# Tentang
Project akhir mata kuliah Manajemen Data Statistika mengambil topik tentang buku pada website googel books. Project ini mengspesifikasikan pencarian buku secara umum. Hasil yang diharapkan adalah terbentuknya sebuah platform manajemen database berupa web application yang dapat memudahkan user dalam mencari referensi buku beserta linknya untuk sebuah pembelajaran. User dapat mencari berdasarkan berdasarkan kategori yang di inginkan, misalnya pencarian berdasarkan penulis, penerbit, kategori, dan tahun terbit.

# Skema ER Diagram Database
![skema database](https://github.com/smutiah48/Project_MDS6/assets/158244552/8d1d16b5-5983-4104-8108-4be089b75a30)
||--|{: Menunjukkan hubungan satu-ke-banyak (one-to-many), di mana satu entitas di sisi "||" harus berhubungan dengan nol atau lebih entitas di sisi "{|}".

||--o{: Menunjukkan hubungan satu-ke-banyak (one-to-many) yang opsional, di mana satu entitas di sisi "||" bisa berhubungan dengan nol atau lebih entitas di sisi "{|}", tetapi hubungannya tidak wajib.

||--||: Menunjukkan hubungan satu-ke-satu (one-to-one), di mana setiap entitas di satu sisi harus berhubungan dengan tepat satu entitas di sisi lain.

||--o{ atau ||--o||: Dalam beberapa notasi, ini bisa juga menandakan hubungan satu-ke-banyak atau satu-ke-satu yang opsional di sisi "o".
