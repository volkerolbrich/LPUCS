
#  Linux Power Utils Collection Script (LPUCS)

This is a simple Script Collection of Powersaving Tools and Scripts for Linux Mashines.

Due to my work on Linux in Proxmox Envireoments, and the Proxmox Helper Scripts ( https://community-scripts.github.io/ProxmoxVE/ ), this is exclusive for Debian Based, Ubuntu and Alpine Linux.

Inspire throu the last Hardware Haven Youtube Video and Wolfgangs Python Script:

https://www.youtube.com/watch?v=QbScWkdcMU8&t=8s

https://www.youtube.com/@WolfgangsChannel

https://github.com/notthebee




## Authors

- [@volkerolbrich](https://www.github.com/volkerolbrich)

- my loved Muse: EMMA,my quaantum Girlfriend


## Badges

Add badges from somewhere like: [shields.io](https://shields.io/)


[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)



## Contributing

Contributions are always welcome!

Feel free to contact me if you have any Ideas.

Please adhere to this project's `code of conduct`.


## Run Locally

Clone the project

```bash
  git clone https://github.com/volkerolbrich/LPUCS
```

Go to the project directory

```bash
  cd LPUCS
 
  chmod +x LPUCS_v6_2.sh

  ./LPUCS_v6_2.sh
```

or, if you don´t want to clone the whole repo, just be lazy

```bash
  nano LPUCS_v6_2.sh
```
copy paste the script from here, save the file

and then:


```bash
 chmod +x LPUCS_v6_2.sh

  ./LPUCS_v6_2.sh
```

The tool schould find out all dependencies that are missing and install them.

This is still Beta, and don´t run perfect, specially on Proxmox VE and Open Media Vault. This Products uses there own package managment.

So pay attention and know what you are doing!

They use own kind of Powermangmant, here is as well: know what you install and run as well!

---------------------------------------------------

And finally, another important point for me:

Don't just install any scripts from the internet, preferably as root, without checking them first!

This seems to be a new trend in the home lab bubble, which I already considered highly questionable when the first Proxmox helper scripts appeared.
So please take the time to check the scripts you install, and preferably run them as root!
You don't have to know exactly what's going on there, but if the script, for example, contains encrypted passwords or parts or reloads them, you should at least be cautious.

And no, this isn't meant to be a diss against, for example, the helper scripts. I also like to use them regularly, but I do check them first...



## Roadmap

- better usabillity if you are running this as root or other user, to find out if we need to sudo all commands or not. Better detection, display and reloading of missing packages and repositories

- better funktionality with proxmox pve

- testing and corrections for alpine linux

. 

## 🚀 About Me
First tryouts in Coding since Kixtart Script in NT4.0 or c64 Assembler...



![Logo](https://i.postimg.cc/c4Cb5KVn/E-G-A-logo-with-the-text-E-G-A-prominently-displayed.jpg)


## Support

For support, i could not help you out, get in contact with the original supplier of the used Toosl like:

https://github.com/AdnanHodzic/auto-cpufreq

https://github.com/rickysarraf/laptop-mode-tools

https://github.com/notthebee/AutoASPM

https://github.com/fenrus75/powertop


https://linrunner.de/tlp/index.html

