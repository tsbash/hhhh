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
