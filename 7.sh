# Install the required packages
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[5/11]${PINK} ==> Install package\n---------------------------------------------------------------------\n${WHITE}"
sleep 0.5

# 先安装必要的依赖
sudo pacman -S --needed --noconfirm git curl wget base-devel

# 运行安装脚本
if [ -f ~/dotfiles/.config/viegphunt/install_archpkg.sh ]; then
    ~/dotfiles/.config/viegphunt/install_archpkg.sh
else
    echo -e "${YELLOW}[WARNING]${WHITE} Package installation script not found, installing basic packages...\n"
    # 安装 Hyprland 基础包
    sudo pacman -S --needed --noconfirm hyprland waybar rofi alacritty
fi

# enable bluetooth & networkmanager
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[6/11]${PINK} ==> Enable bluetooth & networkmanager\n---------------------------------------------------------------------\n${WHITE}"
sleep 0.5
sudo systemctl enable --now bluetooth
sudo systemctl enable --now NetworkManager
