### Appimage Icon

```bash
wget https://github.com/TheAssassin/AppImageLauncher/releases/download/v2.2.0/appimagelauncher_2.2.0-travis995.0f91801.bionic_amd64.deb -O /tmp/appimagelauncher.deb
sudo dpkg -i /tmp/appimagelauncher.deb
```

create symlink to start from command line 


```bash
ln -s ~/Applications/clash ~/bin/clash
ln -s ~/Applications/obsidian ~/bin/obsidian
```

note that the following should be in `~/.zshrc`

```bash
export PATH="$HOME/bin:$PATH"
```
