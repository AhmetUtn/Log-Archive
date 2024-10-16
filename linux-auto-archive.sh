#!/bin/bash

# Dağıtımı algılayan fonksiyon
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        echo "Dağıtım algılanamadı!"
        exit 1
    fi
}

# Paket yöneticisine göre tar ve sudo'yu yükleme fonksiyonu
install_dependencies() {
    case "$DISTRO" in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y tar sudo
            ;;
        centos|fedora|rhel)
            sudo yum install -y tar sudo
            ;;
        arch)
            sudo pacman -Sy --noconfirm tar sudo
            ;;
        alpine)
            sudo apk add tar sudo
            ;;
        opensuse|suse)
            sudo zypper install -y tar sudo
            ;;
        *)
            echo "Bu dağıtım için otomatik kurulum desteklenmiyor!"
            exit 1
            ;;
    esac
}

# Tar ve sudo'nun kurulu olup olmadığını kontrol et
check_dependencies() {
    command -v tar >/dev/null 2>&1 || MISSING_TAR=true
    command -v sudo >/dev/null 2>&1 || MISSING_SUDO=true

    if [ "$MISSING_TAR" == true ] || [ "$MISSING_SUDO" == true ]; then
        detect_distro
        echo "Gerekli paketler eksik. Dağıtım: $DISTRO"
        install_dependencies
    else
        echo "Tüm gerekli paketler kurulu."
    fi
}

# Arşivleme fonksiyonu
archive_logs() {
    LOG_DIR=${1:-/var/log}
    OUTPUT_DIR=${2:-./archived_logs}
    CURRENT_TIME=$(date +"%Y%m%d_%H%M%S")
    ARCHIVE_NAME="logs_archive_$CURRENT_TIME.tar.gz"
    ARCHIVE_PATH="$OUTPUT_DIR/$ARCHIVE_NAME"

    # Çıkış dizini yoksa oluştur
    if [ ! -d "$OUTPUT_DIR" ]; then
        mkdir -p "$OUTPUT_DIR"
    fi

    # Logları arşivle (sudo gerekli olabilir)
    sudo tar -czf "$ARCHIVE_PATH" -C "$LOG_DIR" .

    # Arşivleme işlemini log dosyasına kaydet
    echo "Archived $LOG_DIR at $CURRENT_TIME to $ARCHIVE_PATH" >> "$OUTPUT_DIR/archive_log.txt"

    # İşlemi tamamla
    echo "Logs archived to $ARCHIVE_PATH"
}

# Bağımlılıkları kontrol et ve kur
check_dependencies

# Arşivleme işlemini başlat
archive_logs $1 $2
