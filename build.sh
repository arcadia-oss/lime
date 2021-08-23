#!/bin/bash
TC_DIR="$HOME"
echo "Cloning dependencies"
git clone --depth=1 https://github.com/mvaisakh/gcc-arm64 -b gcc-new $TC_DIR/arm64
git clone --depth=1 https://github.com/mvaisakh/gcc-arm -b gcc-new $TC_DIR/arm
git clone https://github.com/sm6115-dev/AnyKernel3.git  --depth=1 AnyKernel

echo "Done"
KERNEL_DIR=$(pwd)
IMAGE="${KERNEL_DIR}/out/arch/arm64/boot/Image"
TANGGAL=$(date +"%Y%m%d-%H")
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
export ARCH=arm64
export KBUILD_BUILD_USER=gagan
export KBUILD_BUILD_HOST=malvi

make O=out ARCH=arm64 vendor/bengal-perf_defconfig

# Compile plox
compile() {
    make -j$(nproc --all) O=out \
                PATH="$TC_DIR/arm64/bin:$TC_DIR/arm/bin:$PATH" \
                CROSS_COMPILE=$TC_DIR/arm64/bin/aarch64-elf- \
                CROSS_COMPILE_ARM32=$TC_DIR/arm/bin/arm-eabi- |& tee $LOG
}


module() {
[ -d "modules" ] && rm -rf modules || mkdir -p modules

compile \
INSTALL_MOD_PATH=../modules \
INSTALL_MOD_STRIP=1 \
modules_install
}

# Zipping
zipping() {
    cd AnyKernel || exit 1
    cp ../out/arch/arm64/boot/Image .
    zip -r9 CartelProject-lime-BETA-${TANGGAL}.zip *
    cd ..
}

# Upload
upload() {
    cd AnyKernel && curl -sL https://git.io/file-transfer | sh && ./transfer wet *.zip
    cd ..
}

compile
module
zipping
upload
