## 刷机

构建好内核以及rootfs之后就可以刷机了。

首先给emmc刷写新的分区表以及bootloader、固件等，这一步直接使用Openstick的base-generic.zip中的flash.bat即可。运行前把fsc.bin、fsg.bin、modemst1.bin、modemst2.bin换成你自己用Qualcomm Premium Tool从棒子里面提取的。

然后刷写boot.img和rootfs.img：

```Shell
fastboot flash boot boot.img
fastboot -S 200m flash rootfs sparse_rootfs.img
```

刷机后，如果设备管理器中只有一个`Android ADB Interface`，并且adb和usb网络都没有，可以尝试右键该设备更新驱动为`USB Composite Device`，然后拔插设备。再次插入设备后，应该能识别adb，并且`设备管理器->其他设备`里面应该有个未知设备，将它的驱动更新为`网络适配器->Microsoft->基于远程NDIS的Internet共享设备`即可连接到设备的usb共享网络。

刷写后，如果`df -h`发现`/dev/mmcblk0pXX`大小与emmc剩余空间不一致，可使用`resize2fs`命令扩容，例如：

```Shell
resize2fs /dev/mmcblk0p14
```

后续如果需要再次刷写新的debian镜像，只需要重新刷boot.img和rootfs.img。

如果启动后使用apt安装软件报错`Certificate verification failed: The certificate is NOT trusted. The certificate chain uses not yet valid certificate.  Could not handshake: Error in the certificate verification.`，可能是因为系统时间不正确，需要手动校准或者开启自动同步：

```Shell
sudo date -s "2026-10-20 14:30:00"
```
