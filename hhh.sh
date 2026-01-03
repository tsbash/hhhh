#!/usr/bin/env bash
set -euo pipefail

# Variables
#----------------------------

# time variable
start=$(date +%s)

# Color variables
PINK="\e[35m"
WHITE="\e[0m"
YELLOW="\e[33m"
GREEN="\e[32m"
BLUE="\e[34m"


clear

# Welcome message
echo -e "${PINK}\e[1m
 欢迎使用!${PINK} 现在将在基于 Arch 的系统上安装和设置 Hyprland
                       由 \e[1;4mPhunt_Vieg_ 创建
${WHITE}"

# Warning message
echo -e "${PINK}
 *********************************************************************
 *                         ⚠️  \e[1;4m警告\e[0m${PINK}:                              *
 *               此脚本将修改您的系统配置!                *
 *         它将安装 Hyprland 和多个依赖包。        *
 *      请在继续之前确认您知道自己在做什么。     *
 *********************************************************************
\n
"

# Asking if the user want to proceed
echo -e "${YELLOW} 您确定要继续使用此脚本安装 Hyprland 吗？ [y/N]: \n"
read -r confirm
case "$confirm" in
    [yY][eE][sS]|[yY])
        echo -e "\n${GREEN}[确定]${PINK} ==> 继续安装..."
        ;;
    *)
        echo -e "${BLUE}[提示]${PINK} ==> 您 🫵 选择了 ${YELLOW}不继续${PINK}.. 正在退出..."
        echo
        exit 1
        ;;
esac

# Start of the install procedure
cd ~

# Full system update
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[1/11]${PINK} ==> 正在更新系统软件包\n---------------------------------------------------------------------\n${WHITE}"
sudo pacman -Syu --noconfirm

# Launch auto-setup script and download all the dotfiles (使用国内镜像)
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[2/11]${PINK} ==> 设置终端\n---------------------------------------------------------------------\n${WHITE}"
sleep 0.5
bash -c "$(curl -fSL https://ghproxy.com/https://raw.githubusercontent.com/ViegPhunt/auto-setup-LT/main/arch.sh)"

# Making all the scripts executable
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[3/11]${PINK} ==> 设置脚本可执行权限\n---------------------------------------------------------------------\n${WHITE}"
sudo chmod +x ~/dotfiles/.config/viegphunt/*

# Download & move the wallpapers to the right directory (使用国内镜像)
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[4/11]${PINK} ==> 下载壁纸\n---------------------------------------------------------------------\n${WHITE}"
git clone --depth 1 https://ghproxy.com/https://github.com/ViegPhunt/Wallpaper-Collection.git ~/Wallpaper-Collection
mkdir -p ~/Pictures/Wallpapers
mv ~/Wallpaper-Collection/Wallpapers/* ~/Pictures/Wallpapers
rm -rf ~/Wallpaper-Collection

# Install the required packages
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[5/11]${PINK} ==> 安装软件包\n---------------------------------------------------------------------\n${WHITE}"
sleep 0.5
~/dotfiles/.config/viegphunt/install_archpkg.sh

# Enable bluetooth & networkmanager
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[6/11]${PINK} ==> 启用蓝牙和网络管理器\n---------------------------------------------------------------------\n${WHITE}"
sleep 0.5
sudo systemctl enable --now bluetooth
sudo systemctl enable --now NetworkManager

# Set Ghostty as default terminal emulator for Nemo
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[7/11]${PINK} ==> 为 Nemo 设置 Ghostty 为默认终端\n---------------------------------------------------------------------\n${WHITE}"
gsettings set org.cinnamon.desktop.default-applications.terminal exec ghostty

# Apply fonts
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[8/11]${PINK} ==> 应用字体\n---------------------------------------------------------------------\n${WHITE}"
fc-cache -fv

# Set cursor
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[9/11]${PINK} ==> 设置鼠标指针\n---------------------------------------------------------------------\n${WHITE}"
~/dotfiles/.config/viegphunt/setcursor.sh

# Stow
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[10/11]${PINK} ==> 部署配置文件\n---------------------------------------------------------------------\n${WHITE}"
cd ~/dotfiles
stow -t ~ .
cd ~

# Check display manager
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[11/11]${PINK} ==> 检查显示管理器\n---------------------------------------------------------------------\n${WHITE}"
if [[ ! -e /etc/systemd/system/display-manager.service ]]; then
    sudo systemctl enable sddm
    echo -e "[Theme]\nCurrent=sddm-astronaut-theme" | sudo tee -a /etc/sddm.conf
    sudo sed -i 's|astronaut.conf|purple_leaves.conf|' /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
    echo -e "\n${PINK}SDDM 已启用。"
fi

# Wait a little just for the last message
sleep 0.7
clear

# Calculate how long the script took
end=$(date +%s)
duration=$((end - start))

hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))

printf -v minutes "%02d" "$minutes"
printf -v seconds "%02d" "$seconds"

echo -e "\n
 *********************************************************************
 *                    Hyprland 设置完成！                    *
 *                                                                   *
 *             耗时 : $hours 小时, $minutes 分钟, $seconds 秒            *
 *                                                                   *
 *   建议 \e[1;4m重启\e[0m 系统以应用所有更改。   *
 *                                                                   *
 *                  \e[4m祝您使用 Hyprland 愉快！${WHITE}                 *
 *********************************************************************
 \n
"
