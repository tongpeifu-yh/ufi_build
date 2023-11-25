# 注意事项
## 1、固件（firmware）
一般固件在modem.img中，但现在发现大多在NON-HLOS.bin中，使用7-zip打开或者mount挂载（该文件本质为fat raw格式镜像），将image文件夹下的文件复制到/lib/firmware即可。  
wlan、qcom固件在/system/etc/firmware下，到安卓备份的system.img中的etc文件夹下面找
