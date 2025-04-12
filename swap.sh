#!/bin/bash
function set_swap() {
    read -p "请输入SWAP大小（单位：GB）: " swap_size

    if [[ ! $swap_size =~ ^[0-9]+$ ]]; then
        echo "无效的输入，请输入一个有效的数字"
        return
    fi

    if [[ -f /etc/fstab ]]; then
        sudo sed -i '/swap/d' /etc/fstab
        sudo swapoff -a

        if [[ -f /swapfile ]]; then
            sudo rm /swapfile
        fi

        sudo fallocate -l ${swap_size}G /swapfile
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile

        echo "/swapfile swap swap defaults 0 0" | sudo tee -a /etc/fstab
        echo "SWAP已设置为 ${swap_size}GB"
        echo "SWAP设置已添加到 /etc/fstab，将在系统启动时自动启用"
    else
        echo "无法找到fstab文件"
    fi
}
#!/bin/bash

#版权©West2Cloud

#关闭SWAP
function disable_swap() {
    if [[ -f /etc/fstab ]]; then
        sudo sed -i '/swap/d' /etc/fstab
        sudo swapoff -a
        echo "SWAP已关闭"
    else
        echo "无法找到fstab文件"
    fi
}

#设置SWAP
function set_swap() {
    read -p "请输入SWAP大小（单位：GB）: " swap_size

    if [[ ! $swap_size =~ ^[0-9]+$ ]]; then
        echo "无效的输入，请输入一个有效的数字"
        return
    fi

    if [[ -f /etc/fstab ]]; then
        sudo sed -i '/swap/d' /etc/fstab
        sudo swapoff -a

        if [[ -f /swapfile ]]; then
            sudo rm /swapfile
        fi

        sudo fallocate -l ${swap_size}G /swapfile
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile

        echo "/swapfile swap swap defaults 0 0" | sudo tee -a /etc/fstab
        echo "SWAP已设置为 ${swap_size}GB"
        echo "SWAP设置已添加到 /etc/fstab，将在系统启动时自动启用"
    else
        echo "无法找到fstab文件"
    fi
}

# 主菜单
while true
do
    clear
    echo "=== SWAP管理菜单 ==="
    echo "1. 一键自定义设置SWAP虚拟内存"
    echo "2. 一键关闭SWAP虚拟内存"
    echo "q. 退出"
    echo "===================="
    read -p "请输入选项: " choice
    case $choice in
        1) set_swap ;;
        2) disable_swap ;;
        q) 
            echo "See you！"
            exit 0
            ;;
        *)
            echo "无效的选项，请重新输入"
            ;;
    esac
    read -p "按回车键继续..."
done
