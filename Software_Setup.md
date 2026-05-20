### Appimage Icon

```bash
wget https://github.com/TheAssassin/AppImageLauncher/releases/download/v2.2.0/appimagelauncher_2.2.0-travis995.0f91801.bionic_amd64.deb -O /tmp/appimagelauncher.deb
sudo dpkg -i /tmp/appimagelauncher.deb
```

Create symlinks to start from command line (ensure `~/bin` exists):

```bash
mkdir -p ~/bin
ln -s ~/Applications/clash ~/bin/clash
ln -s ~/Applications/obsidian ~/bin/obsidian
```

`~/bin` is already on PATH via `.zshrc`.
