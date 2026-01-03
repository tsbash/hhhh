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

# 国内镜像源配置
GITHUB_MIRROR="https://ghproxy.com/https://github.com"
RAW_MIRROR="https://ghproxy.com/https://raw.githubusercontent.com"
GITHUB_MIRROR_ALT="https://github.com.cnpmjs.org"
RAW_MIRROR_ALT="https://raw.fastgit.org"

clear

# Welcome message
echo -e "${PINK}\e[1m
 WELCOME!${PINK} Now we will install and setup Hyprland on an Arch-based system
                       Created by \e[1;4mPhunt_Vieg_
${WHITE}"

# Warning message
echo -e "${PINK}
 *********************************************************************
 *                         ⚠️  \e[1;4mWARNING\e[0m${PINK}:                              *
 *               This script will modify your system!                *
 *         It will install Hyprland and several dependencies.        *
 *      Make sure you know what you are doing before continuing.     *
 *********************************************************************
\n
"

# 检查网络连接
echo -e "${YELLOW}Checking network connectivity to GitHub mirror...${WHITE}"
if curl -s --connect-timeout 5 "${RAW_MIRROR}" > /dev/null; then
    echo -e "${GREEN}✓ GitHub mirror is accessible${WHITE}"
else
    echo -e "${YELLOW}⚠️ Primary mirror not available, trying alternative...${WHITE}"
    RAW_MIRROR="${RAW_MIRROR_ALT}"
    GITHUB_MIRROR="${GITHUB_MIRROR_ALT}"
fi

# Asking if the user want to proceed
echo -e "${YELLOW} Do you still want to continue with Hyprland installation using this script? [y/N]: \n"
read -r confirm
case "$confirm" in
    [yY][eE][sS]|[yY])
        echo -e "\n${GREEN}[OK]${PINK} ==> Continuing with installation..."
        ;;
    *)
        echo -e "${BLUE}[NOTE]${PINK} ==> You 🫵 chose ${YELLOW}NOT${PINK} to proceed.. Exiting..."
        echo
        exit 1
        ;;
esac

# 设置 Arch Linux 国内镜像源
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[0/11]${PINK} ==> Configuring Arch Linux mirrors for China\n---------------------------------------------------------------------\n${WHITE}"
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
echo "Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch" | sudo tee /etc/pacman.d/mirrorlist
echo "Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch" | sudo tee -a /etc/pacman.d/mirrorlist
echo "Server = https://mirrors.aliyun.com/archlinux/\$repo/os/\$arch" | sudo tee -a /etc/pacman.d/mirrorlist
sudo pacman -Syy --noconfirm

# Start of the install procedure
cd ~

# Full system update
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[1/11]${PINK} ==> Updating system packages\n---------------------------------------------------------------------\n${WHITE}"
sudo pacman -Syu --noconfirm

# Lunch auto-setup script and dl all the dotfiles
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[2/11]${PINK} ==> Setup terminal\n---------------------------------------------------------------------\n${WHITE}"
sleep 0.5

echo -e "${BLUE}[INFO]${WHITE} Downloading setup script from mirror...\n"
if curl -fSL "${RAW_MIRROR}/ViegPhunt/auto-setup-LT/main/arch.sh" -o /tmp/arch_setup.sh; then
    bash /tmp/arch_setup.sh
    rm /tmp/arch_setup.sh
else
    echo -e "${YELLOW}[WARNING]${WHITE} Failed to download from mirror, trying direct download...\n"
    if curl -fSL "https://raw.githubusercontent.com/ViegPhunt/auto-setup-LT/main/arch.sh" -o /tmp/arch_setup.sh; then
        bash /tmp/arch_setup.sh
        rm /tmp/arch_setup.sh
    else
        echo -e "${PINK}[ERROR]${WHITE} Could not download setup script. Please check your network connection.\n"
        exit 1
    fi
fi

# Making all the scripts executable
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[3/11]${PINK} ==> Make executable\n---------------------------------------------------------------------\n${WHITE}"
sudo chmod +x ~/dotfiles/.config/viegphunt/*

# download & mv the wallpapers in the right directory
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[4/11]${PINK} ==> Download wallpaper\n---------------------------------------------------------------------\n${WHITE}"

if git clone --depth 1 "${GITHUB_MIRROR}/ViegPhunt/Wallpaper-Collection.git" ~/Wallpaper-Collection; then
    echo -e "${GREEN}✓ Wallpaper collection downloaded successfully${WHITE}"
else
    echo -e "${YELLOW}⚠️ Failed to download from mirror, trying direct clone...${WHITE}"
    git clone --depth 1 "https://github.com/ViegPhunt/Wallpaper-Collection.git" ~/Wallpaper-Collection
fi

mkdir -p ~/Pictures/Wallpapers
if [ -d ~/Wallpaper-Collection/Wallpapers ]; then
    mv ~/Wallpaper-Collection/Wallpapers/* ~/Pictures/Wallpapers 2>/dev/null || true
    rm -rf ~/Wallpaper-Collection
else
    echo -e "${YELLOW}[WARNING]${WHITE} Wallpaper directory not found, skipping...\n"
fi

# Install the required packages
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[5/11]${PINK} ==> Install package\n---------------------------------------------------------------------\n${WHITE}"
sleep 0.5

sudo pacman -S --needed --noconfirm git curl wget base-devel

if [ -f ~/dotfiles/.config/viegphunt/install_archpkg.sh ]; then
    ~/dotfiles/.config/viegphunt/install_archpkg.sh
else
    echo -e "${YELLOW}[WARNING]${WHITE} Package installation script not found, installing basic packages...\n"
    sudo pacman -S --needed --noconfirm hyprland waybar rofi alacritty
fi

# enable bluetooth & networkmanager
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[6/11]${PINK} ==> Enable bluetooth & networkmanager\n---------------------------------------------------------------------\n${WHITE}"
sleep 0.5
sudo systemctl enable --now bluetooth
sudo systemctl enable --now NetworkManager

# Set Ghostty as default terminal emulator for Nemo
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[7/11]${PINK} ==> Set Ghostty as the default terminal emulator for Nemo\n---------------------------------------------------------------------\n${WHITE}"
if command -v gsettings &> /dev/null && command -v ghostty &> /dev/null; then
    gsettings set org.cinnamon.desktop.default-applications.terminal exec ghostty
    echo -e "${GREEN}✓ Ghostty set as default terminal for Nemo${WHITE}"
else
    echo -e "${YELLOW}⚠️ Nemo or Ghostty not found, skipping...${WHITE}"
fi

# Apply fonts
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[8/11]${PINK} ==> Apply fonts\n---------------------------------------------------------------------\n${WHITE}"
fc-cache -fv

# Set cursor
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[9/11]${PINK} ==> Set cursor\n---------------------------------------------------------------------\n${WHITE}"
if [ -f ~/dotfiles/.config/viegphunt/setcursor.sh ]; then
    ~/dotfiles/.config/viegphunt/setcursor.sh
else
    echo -e "${YELLOW}[WARNING]${WHITE} Cursor setup script not found, skipping...\n"
fi

# Stow
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[10/11]${PINK} ==> Stow dotfiles\n---------------------------------------------------------------------\n${WHITE}"
if command -v stow &> /dev/null; then
    cd ~/dotfiles
    stow -t ~ .
    cd ~
else
    echo -e "${YELLOW}[WARNING]${WHITE} GNU Stow not installed, installing...\n"
    sudo pacman -S --noconfirm stow
    cd ~/dotfiles
    stow -t ~ .
    cd ~
fi

# Check display manager
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[11/11]${PINK} ==> Check display manager\n---------------------------------------------------------------------\n${WHITE}"
if [[ ! -e /etc/systemd/system/display-manager.service ]]; then
    sudo pacman -S --noconfirm sddm sddm-themes
    sudo systemctl enable sddm
    
    if [ -f /etc/sddm.conf ]; then
        sudo sed -i 's/^Current=.*/Current=sddm-astronaut-theme/' /etc/sddm.conf
    else
        echo -e "[Theme]\nCurrent=sddm-astronaut-theme" | sudo tee /etc/sddm.conf
    fi
    
    if [ -f /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop ]; then
        sudo sed -i 's|astronaut.conf|purple_leaves.conf|' /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
    fi
    
    echo -e "\n${PINK}SDDM has been enabled."
else
    echo -e "${BLUE}[INFO]${WHITE} Display manager already exists, skipping SDDM setup.\n"
fi

# Wait a little just for the last message
sleep 0.7
clear

# 清理临时文件
echo -e "${PINK}Cleaning up temporary files...${WHITE}"
rm -f /tmp/arch_setup.sh 2>/dev/null || true

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
 *                    Hyprland setup is complete!                    *
 *                                                                   *
 *             Duration : $hours hours, $minutes minutes, $seconds seconds            *
 *                                                                   *
 *   It is recommended to \e[1;4mREBOOT\e[0m your system to apply all changes.   *
 *                                                                   *
 *                 \e[4mHave a great time with Hyprland!!${WHITE}                 *
 *********************************************************************
 \n
"

# 最后的建议
echo -e "${BLUE}[建议]${WHITE}"
echo -e "1. 如果遇到网络问题，可以尝试配置代理"
echo -e "2. 使用国内镜像加速后续软件安装:"
echo -e "   sudo pacman-mirrors -c China"
echo -e "3. 如需 AUR 包，可以使用 yay 并设置国内镜像"
echo -e "\n"
