# xmonad-cfg

[xmonad](https://hackage.haskell.org/package/xmonad) + [xmobar](https://hackage.haskell.org/package/xmobar) at solarized dark theme \w tabs and hoOkers

## depends

```bash
# xmonad
sudo apt install xmonad libghc-xmonad-dev libghc-xmonad-contrib-dev
# xmobar + fonts
sudo apt install xmobar xfonts-terminus fonts-font-awesome
# dmenu
# from repo
sudo apt install suckless-tools
# or from git
git clone http://git.suckless.org/dmenu/ && cd dmenu && sudo make install clean
```

## install

```bash
cd ~
git clone https://github.com/qbbr/xmonad-cfg.git .xmonad
echo "xmonad" >> .xinitrc
startx
```

## screenshots

[![qbbr-xmonad](https://i.imgur.com/cFNee1El.png)](https://i.imgur.com/cFNee1E.png)

## links

 * [Haskell](https://wiki.haskell.org/Haskell)
 * [Xmonad](https://wiki.haskell.org/Xmonad)
 * [dmenu](https://tools.suckless.org/dmenu/)
