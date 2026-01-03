# Set Ghostty as default terminal emulator for Nemo
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[7/11]${PINK} ==> Set Ghostty as the default terminal emulator for Nemo\n---------------------------------------------------------------------\n${WHITE}"
# 检查是否有 Nemo 和 Ghostty
if command -v gsettings &> /dev/null && command -v ghostty &> /dev/null; then
    gsettings set org.cinnamon.desktop.default-applications.terminal exec ghostty
    echo -e "${GREEN}✓ Ghostty set as default terminal for Nemo${WHITE}"
else
    echo -e "${YELLOW}⚠️ Nemo or Ghostty not found, skipping...${WHITE}"
fi

# Apply fonts
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[8/11]${PINK} ==> Apply fonts\n---------------------------------------------------------------------\n${WHITE}"
fc-cache -fv
