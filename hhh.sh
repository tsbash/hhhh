#!/usr/bin/env bash
set -euo pipefail

# 国内镜像设置
GITHUB_MIRROR="https://gitclone.com/github.com"  # 更稳定的镜像
RAW_MIRROR="https://gitclone.com/github.com/raw"  # raw文件镜像
DEFAULT_MIRROR="https://mirror.ghproxy.com"  # 备选镜像

# 主仓库配置
MAIN_REPO="ViegPhunt/Arch-Hyprland"
DOTFILES_REPO="ViegPhunt/dotfiles"
WALLPAPER_REPO="ViegPhunt/Wallpaper-Collection"

# 颜色变量
PINK="\e[35m"
WHITE="\e[0m"
YELLOW="\e[33m"
GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"

# 进度跟踪
current_step=0
total_steps=11

show_step() {
    current_step=$((current_step + 1))
    echo -e "${PINK}\n---------------------------------------------------------------------"
    echo -e "${YELLOW}[$current_step/$total_steps]${PINK} ==> $1"
    echo -e "---------------------------------------------------------------------\n${WHITE}"
}

# 下载函数（尝试多个镜像）
download_with_mirrors() {
    local url="$1"
    local output="$2"
    local mirrors=(
        "$GITHUB_MIRROR/$url"
        "$DEFAULT_MIRROR/https://github.com/$url"
        "https://kgithub.com/$url"
        "https://github.com/$url"
    )
    
    for mirror in "${mirrors[@]}"; do
        echo -e "${BLUE}[尝试]${WHITE} 从: ${mirror}"
        if curl -fSL "$mirror" -o "$output" --connect-timeout 30 2>/dev/null; then
            if [[ -s "$output" ]]; then
                echo -e "${GREEN}[成功]${WHITE} 下载完成"
                return 0
            fi
        fi
        rm -f "$output" 2>/dev/null
        sleep 1
    done
    return 1
}

# 克隆函数（尝试多个镜像）
clone_with_mirrors() {
    local repo="$1"
    local target="$2"
    local mirrors=(
        "$GITHUB_MIRROR/$repo.git"
        "$DEFAULT_MIRROR/https://github.com/$repo.git"
        "https://kgithub.com/$repo.git"
        "https://github.com/$repo.git"
    )
    
    for mirror in "${mirrors[@]}"; do
        echo -e "${BLUE}[尝试]${WHITE} 克隆: $repo"
        if git clone --depth 1 "$mirror" "$target" 2>/dev/null; then
            echo -e "${GREEN}[成功]${WHITE} 克隆完成"
            return 0
        fi
        rm -rf "$target" 2>/dev/null
        sleep 1
    done
    return 1
}

clear

echo -e "${PINK}\e[1m
    欢迎使用 Arch Linux + Hyprland 安装脚本
            基于 ViegPhunt/Arch-Hyprland 配置
               镜像适配版
${WHITE}"

echo -e "${PINK}
 *********************************************************************
 *                         ⚠️  \e[1;4m警告\e[0m${PINK}:                             *
 *               本脚本将修改您的系统配置！                *
 *        它会安装 Hyprland 及其依赖包和桌面环境配置          *
 *               请确认您知道自己在做什么！               *
 *********************************************************************
\n
"

read -p "$(echo -e "${YELLOW}是否继续安装？ [y/N]: ${WHITE}")" confirm
case "$confirm" in
    [yY][eE][sS]|[yY])
        echo -e "\n${GREEN}[OK]${PINK} ==> 继续安装...\n"
        ;;
    *)
        echo -e "${BLUE}[NOTE]${PINK} ==> 取消安装...\n"
        exit 1
        ;;
esac

# 1. 更新系统
show_step "更新系统包"
sudo pacman -Syu --noconfirm

# 2. 安装基础开发工具
show_step "安装基础工具"
sudo pacman -S --noconfirm --needed base-devel git wget curl

# 3. 克隆主仓库
show_step "克隆配置仓库"
clone_with_mirrors "$MAIN_REPO" "$HOME/Arch-Hyprland"

# 4. 克隆 dotfiles
show_step "克隆 dotfiles"
clone_with_mirrors "$DOTFILES_REPO" "$HOME/dotfiles"

# 5. 克隆壁纸
show_step "下载壁纸"
clone_with_mirrors "$WALLPAPER_REPO" "/tmp/Wallpaper-Collection"
mkdir -p ~/Pictures/Wallpapers
if [[ -d "/tmp/Wallpaper-Collection/Wallpapers" ]]; then
    mv "/tmp/Wallpaper-Collection/Wallpapers"/* ~/Pictures/Wallpapers/ 2>/dev/null
fi
rm -rf "/tmp/Wallpaper-Collection"

# 6. 设置可执行权限
show_step "设置脚本权限"
if [[ -d "$HOME/dotfiles/.config/viegphunt" ]]; then
    find "$HOME/dotfiles/.config/viegphunt" -name "*.sh" -exec chmod +x {} \;
fi

if [[ -d "$HOME/Arch-Hyprland" ]]; then
    find "$HOME/Arch-Hyprland" -name "*.sh" -exec chmod +x {} \;
fi

# 7. 安装 Hyprland 和依赖
show_step "安装 Hyprland 及依赖"

# 读取原仓库的包列表
if [[ -f "$HOME/Arch-Hyprland/packages.txt" ]]; then
    echo "从 packages.txt 安装包..."
    while IFS= read -r package || [[ -n "$package" ]]; do
        if [[ -n "$package" && ! "$package" =~ ^# ]]; then
            echo "安装: $package"
            sudo pacman -S --noconfirm --needed "$package" 2>/dev/null || true
        fi
    done < "$HOME/Arch-Hyprland/packages.txt"
else
    # 如果没有 packages.txt，安装常见包
    echo "安装常用包..."
    sudo pacman -S --noconfirm --needed \
        hyprland \
        waybar \
        rofi \
        kitty \
        firefox \
        thunar \
        neofetch \
        htop \
        network-manager-applet \
        blueman \
        pipewire \
        wireplumber \
        pavucontrol \
        brightnessctl \
        playerctl \
        wtype \
        wl-clipboard \
        grim \
        slurp \
        swappy \
        imagemagick
fi

# 8. 安装 AUR 包（如果需要）
show_step "安装 AUR 包"
if command -v yay &> /dev/null; then
    echo "yay 已安装"
elif command -v paru &> /dev/null; then
    echo "paru 已安装"
else
    echo "安装 yay..."
    sudo pacman -S --noconfirm --needed base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd ~
fi

# 尝试安装一些常用的 AUR 包
aur_packages=(
    "hyprpaper"
    "hyprpicker"
    "swaync"
    "cava"
    "nwg-look"
)

for pkg in "${aur_packages[@]}"; do
    if command -v yay &> /dev/null; then
        yay -S --noconfirm --needed "$pkg" 2>/dev/null || true
    elif command -v paru &> /dev/null; then
        paru -S --noconfirm --needed "$pkg" 2>/dev/null || true
    fi
done

# 9. 复制配置文件
show_step "复制配置文件"

# 复制 Hyprland 配置
if [[ -d "$HOME/dotfiles/.config/hypr" ]]; then
    mkdir -p ~/.config/hypr
    cp -r "$HOME/dotfiles/.config/hypr"/* ~/.config/hypr/ 2>/dev/null || true
fi

# 复制 Waybar 配置
if [[ -d "$HOME/dotfiles/.config/waybar" ]]; then
    mkdir -p ~/.config/waybar
    cp -r "$HOME/dotfiles/.config/waybar"/* ~/.config/waybar/ 2>/dev/null || true
fi

# 复制 Rofi 配置
if [[ -d "$HOME/dotfiles/.config/rofi" ]]; then
    mkdir -p ~/.config/rofi
    cp -r "$HOME/dotfiles/.config/rofi"/* ~/.config/rofi/ 2>/dev/null || true
fi

# 复制 Kitty 配置
if [[ -d "$HOME/dotfiles/.config/kitty" ]]; then
    mkdir -p ~/.config/kitty
    cp -r "$HOME/dotfiles/.config/kitty"/* ~/.config/kitty/ 2>/dev/null || true
fi

# 复制其他配置
for config_dir in "$HOME/dotfiles/.config/"*; do
    if [[ -d "$config_dir" ]]; then
        dir_name=$(basename "$config_dir")
        if [[ "$dir_name" != "viegphunt" && "$dir_name" != "archpkg" ]]; then
            mkdir -p "$HOME/.config/$dir_name"
            cp -r "$config_dir"/* "$HOME/.config/$dir_name/" 2>/dev/null || true
        fi
    fi
done

# 10. 启用服务
show_step "启用系统服务"

# 启用 NetworkManager
sudo systemctl enable --now NetworkManager 2>/dev/null || true

# 启用蓝牙
sudo systemctl enable --now bluetooth 2>/dev/null || true

# 启用 SDDM 显示管理器
if [[ ! -f /etc/systemd/system/display-manager.service ]]; then
    sudo pacman -S --noconfirm sddm sddm-themes 2>/dev/null || true
    sudo systemctl enable sddm 2>/dev/null || true
    
    # 配置 SDDM 主题
    sudo mkdir -p /etc/sddm.conf.d
    echo "[Theme]
Current=sugar-candy" | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null 2>&1
fi

# 11. 应用字体和主题
show_step "应用字体和主题"

# 更新字体缓存
fc-cache -fv 2>/dev/null || true

# 设置 GTK 主题（如果有）
if [[ -f "$HOME/.config/gtk-3.0/settings.ini" ]]; then
    gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark" 2>/dev/null || true
fi

# 设置光标主题
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface cursor-theme "Adwaita" 2>/dev/null || true
fi

# 设置默认终端
if command -v update-alternatives &> /dev/null; then
    sudo update-alternatives --set x-terminal-emulator /usr/bin/kitty 2>/dev/null || true
fi

# 完成安装
clear
echo -e "${PINK}
 *********************************************************************
 *                    Hyprland 安装完成！                    *
 *                                                                   *
 *                  安装已经成功完成！                   *
 *                                                                   *
 *         建议重启系统以应用所有更改：                              *
 *                   ${GREEN}sudo reboot${PINK}                               *
 *                                                                   *
 *        重启后，使用 SDDM 登录管理器选择 Hyprland 会话              *
 *                                                                   *
 *        常见快捷键：                                               *
 *          ${YELLOW}Super + Enter${PINK}: 打开终端                   *
 *          ${YELLOW}Super + D${PINK}: 应用启动器                     *
 *          ${YELLOW}Super + Q${PINK}: 关闭窗口                       *
 *          ${YELLOW}Super + Shift + E${PINK}: 退出 Hyprland           *
 *                                                                   *
 *                 ${GREEN}祝您使用愉快！${PINK}                         *
 *********************************************************************
${WHITE}
"

# 显示下一步建议
echo -e "${BLUE}[建议]${WHITE} 接下来您可以："
echo "1. 重启系统：sudo reboot"
echo "2. 查看配置文件：~/.config/hypr/"
echo "3. 自定义配置：编辑 ~/.config/hypr/hyprland.conf"
echo ""
echo "如需帮助，请参考："
echo "- Hyprland Wiki: https://wiki.hyprland.org"
echo "- 原仓库: https://github.com/ViegPhunt/Arch-Hyprland"
echo ""
