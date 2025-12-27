#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# CN Network Compatibility Layer（只改网络，不改行为）
# =========================================================

# GitHub / Raw 透明代理（不影响仓库内容）
git config --global url."https://ghproxy.com/https://github.com/".insteadOf https://github.com/
git config --global url."https://ghproxy.com/https://raw.githubusercontent.com/".insteadOf https://raw.githubusercontent.com/

# Go 国内代理（不改版本、不改依赖）
export GOPROXY=https://goproxy.cn,direct
export GO111MODULE=on
export GOSUMDB=off

# 清理 yay 残留（防止 clone 冲突）
rm -rf ~/yay

# =========================================================
# 原脚本内容（等价执行）
# =========================================================

start=$(date +%s)

PINK="\e[35m"
WHITE="\e[0m"
YELLOW="\e[33m"
GREEN="\e[32m"
BLUE="\e[34m"

clear

echo -e "${PINK}\e[1m
 WELCOME!${PINK} Now we will install and setup Hyprland on an Arch-based system
                       Created by \e[1;4mPhunt_Vieg_
${WHITE}"

echo -e "${PINK}
 *********************************************************************
 *                         ⚠️  \e[1;4mWARNING\e[0m${PINK}:                              *
 *               This script will modify your system!                *
 *         It will install Hyprland and several dependencies.        *
 *      Make sure you know what you are doing before continuing.     *
 *********************************************************************
\n
"

echo -e "${YELLOW} Do you still want to continue with Hyprland installation using this script? [y/N]: \n"
read -r confirm
case "$confirm" in
    [yY][eE][sS]|[yY])
        echo -e "\n${GREEN}[OK]${PINK} ==> Continuing with installation..."
        ;;
    *)
        echo -e "${BLUE}[NOTE]${PINK} ==> You chose NOT to proceed.. Exiting..."
        exit 1
        ;;
esac

cd ~

# ---------------------------------------------------------
# [1/11] Full system update
# ---------------------------------------------------------
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[1/11]${PINK} ==> Updating system packages\n---------------------------------------------------------------------\n${WHITE}"
sudo pacman -Syu --noconfirm

# ---------------------------------------------------------
# [2/11] Setup terminal & dotfiles（仅换下载入口）
# ---------------------------------------------------------
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[2/11]${PINK} ==> Setup terminal\n---------------------------------------------------------------------\n${WHITE}"
sleep 0.5
bash -c "$(curl -fSL https://ghproxy.com/https://raw.githubusercontent.com/ViegPhunt/auto-setup-LT/main/arch.sh)"

# ---------------------------------------------------------
# [3/11] Make executable
# ---------------------------------------------------------
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[3/11]${PINK} ==> Make executable\n---------------------------------------------------------------------\n${WHITE}"
chmod +x ~/dotfiles/.config/viegphunt/*

# ---------------------------------------------------------
# [4/11] Download wallpapers
# ---------------------------------------------------------
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[4/11]${PINK} ==> Download wallpaper\n---------------------------------------------------------------------\n${WHITE}"
git clone --depth 1 https://github.com/ViegPhunt/Wallpaper-Collection.git ~/Wallpaper-Collection
mkdir -p ~/Pictures/Wallpapers
mv ~/Wallpaper-Collection/Wallpapers/* ~/Pictures/Wallpapers
rm -rf ~/Wallpaper-Collection

# ---------------------------------------------------------
# [5/11] Install required packages（原样执行）
# ---------------------------------------------------------
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[5/11]${PINK} ==> Install package\n---------------------------------------------------------------------\n${WHITE}"
sleep 0.5
bash ~/dotfiles/.config/viegphunt/install_archpkg.sh

# ---------------------------------------------------------
# [6/11] Enable services
# ---------------------------------------------------------
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[6/11]${PINK} ==> Enable bluetooth & networkmanager\n---------------------------------------------------------------------\n${WHITE}"
sudo systemctl enable --now bluetooth
sudo systemctl enable --now NetworkManager

# ---------------------------------------------------------
# [7/11] Default terminal
# ---------------------------------------------------------
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[7/11]${PINK} ==> Set Ghostty as default terminal\n---------------------------------------------------------------------\n${WHITE}"
gsettings set org.cinnamon.desktop.default-applications.terminal exec ghostty || true

# ---------------------------------------------------------
# [8/11] Fonts
# ---------------------------------------------------------
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[8/11]${PINK} ==> Apply fonts\n---------------------------------------------------------------------\n${WHITE}"
fc-cache -fv

# ---------------------------------------------------------
# [9/11] Cursor
# ---------------------------------------------------------
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[9/11]${PINK} ==> Set cursor\n---------------------------------------------------------------------\n${WHITE}"
bash ~/dotfiles/.config/viegphunt/setcursor.sh

# ---------------------------------------------------------
# [10/11] Stow dotfiles
# ---------------------------------------------------------
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[10/11]${PINK} ==> Stow dotfiles\n---------------------------------------------------------------------\n${WHITE}"
cd ~/dotfiles
stow -t ~ .
cd ~

# ---------------------------------------------------------
# [11/11] Display manager
# ---------------------------------------------------------
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[11/11]${PINK} ==> Check display manager\n---------------------------------------------------------------------\n${WHITE}"
if [[ ! -e /etc/systemd/system/display-manager.service ]]; then
    sudo systemctl enable sddm
    echo -e "[Theme]\nCurrent=sddm-astronaut-theme" | sudo tee -a /etc/sddm.conf
    sudo sed -i 's|astronaut.conf|purple_leaves.conf|' /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
fi

# ---------------------------------------------------------
# Finish
# ---------------------------------------------------------
end=$(date +%s)
duration=$((end - start))

echo -e "\n${GREEN}
 *********************************************************************
 *                    Hyprland setup is complete!                    *
 *             Duration : ${duration} seconds                         *
 *        Reboot is recommended to apply all changes.                *
 *********************************************************************
${WHITE}
"
