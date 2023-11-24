#创建rootfs包
sudo qemu-debootstrap --arch=${ARCH} \
--keyring /usr/share/keyrings/debian-archive-keyring.gpg \
--variant=buildd \
--exclude=debfoster bookworm $ROOTFS http://127.0.0.1:8081/debian
#需要安装的其他包有：
#	linux内核
#	openstick-utils
#	firmware
#其中，linux内核的两个包必须用dpkg -i安装，否则不会生成initrd.img
