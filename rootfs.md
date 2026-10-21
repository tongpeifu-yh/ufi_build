## 构建底包

从零开始为板子构建底包。这里以debian 12 bookworm为例。构建前请安装好所需软件，详见prepare.md。

### 构建基础rootfs

debian系linux提供了一个名为`debootstrap`的软件，用于快速构建一个该系统的rootfs。其他系也有对应的软件，可自行探索。这里使用它来构建基础的rootfs。

首先，我们设置几个环境变量：

```shell
export ARCH=arm64
export ROOTFS=~/rootfs/tmpfs
export MIRROR=https://mirrors.tuna.tsinghua.edu.cn/debian/
```

在构建之前，需要设定好目录结构软连接，如bin->usr/bin，`debootstrap`默认不会设置软连接而是新建目录。

```shell
cd $ROOTFS
for dir in sbin bin lib lib32 lib64 libx32;do
    sudo mkdir usr/$dir -p
    sudo ln -s usr/$dir $dir
done
```

下面开始构建底包：

```Shell
sudo apt -y install debian-archive-keyring
sudo apt-key add /usr/share/keyrings/debian-archive-keyring.gpg
sudo qemu-debootstrap --arch=${ARCH} \
	--keyring /usr/share/keyrings/debian-archive-keyring.gpg \
	--variant=buildd \
	--exclude=debfoster bookworm $ROOTFS $MIRROR
```

一个基础的底包（包含基本的libc、包管理器apt等）就构建好了。使用如下命令可登录进入底包环境：

```Shell
HOME=/root sudo chroot $ROOTFS /bin/bash --login -i
```

> 注意，像sudo这类权限中含有`s`位的程序一旦经过拷贝，`s`位就会丢失，程序功能就会异常。因此，底包应当直接挂载rootfs镜像并在其中构建，而不是先在主机文件系统中构建然后再拷贝到rootfs。

### 安装必要的软件

进入底包中，可用自由使用apt命令安装软件。以下是必须安装的：

```Shell
apt update
apt -y install iputils-ping iproute2 iw \
	lsb-release vim whois sudo systemd \
    systemd-sysv kmod network-manager \
    parted openssh-server net-tools \
    locales dnsmasq netfilter-persistent \
    unattended-upgrades zram-tools gawk \
    initramfs-tools wget curl
```

### Mobian软件

通过分析苏苏小亮亮的rootfs得到以下来自Mobian的软件包：

```Shell
apt install mobian-archive-keyring
echo "deb http://repo.mobian.org/ bookworm main non-free non-free-firmware" >> /etc/apt/sources.list.d/mobian.list
apt update
apt install alsa-ucm-conf f2fs-tools libglib2.0-0 libglib2.0-bin \
    libglib2.0-data libmbim-glib4 libmbim-proxy libmm-glib0 \
    libqmi-glib5 libqmi-proxy libqmi-utils libqrtr1 \
    mobian-tweaks-common mobile-tweaks-common modemmanager \
    qrtr-tools rmtfs
```

其中`qrtr`和`rmtfs`这两个可能需要自行构建安装（如果使用较新的源应该可以直接安装`rmtfs`、`qrtr-tools`、`libqrtr1`）。其中，`rmtfs`来自：https://github.com/andersson/rmtfs ，`qrtr`来自：https://github.com/andersson/qrtr 。

### 配置服务

手动开启下列服务（未确认作用，可能多余）：`systemd-networkd.service`， `systemd-networkd-wait-online.service`。

```Shell
systemctl enable systemd-networkd.service
systemctl enable systemd-networkd-wait-online.service
```

手动关闭下列服务（或者前面安装软件时把 dnsmasq 换成 dnsmasq-base）：

```Shell
systemctl disable dnsmasq
```

手动编辑并添加下列服务：`mobian-ssh-keygen.service`，置于`bin_sh_service/`，需要手动复制到`/etc/systemd/system/`再启用。

### 网络配置

添加下列网络配置（配置文件同样来自苏苏小亮亮，有修改，置于`configure_files/`，安装到`/etc/NetworkManager/system-connections/`，权限改为600）：`bridge.nmconnection`，`modem.nmconnection`，`usb.nmconnection`，`wifi.nmconnection`。

### 安装openstick-utils

安装`openstick-utils`，它包含adbd、gc以及相关的服务。该软件是openstick项目提供的，需要手动安装，现置于deb/目录下，或者见[github.com/hyx0329/openstick-failsafe-guard](https://github.com/hyx0329/openstick-failsafe-guard)。

### 杂项

如果要修改hostname，还需要更改`hosts`和`/etc/hostname`。

重新配置语言为中文：`dpkg-reconfigure locales`。

最好再设置一个非空的密码，然后修改`/etc/ssh/sshd_config`的`PermitRootLogin`，防止ssh无法登录。

### 安装固件与内核

随后，安装firmware。firmware可手动从备份镜像中提取，也可以直接安装其他人打包好的deb包。

注意，固件必须在内核之前安装。

最后安装内核。要注意的是，linux内核的两个包必须用`dpkg -i`安装，否则不会生成initrd.img(也不一定，这个很玄学，得apt和dpkg交替安装几次)。

### 生成稀疏镜像

打包好rootfs.img，建议生成稀疏镜像，体积更小。

```Shell
img2simg rootfs.img sparse_rootfs.img
```
