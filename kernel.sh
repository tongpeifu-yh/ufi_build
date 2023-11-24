#编译内核
git clone https://github.com/OpenStick/linux --depth=1
export CROSS_COMPILE=aarch64-linux-gnu-
export ARCH=arm64
make msm8916_defconfig
make menuconfig
make -j16
fakeroot make-kpkg  --initrd --cross-compile aarch64-linux-gnu- --arch arm64  kernel_image kernel_headers
