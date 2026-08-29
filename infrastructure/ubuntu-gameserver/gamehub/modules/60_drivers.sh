#!/bin/bash

install_gpu_drivers() {
    info "Detekce grafické karty..."
    if lspci | grep -i nvidia > /dev/null; then
        info "Detekována NVIDIA. Instaluji proprietární ovladače..."
        add-apt-repository -y ppa:graphics-drivers/ppa >/dev/null
        apt-get update -qq
        apt-get install -y -qq nvidia-driver-535 nvidia-utils-535 libvulkan1 libvulkan1:i386 >/dev/null
    elif lspci | grep -i 'amd\|ati' > /dev/null; then
        info "Detekována AMD. Instaluji Mesa a Vulkan..."
        add-apt-repository -y ppa:kisak/kisak-mesa >/dev/null
        apt-get update -qq
        apt-get install -y -qq mesa-vulkan-drivers mesa-vulkan-drivers:i386 >/dev/null
    fi
}

install_vulkan_layers() {
    info "Instalace Vulkan nástrojů (MangoHud)..."
    apt-get install -y -qq mangohud vulkan-tools >/dev/null
}
