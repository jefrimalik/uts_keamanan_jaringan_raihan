#!/bin/bash
#
# UTS Network Security - Cleanup Script (Kasus 3)
# Jalankan ini SETELAH selesai mengerjakan semua tugas
# Usage: bash cleanup.sh
#

set -e

echo "=========================================="
echo "  UTS Network Security - Cleanup (Kasus 3)"
echo "=========================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if ! docker ps &> /dev/null; then
    echo -e "${RED}✗ Docker daemon tidak berjalan${NC}"
    exit 1
fi

echo -e "${BLUE}Membersihkan resource Docker...${NC}"
echo ""

echo -e "${YELLOW}=== Kondisi Saat Ini ===${NC}"
echo "Container berjalan:"
docker ps --format "table {{.Names}}\t{{.Status}}" || echo "  (tidak ada)"

echo ""
echo "Network (selain default):"
docker network ls --format "table {{.Name}}\t{{.Driver}}" | grep -v "bridge\|host\|none" || echo "  (tidak ada)"

echo ""
echo "Volume:"
docker volume ls --format "table {{.Name}}" | grep -v "local" || echo "  (tidak ada - hanya default)"

echo ""

echo -e "${YELLOW}=== Menghentikan Container ===${NC}"
if [ "$(docker ps -q)" ]; then
    docker stop $(docker ps -q)
    echo -e "${GREEN}✓ Container dihentikan${NC}"
else
    echo "  (tidak ada container berjalan)"
fi

echo ""
echo -e "${YELLOW}=== Menghapus Container ===${NC}"
if [ "$(docker ps -a -q)" ]; then
    docker rm -f $(docker ps -a -q)
    echo -e "${GREEN}✓ Semua container dihapus${NC}"
else
    echo "  (tidak ada container untuk dihapus)"
fi

echo ""
echo -e "${YELLOW}=== Menghapus Network Kasus 3 ===${NC}"
networks_to_remove=$(docker network ls --format "{{.Name}}" | grep -E "lab-k3|arp-k3|k3" || true)
if [ ! -z "$networks_to_remove" ]; then
    echo "$networks_to_remove" | while read net; do
        docker network rm "$net" 2>/dev/null && echo "  ✓ $net"
    done
    echo -e "${GREEN}✓ Network dihapus${NC}"
else
    echo "  (tidak ada network Kasus 3 untuk dihapus)"
fi

echo ""
echo -e "${YELLOW}=== Menghapus Volume Kasus 3 ===${NC}"
volumes_to_remove=$(docker volume ls --format "{{.Name}}" | grep -E "vol-k3" || true)
if [ ! -z "$volumes_to_remove" ]; then
    echo "$volumes_to_remove" | while read vol; do
        docker volume rm "$vol" 2>/dev/null && echo "  ✓ $vol"
    done
    echo -e "${GREEN}✓ Volume dihapus${NC}"
else
    echo "  (tidak ada volume Kasus 3 untuk dihapus)"
fi

echo ""
echo -e "${YELLOW}=== Verifikasi Akhir ===${NC}"
echo "Sisa container:"
docker ps -a | wc -l | xargs echo "  Total baris:"
if [ "$(docker ps -a -q)" ]; then
    echo -e "${RED}  ⚠ Masih ada container tersisa!${NC}"
    docker ps -a --format "table {{.Names}}\t{{.Status}}"
else
    echo -e "${GREEN}  ✓ Bersih${NC}"
fi

echo ""
echo "Sisa network (selain default):"
if [ "$(docker network ls --format '{{.Name}}' | grep -v 'bridge\|host\|none')" ]; then
    echo -e "${RED}  ⚠ Masih ada network custom tersisa!${NC}"
else
    echo -e "${GREEN}  ✓ Bersih (hanya network default)${NC}"
fi

echo ""
echo "Sisa volume:"
if [ "$(docker volume ls --format '{{.Name}}' | grep -v 'local')" ]; then
    echo -e "${RED}  ⚠ Masih ada volume custom tersisa!${NC}"
else
    echo -e "${GREEN}  ✓ Bersih (hanya volume local default)${NC}"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}✓ Cleanup Selesai!${NC}"
echo ""
echo "Checklist sebelum kumpulkan:"
echo "  [ ] Semua 7 Tugas sudah dikerjakan"
echo "  [ ] Output/bukti sudah ada di jawaban.md dan screenshots/"
echo "  [ ] NIM & Kasus tercantum di jawaban.md"
echo "  [ ] Semua container sudah dihapus"
echo "  [ ] Semua network sudah dihapus"
echo "  [ ] Semua volume sudah dihapus"
echo ""
echo "Siap untuk dikumpulkan ke e-learning!"
echo "=========================================="
