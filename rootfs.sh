#!/usr/bin/bash
export ARCH=arm64
export ROOTFS=~/rootfs/tmpfs
#创建rootfs包
#创建前，需要设定好目录结构软连接，如/bin->/usr/bin，debootstrap默认不会设置软连接而是新建目录
#eg：
#sudo mkdir ./usr/bin 
#sudo ln -s ./usr/bin ./bin
#如此重复sbin,lib,lib32,lib64,libx32等即可
for dir in sbin bin lib lib32 lib64 libx32;do
    sudo mkdir usr/$dir -p
    sudo ln -s usr/$dir $dir
done
#构建底包
sudo apt -y install debian-archive-keyring
sudo apt-key add /usr/share/keyrings/debian-archive-keyring.gpg
sudo qemu-debootstrap --arch=${ARCH} \
--keyring /usr/share/keyrings/debian-archive-keyring.gpg \
--variant=buildd \
--exclude=debfoster bookworm $ROOTFS http://127.0.0.1:8081/debian

#构建好底包，用如下命令登录：
HOME=/root sudo chroot $ROOTFS /bin/bash --login -i
#需要安装的其他包有：
#	linux内核
#	openstick-utils
#	firmware
#最好还要安装：
#   openssh-server
#   net-tools
#  
#其中，linux内核的两个包必须用dpkg -i安装，否则不会生成initrd.img
