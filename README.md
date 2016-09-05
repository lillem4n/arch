# Arch + i3 install

This repo contains basic instructions and shortcut scripts to install and configure Arch Linux and i3 for my personal needs. They should with small tweaks be able to be used by anyone.

**WARNING! The scripts and instructions here will overwrite your disk(s)!!!**

1)  boot from arch linux live media  
2)  setup network (use wifi-menu if only wifi is available)  
3) run "loadkeys sv-latin1" if Swedish keyboard is wanted  
4) partition disk  
5) download and run install scripts:  

```bash
wget https://raw.githubusercontent.com/lillem4n/arch/master/arch_install.sh;
wget https://raw.githubusercontent.com/lillem4n/arch/master/arch_install2.sh;
chmod +x arch_install.sh arch_install2.sh;
./arch_install.sh;
```
