#!/bin/bash
cpdomain=``
clear
while [ 1=1 ]
do
clear
	echo "Please enter the domain name:"
	read -p "(For example: www.5233.xin):" cpdomain
    echo "The domain is $cpdomain"
	if [ "$cpdomain" != "" ]; then
			echo "Billing Domain："$cpdomain
			break
	else
		if [ "$cpdomain" = "" ]; then
:<<EOF
			echo ""
            echo "========================================"
            echo "Domain name cannot be empty, please re-enter!"
            echo "========================================"
            echo ""
EOF
			continue
		fi
	fi
done

#<!-- 创建主控制台路径 -->
mkdir /home
mkdir /home/rsbilling
chmod 777 /home/rsbilling

#<!-- 关闭SELINUX -->
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

#<!-- 安装常用工具 -->
yum install wget curl gzexe net-tools.x86_64 -y

#<!-- 启动防火墙 -->
systemctl start firewalld
firewall-cmd --zone=public --add-port=22/tcp --permanent
firewall-cmd --zone=public --add-port=80/tcp --permanent
systemctl restart firewalld
systemctl enable firewalld


#<!-- 安装数据库 -->
yum install mariadb mariadb-server -y
systemctl start mariadb
systemctl stop mariadb
systemctl restart mariadb
systemctl enable mariadb
systemctl restart mariadb.service

#<!-- 随机生成mysql密码 -->
MySQLPassword=`cat /dev/urandom | head -n 16 | sha256sum | head -c 64`

#<!-- 设置数据库密码 -->
yum -y install expect -y
expect <<EOF
    spawn mysql_secure_installation
    expect {
"*none):*" {
send "\r";
exp_continue
}
"*Y/n*" {
send "y\r";
exp_continue
}
"*pass*" {
send "$MySQLPassword\r";
exp_continue
}
"*Y/n*" {
send "y\r";
exp_continue
}
}
EOF

#<!-- 创建主控数据库 rsbilling -->
mysql -uroot -p$MySQLPassword -e "create database rsbilling"

#<!-- 修改Linux限制打开文件数 -->
/usr/bin/echo "root soft nofile 65535" >>/etc/security/limits.conf
/usr/bin/echo "root hard nofile 65535" >>/etc/security/limits.conf
/usr/bin/echo "* soft nofile 65535" >>/etc/security/limits.conf
/usr/bin/echo "* hard nofile 65535" >>/etc/security/limits.conf
/usr/bin/echo '* soft nproc 65535' >> /etc/security/limits.conf
/usr/bin/echo '* hard nproc 65535' >> /etc/security/limits.conf
/usr/bin/echo '* soft nofile 65535' >> /etc/security/limits.conf
/usr/bin/echo '* hard nofile 65535' >> /etc/security/limits.conf

#<!-- 下载主控 -->
rm -rf rsbilling.tar.gz
wget http://www.rstack.com.cn/download/billing/rsbilling.tar.gz
tar zxvf rsbilling.tar.gz -C /home/rsbilling
chmod -R 777 /home/rsbilling/

#<!-- 设置全部插件目录 和 主程序的执行权限 -->
chmod +x /home/rsbilling/rsbilling
chmod +x /home/rsbilling/bin *

#<!-- 将样本配置文件sample.app.conf文件重命名app.conf -->
rm -rf /home/rsbilling/conf/app.conf
mv /home/rsbilling/conf/sample.app.conf /home/rsbilling/conf/app.conf

#<!-- 替换配置文件域名 -->
sed -i 's/192.168.1.23/'$cpdomain'/g' /home/rsbilling/conf/app.conf

#<!-- 替换enKey登录秘钥&&共享API秘钥 -->
random64=`cat /dev/urandom | head -n 16 | sha256sum | head -c 64`
sed -i 's/enKey123456/'$random64'/g' /home/rsbilling/conf/app.conf

#<!-- 替换MySQL配置文件中密码 -->
sed -i 's/root123/'$MySQLPassword'/g' /home/rsbilling/conf/app.conf

#<!-- 导入SQL -->
mysql -uroot -p$MySQLPassword rsbilling < /home/rsbilling/static/sql/rsbilling.sql


#<!-- 开机自启动系统 -->
#<!-- 必须先切换到目录在执行自启动 -->
cd /home/rsbilling/
/home/rsbilling/rsbilling autostart

#<!-- 添加计划任务 -->

/home/rsbilling/rsbilling domain=$cpdomain

#<!-- 启动主控 -->
pkill rsbilling && check-rstack-billing

#<!-- 更新/同步时间 -->
yum install -y rdate
timedatectl set-timezone Asia/Shanghai
rdate -s time.nist.gov
hwclock --systohc
yum -y install ntp
timedatectl set-ntp true

echo "----------------------------------------------------"
echo "真棒！您已成功安装rsBilling云财务系统"
echo "网站地址：http://$cpdomain/"
echo "默认账号：rsadmin"
echo "默认密码：rsadmin"
echo "后台密码：rsadmin"
echo "请尽快修改密码！"
echo "优质云服务器：:http://west2cloud.cn/ && 网络站长交流群:255192313"
echo "----------------------------------------------------"