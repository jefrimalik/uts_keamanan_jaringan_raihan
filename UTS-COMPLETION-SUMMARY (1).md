# UTS Network Security - Completion Summary

**NIM:** 24552011337
**Kasus:** 3
**Status:** ✅ Semua 7 tugas selesai

---

## Struktur Repository

```
uts_keamanan_jaringan_raihan/
├── README.md                      [Laporan utama dengan screenshot]
├── jawaban.md                     [File jawaban untuk dikumpulkan ke e-learning]
├── STUDENT-QUICK-GUIDE.md         [Catatan ringkas perintah per tugas]
├── UTS-COMPLETION-SUMMARY.md      [File ini]
├── cleanup.sh                     [Script pembersihan Docker]
└── screenshots/                   [Semua bukti screenshot]
    ├── tugas1-volume.png
    ├── tugas1-compose.png
    ├── tugas2-kripto.png
    ├── tugas3-sebelum.png
    ├── tugas3-serangan.png
    ├── tugas3-sesudah.png
    ├── tugas3-mitigasi.png
    ├── tugas4-aircrack.png
    ├── tugas5-icmp.png
    ├── tugas6-sebelum.png
    ├── tugas6-serangan.png
    ├── tugas6-tcpdump.png
    ├── tugas7-dig-log.png
    ├── tugas7-deteksi.png
    └── tugas7-decode.png
```

---

## Status per Tugas

| Tugas | Materi | Status | Catatan |
|---|---|---|---|
| 1 | Docker, volume, compose | ✅ Selesai | Volume persisten dibuktikan, compose 2 service berhasil |
| 2 | Kriptografi (AES-256, SHA-256, sertifikat) | ✅ Selesai | Hash sebelum/sesudah identik, sertifikat self-signed terbit |
| 3 | ARP spoofing | ✅ Selesai | MAC gateway berubah saat spoof, pulih dengan static ARP |
| 4 | WPA2 handshake (aircrack-ng) | ✅ Selesai | Hasil: KEY NOT FOUND — file capture terverifikasi tidak valid sebagai 802.11 capture |
| 5 | ICMP dengan Scapy | ✅ Selesai | TTL 64, tipe ICMP balasan 0 (echo-reply) |
| 6 | SYN flood & three-way handshake | ✅ Selesai | SYN_RECV naik saat serangan (setelah syncookies dinonaktifkan sementara), three-way handshake tertangkap tcpdump |
| 7 | DNS exfiltration | ✅ Selesai | NIM berhasil dikirim via subdomain hex, terdeteksi script, dan di-decode kembali |

---

## Infrastruktur yang Digunakan

- **Docker Desktop** di Windows
- **Image custom:**
  - `uts-kali-tools` (dari `kalilinux/kali-rolling` + hping3, tcpdump, dnsutils, aircrack-ng, scapy, dsniff)
  - `uts-dnsmasq` (dari `alpine:3.20` + dnsmasq)
- **Image base:** `alpine`, `nginx:alpine`, `curlimages/curl`, `python:3.11-slim`, `kalilinux/kali-rolling`
- Semua jaringan serangan memakai `internal: true` sesuai ketentuan soal — tidak ada akses ke luar lab.

---

## Verifikasi Cleanup

Sebelum dikumpulkan, jalankan:
```bash
bash cleanup.sh
```
Lalu pastikan:
```bash
docker ps -a           # kosong atau minimal
docker network ls      # hanya bridge, host, none
docker volume ls       # hanya local, tidak ada vol-k3
```

---

## Sumber Materi Pendukung

Dockerfile, docker-compose.yml, dan skrip Python (`kirim_icmp.py`, `analisis_dns.py`) diambil dari repositori mata kuliah:
`https://github.com/yastiaisyah/Network-Security-Course-Bank`
