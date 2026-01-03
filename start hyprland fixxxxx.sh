# 检查并修复 start-hyprland 脚本
echo "检查 start-hyprland 脚本..."
if [ -f /usr/bin/start-hyprland ]; then
    echo "备份原始 start-hyprland..."
    sudo mv /usr/bin/start-hyprland /usr/bin/start-hyprland.bak
fi

# 创建新的启动器
echo "创建新的 VMware 启动器..."
sudo tee /usr/bin/start-hyprland-vmware << 'EOF'
#!/bin/bash
# VMware 专用的 Hyprland 启动器

# 清理环境
unset WAYLAND_DISPLAY
unset XDG_CURRENT_DESKTOP
unset XDG_SESSION_TYPE

# 设置 VMware 特定的环境变量
export WLR_NO_HARDWARE_CURSORS=1
export WLR_BACKENDS=vulkan
export WLR_RENDERER=vulkan
export LIBGL_ALWAYS_SOFTWARE=0
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland
export SDL_VIDEODRIVER=wayland
export CLUTTER_BACKEND=wayland
export MOZ_ENABLE_WAYLAND=1
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland

# 检查 Vulkan 支持
if ! vulkaninfo --summary 2>/dev/null | grep -q "Vulkan API"; then
    echo "警告：Vulkan 可能不支持，回退到其他渲染器"
    export WLR_RENDERER=gles2
fi

# 启动必要的 VMware 服务
if command -v vmware-user-suid-wrapper > /dev/null; then
    vmware-user-suid-wrapper &
fi

# 等待 VMware 工具初始化
sleep 0.5

# 检查用户目录
if [ ! -d ~/.config/hypr ]; then
    mkdir -p ~/.config/hypr
    echo "# 最小配置" > ~/.config/hypr/hyprland.conf
    echo "monitor=,preferred,auto,1" >> ~/.config/hypr/hyprland.conf
    echo "exec-once = /usr/lib/polkit-kde-authentication-agent-1" >> ~/.config/hypr/hyprland.conf
fi

# 启动 Hyprland
echo "启动 Hyprland..."
exec Hyprland --config ~/.config/hypr/hyprland.conf
EOF

sudo chmod +x /usr/bin/start-hyprland-vmware

# 更新 SDDM 配置使用新的启动器
echo "更新 SDDM 配置..."
if [ -f /usr/share/wayland-sessions/hyprland.desktop ]; then
    sudo sed -i 's|Exec=Hyprland|Exec=start-hyprland-vmware|' /usr/share/wayland-sessions/hyprland.desktop
fi
