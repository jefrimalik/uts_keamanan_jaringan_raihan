# Laporan UTS Praktik Infrastruktur & Network Attacks

- **Nama:** [ISI NAMA ANDA]
- **NIM:** 24552011337
- **Kelas:** TIF RP 24E CNS

## Penentuan Studi Kasus

- Penjumlahan Digit NIM: 2 + 4 + 5 + 5 + 2 + 0 + 1 + 1 + 3 + 3 + 7 = 33
- Perhitungan Sisa Bagi: 33 mod 10 = 3
- **Kasus Terpilih:** Kasus 3

---

## Tugas 1 (Pertemuan 1): Docker & Volume Persistensi

### 1. Pembuktian Data Persisten Volume `vol-k3`

Data NIM `24552011337` yang ditulis ke dalam volume `vol-k3` tetap persisten dan dapat dibaca oleh container baru meskipun container pembuat awal (`writer-k3`) telah dihapus.

![Bukti Volume Persistensi](screenshots/tugas1-volume.png)

### 2. Pengujian Akses Jaringan Internal Compose

Container `attacker-k3` berhasil mengambil halaman utama HTTP dari web server `target-k3` di dalam jaringan internal terisolasi (`internal: true`).

![Bukti Akses Compose Target](screenshots/tugas1-compose.png)

---

## Tugas 2 (Pertemuan 2): Kriptografi AES-256 & Sertifikat Self-Signed

### 1. Enkripsi AES-256-CBC & Integrity Check (SHA-256)

File `laporan-k3.txt` dienkripsi menjadi `laporan-k3.enc` menggunakan algoritma AES-256-CBC dengan kata sandi `kunci-k3-2026`. Integritas data terverifikasi karena nilai hash SHA-256 berkas sebelum enkripsi identik dengan berkas setelah dekripsi (`laporan-k3-dekrip.txt`).

### 2. Penerbitan Sertifikat Self-Signed X.509

Sertifikat SSL/TLS X.509 berhasil diterbitkan secara lokal untuk Common Name (CN) `k3.exfil.lab`.

![Bukti Hash SHA-256 dan Sertifikat Self-Signed](screenshots/tugas2-kripto.png)

**Perbedaan sertifikat self-signed dan sertifikat yang ditandatangani CA:** [TULIS PENJELASAN ANDA SENDIRI DI SINI]

---

## Tugas 3 (Pertemuan 3): ARP Spoofing & Mitigasi Static ARP

### 1. Tabel ARP Sebelum Serangan

Tabel ARP korban (`victim-k3`) menunjukkan MAC address gateway yang benar: `da:c9:bc:b1:b9:f7`.

![Bukti ARP Sebelum Serangan](screenshots/tugas3-sebelum.png)

### 2. Serangan ARP Spoofing Berlangsung

Serangan `arpspoof` dari container `attacker-k3` sedang berjalan, mengirim paket ARP reply palsu secara terus-menerus.

![Bukti ARP Spoofing Berjalan](screenshots/tugas3-serangan.png)

### 3. Tabel ARP Sesudah Serangan

Tabel ARP korban berhasil diracuni — MAC address gateway berubah dari `da:c9:bc:b1:b9:f7` menjadi `2e:6e:0a:22:bb:34` (MAC attacker).

![Bukti ARP Sesudah Serangan](screenshots/tugas3-sesudah.png)

### 4. Penerapan Mitigasi Static ARP

Penguncian entri ARP dilakukan secara statis dengan perintah `ip neigh replace`. Alamat MAC gateway terdaftar sebagai entri `PERMANENT` sehingga kebal dari racun ARP (ARP Poisoning).

![Bukti Mitigasi Static ARP](screenshots/tugas3-mitigasi.png)

**Mitigasi lain selain static ARP:** [TULIS PENJELASAN ANDA SENDIRI DI SINI, misalnya Dynamic ARP Inspection]

---

## Tugas 4 (Pertemuan 4): Analisis WPA2 Handshake

### Bukti Eksekusi Aircrack-ng

Pengujian file capture `handshake-k3.cap` dilakukan menggunakan `aircrack-ng` dengan kamus `wordlist-k3.txt`. File capture terbukti tidak valid sebagai 802.11 capture (bukan karena password di luar wordlist), sehingga hasilnya **KEY NOT FOUND**.

![Bukti Analisis WPA2 Handshake](screenshots/tugas4-aircrack.png)

**Penjelasan 4-Way Handshake WPA2:** [TULIS PENJELASAN ANDA SENDIRI DI SINI — 4 langkah: ANonce, SNonce+MIC, GTK+MIC, konfirmasi]

---

## Tugas 5 (Pertemuan 5): ICMP dengan Scapy & Smurf Attack

### Eksekusi Skrip ICMP Scapy

Pengiriman paket ICMP Echo Request ke IP target berhasil dieksekusi menggunakan skrip `kirim_icmp.py`. Balasan diterima dengan tipe ICMP Echo Reply (Type 0) dan nilai TTL 64.

![Bukti ICMP Scapy](screenshots/tugas5-icmp.png)

**Penjelasan Smurf Attack:** [TULIS PENJELASAN ANDA SENDIRI DI SINI]

---

## Tugas 6 (Pertemuan 6): SYN Flood & Three-Way Handshake

### 1. SYN_RECV Sebelum dan Saat Serangan

Sebelum serangan, jumlah koneksi `SYN_RECV` konsisten 0. Saat serangan `hping3 --flood` berlangsung (setelah SYN cookies dinonaktifkan sementara untuk demonstrasi), jumlah `SYN_RECV` meningkat.

![Bukti SYN_RECV Sebelum Serangan](screenshots/tugas6-sebelum.png)

![Bukti SYN_RECV Saat Serangan](screenshots/tugas6-serangan.png)

### 2. Three-Way Handshake via tcpdump

Tangkapan paket `tcpdump` saat koneksi HTTP normal dibuat menunjukkan urutan SYN, SYN-ACK, ACK yang lengkap.

![Bukti Three-Way Handshake](screenshots/tugas6-tcpdump.png)

**Mitigasi SYN Flood:** [TULIS PENJELASAN ANDA SENDIRI DI SINI — SYN cookies]

---

## Tugas 7 (Pertemuan 7): DNS Exfiltration

### 1. Pengiriman dan Pencatatan Query DNS

NIM `24552011337` diubah menjadi hex (`3234353532303131333337`) dan dikirim sebagai subdomain ke DNS server lab (`dns-k3`), lalu tercatat di log dnsmasq.

![Bukti Query DNS dan Log](screenshots/tugas7-dig-log.png)

### 2. Deteksi Query Mencurigakan

Script `analisis_dns.py` berhasil mendeteksi label subdomain mencurigakan (panjang 22 karakter, berisi hex murni).

![Bukti Deteksi DNS Exfiltration](screenshots/tugas7-deteksi.png)

### 3. Decode Kembali Menjadi NIM

Hex `3234353532303131333337` berhasil di-decode kembali menjadi `24552011337`, identik dengan NIM asli.

![Bukti Decode NIM](screenshots/tugas7-decode.png)

**Kenapa teknik ini sulit diblokir firewall biasa + indikator deteksi:** [TULIS PENJELASAN ANDA SENDIRI DI SINI]

---

## Catatan

Seluruh pengujian dilakukan di lingkungan lab Docker lokal dengan jaringan `internal: true`, sesuai ketentuan soal. Tidak ada serangan yang diarahkan ke host di luar lab.
