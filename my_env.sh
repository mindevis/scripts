#!/bin/bash

check_packages() {
    echo "Update apt sources list"
    apt update -y
    echo "Upgrade system"
    apt upgrade -y

    for i in zsh curl wget neovim git; do
        if [[ ! $(dpkg -l | grep -w $i | awk '{print $1}') == 'ii' ]]; then
            echo "Installing package $i"
            apt install $i -y
        else
            echo "Package $i installed on your system"
        fi
    done
}

if [[ ! $USER == root ]]; then
    sudo apt install -y zsh curl wget neovim git
    sudo chsh -s "$(which zsh)" "$USER"

    if [[ ! -d /home/$USER/.oh-my-zsh ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        
    fi

    if [[ ! -d /home/$USER/.oh-my-zsh/custom/themes/powerlevel10k ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    fi

    sed -i 's/robbyrussell/powerlevel10k\/powerlevel10k/g' ~/.zshrc
else
    check_packages

    echo "Setup neovim"
    $(which update-alternatives) --remove-all vim
    $(which update-alternatives) --install /usr/bin/vim vim "$(which nvim)" 30

    chsh -s "$(which zsh)" root

    if [[ ! -d /root/.oh-my-zsh ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    if [[ ! -d /root/.oh-my-zsh/custom/themes/powerlevel10k ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    fi

    sed -i 's/robbyrussell/powerlevel10k\/powerlevel10k/g' ~/.zshrc
fi
