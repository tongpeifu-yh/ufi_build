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

#以下为在rootfs中进行的操作
#需要安装的其他包有：
#	linux内核
#	openstick-utils
#	firmware
#最好还要安装：
#   openssh-server
#   net-tools
#   locales
#其中，linux内核的两个包必须用dpkg -i安装，否则不会生成initrd.img

#以下内容通过分析苏苏小亮亮的rootfs得到
#mobian包有：
        # alsa-ucm-conf 
        # f2fs-tools 
        # libglib2.0-0 
        # libglib2.0-bin 
        # libglib2.0-data 
        # libmbim-glib4 
        # libmbim-proxy 
        # libmm-glib0 
        # libqmi-glib5 
        # libqmi-proxy 
        # libqmi-utils 
        # libqrtr1 
        # mobian-tweaks-common 
        # mobile-tweaks-common 
        # modemmanager 
        # qrtr 
        # rmtfs
#其中qrtr和rmtfs需要自己构建安装（但是感觉没什么用的样子）
#rmtfs：https://github.com/andersson/rmtfs
#qrtr：https://github.com/andersson/qrtr

#其他的包：
#dnsmasq netfilter-persistent unattended-upgrades zram-tools

#手动开启的服务
#systemd-networkd.service systemd-networkd-wait-online.service

#手动编辑并添加的服务：(服务和脚本文件来自苏苏小亮亮的rootfs，现置于bin_sh_service/目录下)
#   mobian-setup-usb-network.service       
#   mobian-ssh-keygen.service            //可以省略，内容仅有执行ssh-keygen
#   mobian-usb-gadget.service            
#   依赖的脚本：
#       mobian-setup-usb-network
#       mobian-usb-gadget
#重新配置语言为中文
#sudo dpkg-reconfigure locales
