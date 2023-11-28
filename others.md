# 注意事项
## 1、固件（firmware）
一般固件在modem.img中，但现在发现大多在NON-HLOS.bin中，使用7-zip打开或者mount挂载（该文件本质为fat raw格式镜像），将image文件夹下的文件复制到/lib/firmware即可。  
wlan、qcom固件在/system/etc/firmware下，到安卓备份的system.img中的etc文件夹下面找。但是wlan固件文件仅是软链接，需要安卓启动之后获取root权限到真正目录下找到。venus固件需要放对位置，qcom/venus-1.8/下，不可更改。  
建议直接安装网上制作好的deb包。  

## 2、电脑连接不上usb共享网络
非常离谱的bug，必须先安装firmware，再安装编译好的内核，否则电脑就无法识别usb rndis网络

## 3、提取dts
dtb不一定在boot.img中，而是在recovery.img中。  
HandsomeHacker大佬在[我的4g网卡运行着GNU/Linux -- 某4g无线网卡的逆向工程与主线Linux移植 (一)](https://blog.csdn.net/github_38345754/article/details/121462292) 提供的方法不一定有效，反正我是不知道`unpackbootimg`要从哪里找。  
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

## 4、gc与adbd
gc来自：<https://github.com/HandsomeMod/gc>  
adbd未知，大概可用<https://github.com/tonyho/adbd-linux>（依赖openssl1.0）或者<https://github.com/kiddlu/android-adbd-for-linux>构建？  
按照<https://github.com/hyx0329/openstick-failsafe-guard/blob/dev/bin/README.md>中的说法，[staticx](https://github.com/JonathonReinhart/staticx)可用用于转化可执行程序为静态链接

## 5、构建adbd
警告：暂时未测试是否有效！建议还是用openstick-utils里面的！  
构建<https://github.com/tonyho/adbd-linux>：  
构建好的相关文件已经打包至compiled_package/adbd.tar.gz，其中在adbd-linux目录下执行`make install`即可安装adbd，或者手动复制adb/adbd和adb/xdg-adbd两个文件到/usr/sbin，然后复制adbd.service到/usr/lib/systemd/system/后启用服务  

首先构建1.0版本openssl   
可以参照<https://blog.csdn.net/qq_32348883/article/details/123156198>  
然后手动配置include头文件位置（从默认的/usr/local/ssl/include/openssl复制到/usr/include/openssl）,再手动配置lib文件（把两个lib*.a复制到/usr/lib）  
然后编译安装adbd-linux，中间可能遇到：
### a、 sys/capability.h 没有那个文件或目录
capability.h在/usr/include/linux目录下面，在源码中把sys改为linux即可
### b、 undefined reference to 'dlxxx'
```
g++ -fPIC -O2 -g -std=c++14 -DADB_HOST=0 -Wall -Wno-unused-parameter -D_XOPEN_SOURCE -D_GNU_SOURCE -DHAVE_PTHREADS=1 -DADB_NON_ANDROID=1 -DADB_REVISION='"-android"' -DPROP_NAME_MAX=32 -DPROP_VALUE_MAX=92 -DALLOW_ADBD_NO_AUTH=1 -I../include -I../base/include/ -I../libcrypto_utils/include/ -I../adb adb.o adb_auth.o adb_utils.o adb_trace.o adb_io.o adb_listeners.o diagnose_usb.o shell_service.o shell_service_protocol.o sockets.o transport.o transport_local.o transport_usb.o log-non-android.o fdevent.o get_my_path_linux.o adb_auth_client.o services.o file_sync_service.o framebuffer_service.o remount_service.o set_verity_enable_state_service.o daemon/main.o usb_linux_client.o -L ../libcutils/*.o ../base/*.o ../libcrypto_utils/*.o -lpthread -lresolv -lcrypto -lssl -lutil -o adbd
/usr/bin/ld: /usr/lib/gcc/aarch64-linux-gnu/10/../../../../lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_globallookup':
dso_dlfcn.c:(.text+0x1c): undefined reference to `dlopen'
/usr/bin/ld: dso_dlfcn.c:(.text+0x2c): undefined reference to `dlsym'
/usr/bin/ld: dso_dlfcn.c:(.text+0x3c): undefined reference to `dlclose'
/usr/bin/ld: /usr/lib/gcc/aarch64-linux-gnu/10/../../../../lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_bind_func':
dso_dlfcn.c:(.text+0x394): undefined reference to `dlsym'
/usr/bin/ld: dso_dlfcn.c:(.text+0x450): undefined reference to `dlerror'
/usr/bin/ld: /usr/lib/gcc/aarch64-linux-gnu/10/../../../../lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_bind_var':
dso_dlfcn.c:(.text+0x4d8): undefined reference to `dlsym'
/usr/bin/ld: dso_dlfcn.c:(.text+0x590): undefined reference to `dlerror'
/usr/bin/ld: /usr/lib/gcc/aarch64-linux-gnu/10/../../../../lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_load':
dso_dlfcn.c:(.text+0x5f8): undefined reference to `dlopen'
/usr/bin/ld: dso_dlfcn.c:(.text+0x65c): undefined reference to `dlclose'
/usr/bin/ld: dso_dlfcn.c:(.text+0x694): undefined reference to `dlerror'
/usr/bin/ld: /usr/lib/gcc/aarch64-linux-gnu/10/../../../../lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_pathbyaddr':
dso_dlfcn.c:(.text+0x728): undefined reference to `dladdr'
/usr/bin/ld: dso_dlfcn.c:(.text+0x7a0): undefined reference to `dlerror'
/usr/bin/ld: /usr/lib/gcc/aarch64-linux-gnu/10/../../../../lib/libcrypto.a(dso_dlfcn.o): in function `dlfcn_unload':
dso_dlfcn.c:(.text+0x7f4): undefined reference to `dlclose'
collect2: error: ld returned 1 exit status
make[1]: *** [Makefile:84：adbd] 错误 1
make[1]: 离开目录“/root/adbd-linux/adb”
make: *** [Makefile:38：adb/adbd] 错误 2
```
原因：缺少libdl库  
解决：进入adb目录手动执行编译命令，并增加-ldl选项   
```
g++ -fPIC -O2 -g -std=c++14 -DADB_HOST=0 -Wall -Wno-unused-parameter -D_XOPEN_SOURCE -D_GNU_SOURCE -DHAVE_PTHREADS=1 -DADB_NON_ANDROID=1 -DADB_REVISION='"-android"' -DPROP_NAME_MAX=32 -DPROP_VALUE_MAX=92 -DALLOW_ADBD_NO_AUTH=1 -I../include -I../base/include/ -I../libcrypto_utils/include/ -I../adb adb.o adb_auth.o adb_utils.o adb_trace.o adb_io.o adb_listeners.o diagnose_usb.o shell_service.o shell_service_protocol.o sockets.o transport.o transport_local.o transport_usb.o log-non-android.o fdevent.o get_my_path_linux.o adb_auth_client.o services.o file_sync_service.o framebuffer_service.o remount_service.o set_verity_enable_state_service.o daemon/main.o usb_linux_client.o -L ../libcutils/*.o ../base/*.o ../libcrypto_utils/*.o -lpthread -lresolv -lcrypto -lssl -lutil -ldl -o adbd
```
### c、 glib.h: 没有那个文件或目录
```
fatal error: glib.h: 没有那个文件或目录
   17 | #include <glib.h>
```
原因：未安装glib  
解决：安装glib2.0  
```
sudo apt-get install libglib2.0-dev
```

编译后`make install`，输出   
```
install -d -m 0755 /usr/sbin
install -D -m 0755 adb/adbd /usr/sbin
install -D -m 0755 adb/xdg-adbd /usr/sbin
install -d -m 0755 /usr/lib/systemd/system/
install -D -m 0644 ./adbd.service /usr/lib/systemd/system/
```
可以看到就是复制了三个文件而已，完全可以手动安装