#!/bin/bash

black="\033[30m"
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
blue="\033[34m"
purple="\033[35m"
cyan="\033[36m"
white="\033[37m"
reset="\033[0m"

echo -e "${black}开始检测操作系统${reset}"
echo -e "${red}检测失败${reset}"
echo -e "${green}开始安装wget（yum命令）${reset}"
sudo yum install wget
echo -e "${yellow}开始安装wget（apt命令）${reset}"
sudo apt install wget
echo -e "${blue}下载文件工具${reset}"
wget https://gitee.com/silly-spring-network/qita/raw/master/server_info.sh
echo -e "${purple}给执行权限${reset}"
chmod +x server_info.sh
echo -e "${cyan}开始查看服务器信息${reset}"
./server_info.sh