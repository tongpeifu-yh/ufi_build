# 注意事项
## 1、固件（firmware）
一般固件在modem.img中，但现在发现大多在NON-HLOS.bin中，使用7-zip打开或者mount挂载（该文件本质为fat raw格式镜像），将image文件夹下的文件复制到/lib/firmware即可。  
wlan、qcom固件在/system/etc/firmware下，到安卓备份的system.img中的etc文件夹下面找。但是wlan固件文件仅是软链接，需要安卓启动之后获取root权限到真正目录下找到。venus固件需要放对位置，qcom/venus-1.8/下，不可更改
建议直接安装网上制作好的deb包

## 2、提取dts
dtb不在boot.img中，而是在recovery.img中  
来自chatgpt的可用方法:  
尝试使用 binwalk 工具结合手动提取的方法。下面是一种可能的步骤：
### (1) 安装 binwalk 与 Device Tree Compiler：
在大多数 Linux 系统中，你可以使用包管理器安装 binwalk 与 Device Tree Compiler ：
```
sudo apt-get install binwalk
sudo apt-get install device-tree-compiler
```
### (2) 使用 binwalk 分析 recovery.img：
运行 binwalk 分析 recovery.img，看看它是否能够识别其中的文件系统。
```
binwalk recovery.img
```
查找输出中的可能的文件系统。你可能会看到一些可能的文件系统类型，比如 SquashFS、ext4 等。
### (3) 选择一个设备树的偏移量和大小,使用 dd 命令提取设备树二进制文件：
例如，选择 Flattened device tree, size: 162799 bytes, version: 17 对应的条目，它的偏移量是 6955008（0x6A2000），大小是 162799 字节。
```
dd if=recovery.img bs=1 skip=6955008 count=162799 of=device_tree.dtb
```
### (4) 将 .dtb 转换为 DTS：
```
dtc -I dtb -O dts -o output.dts device_tree.dtb
```
