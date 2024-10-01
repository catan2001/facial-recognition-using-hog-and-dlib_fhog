# Ubuntu, PetaLinux tools and Vivado Design Suite Guidelines
---

**IMPORTANT**: It is crucial to download the correct versions of **Ubuntu**, **PetaLinux-tools**, and **Vivado** to ensure compatibility. Refer to the **official documentation** for detailed information on dependencies and supported versions of these tools.

At the bottom of this document, you’ll find links to the recommended versions and official resources. However, keep in mind that these links might not always reflect the latest versions, so it’s a good idea to search for the most up-to-date releases directly on the official websites.

**Versions used for this setup**:
- **Ubuntu**: **18.04.2** – This version ensures stability and compatibility with the required toolchain.
- **Vivado**: **2019.2** – A version tailored for working with the selected hardware and PetaLinux.
- **PetaLinux-tools**: **2019.2** – This version is aligned with the Vivado suite for seamless integration and development.

## Ubuntu 18.04.4

Ubuntu is a popular, open-source Linux-based operating system known for its user-friendly interface and extensive software support. It is widely used for development and embedded systems projects, especially in hardware-related applications. Link is provided in the section **Links used**.

For installation on specific hardware, it is crucial to use the correct version of the Ubuntu operating system. In this case, **Ubuntu 18.04.2** was used. 

Support for Ubuntu, including installation guides and compatibility details for tools like **Vivado** and **PetaLinux-tools**, can be found on the **Xilinx** website. These tools are essential for FPGA development and embedded Linux deployment.

### Installation

For the installation, **Ubuntu 18.04.2** was used. Since this version is no longer officially supported, you will need to download it from the **Old-Releases** section of the Ubuntu archives.

To begin, download the **.iso** installation file for Ubuntu 18.04.2, and then use a tool like **Rufus** or a similar program to create a bootable USB drive. Once the USB is ready, boot your computer from the USB and proceed with the installation.

It is crucial to **NOT allow any automatic updates** during the installation process, ensuring the system does not upgrade to a newer version of Ubuntu. Failing to do so may cause compatibility issues with the rest of the toolchain, potentially disrupting the setup of tools like **Vivado** and **PetaLinux**.

After the installation, you can check the version of Ubuntu to verify that everything is correct. To do so use shell command 
```bash
cat /etc/lsb-release # press enter
```
The output on terminal should look like this:
```bash
name@name~$ cat /etc/lsb-release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=18.04
DISTRIB_CODENAME=bionic
DISTRIB_DESCRIPTION="Ubuntu 18.04.2 LTS"
```

Before jumping to the next stage it is advised to update your packages using next shell command in your terminal:
```bash
sudo apt-get update
```

## Vivado Design Suite 2019.2

Vivado Design Suite is a software suite for synthesis and analysis of hardware description language designs, superseding Xilinx ISE with additional features for system on a chip development and high-level synthesis. 

### Installing Prerequisites

To ensure **Vivado** is installed correctly and functions properly on **Ubuntu**, several additional packages need to be installed. These packages address compatibility issues and ensure smooth operation of the tool. Here are the steps and necessary packages:

#### 1. **Install Required Packages:**

Open a terminal and run the following commands to install the necessary dependencies:

```bash
sudo apt-get install libstdc++6:i386
sudo apt-get install libgtk2.0-0:i386
sudo apt-get install dpkg-dev:i386
sudo apt-get install libcanberra-gtk-module murrine-themes 
```

These packages are important for 32-bit compatibility and user interface components required by Vivado. Also libcanberra and murrine-themes are used for solving frequent crashes when synthesizing the design

#### 2. **Install Python Pip:**

Vivado relies on Python for some of its features. Install **pip** for Python 3 by running:

```bash
sudo apt-get install python3-pip
```

#### 3. **Install Additional Libraries:**

Some versions of Vivado require specific libraries for terminal interaction and text-based interfaces. Install the following libraries:

```bash
sudo apt-get install libtinfo5 libncurses5 libtinfo-dev
```

These libraries handle terminal functionality that Vivado depends on for some operations.

---
### Vivado Design Suite 2019.2 Download and Install

First, you need to download the Vivado Design Suite from the Xilinx website. The link can be found at the end of this document.

To install **Xilinx Unified 2019.2 Vivado** from a `.tar.gz` file on Ubuntu, follow these steps:

#### 1. **Extract the `.tar.gz` File:**
Open a terminal and navigate to the directory where the `.tar.gz` file is located. Use the following command to extract it:
```bash
tar -xvzf Xilinx_*.tar.gz
```

   This will extract the installation files into a directory.

#### 2. **Navigate to the Installer Directory:**
Once extracted, navigate to the installer directory:
```bash
cd Xilinx_*_
```

#### 3. **Run the Installer:**
Make the installer executable if necessary:
```bash
chmod +x xsetup
```

Now, run the installer:
```bash
sudo ./xsetup
```

This will launch the Xilinx Unified 2019.2 installation wizard. 
   
**NOTE**: It's important not to allow **Installation Wizard** to download newest version of Vivado!

---
#### 4. **Choose Installation Options:**
- Select **Vivado** as the product to install (you may also choose and other tools if needed). Select free version **WebPack**
- You can select either a **Web Install** (recommended for the latest updates) or **Local Install** if you have all the files locally.
- You can select what items you want to install. In this Installation following items were used:
    - [x] Design Tools
        - [x] DocNav
        - [x] Vivado Design Suite
    - [x] Install devices for Alveo and Xilinx edge acceleration platforms
    - [x] Devices for Custom Platforms
        - [x] SoCs
        - [x] 7 Series
        - [x] Ultrascale
    - [x] Engineering Sample Devices
    - [x] Installation Options
#### 5. **Agree to License Terms:**

Read and accept the license terms to proceed with the installation.

#### 6. **Select Installation Directory:**
During the installation process, you will be prompted to select the installation directory (e.g. `/tools/Xilinx`).

#### 7. **Complete the Installation:**
After selecting the appropriate packages and components (Vivado, SDK, drivers, etc.), click **Install** to complete the installation process.

#### 8. **Set Up Environment Variables:**
Once installed, you’ll need to set up environment variables so that Vivado can be accessed from the terminal. Add the following to your `.bashrc` or `.bash_profile` using Vim or other editor:
```bash
cd
vim .bashrc
source /tools/Xilinx/Vivado/2019.2/settings64.sh # paste this line and save file
```

Run the command:
```bash
source ~/.bashrc
```

#### 9. **Install Cable Drivers**
Once you setup everything, the last thing to do is to install cable drivers. To do this use following shell script:

```bash
# cd into the drivers directory
cd /tools/Xilinx/Vivado/2019.2/data/xicom/cable_drivers/lin64/install_script/install_drivers
# run the cable installer with root privileges
sudo ./install_drivers
```

#### 10. **Install Board Files**
If you want to use Zynq7000 board or other boards you will need to download them and put into Vivado install folder. 

**First clone xilinx boards github repository:**
```bash
cd ~/Downloads/
git clone https://github.com/Digilent/vivado-boards
```

**Now you can copy files into you Vivado board_files directory:**
```bash
sudo cp ~/Downloads/vivado-boards/new/board_files/* /tools/Xilinx/Vivado/2019.2/data/boards/board_files/ -r
```

**Note:** If you want to use older boards copy **vivado-boards/old/board_parts/***

#### 11. **Launch Vivado:**
You can now start Vivado by typing the following command in the terminal:
```bash
vivado
```

## Petalinux-tools 2019.2

### Introduction

PetaLinux is an embedded Linux Software Development Kit (SDK) targeting FPGA-based systemon-a-chip (SoC) designs. This guide helps the reader to familiarize with the tool enabling overall
usage of PetaLinux

---
### System Requirements
The PetaLinux tools installation requirements are:
- Minimum workstation requirements:
   - 8 GB RAM (recommended minimum for Xilinx® tools)
   - 2 GHz CPU clock or equivalent (minimum of 8 cores)
   - 100 GB free HDD space
   - Supported OS:
      - Red Hat Enterprise Workstation/Server 7.4, 7.5, 7.6 (64-bit)
      - CentOS Workstation/Server 7.4, 7.5, 7.6 (64-bit)
      - Ubuntu Linux Workstation/Server 16.04.5, 16.04.6, 18.04.1, **18.04.02** (64-bit)

You need to have root access to install the required packages mentioned in the release notes.
The PetaLinux tools need to be installed as a non-root user.
- PetaLinux requires a number of standard development tools and libraries to be installed on
your Linux host workstation. Install the libraries and tools listed in the release notes on the
host Linux.
- PetaLinux tools require that your host system /bin/sh is 'bash'.

 If you are using Ubuntu
distribution and your /bin/sh is 'dash', consult your system administrator to change your
default system shell /bin/sh with the sudo dpkg-reconfigure dash command.
Note: For package versions, refer to the PetaLinux 2019.2 Release Notes and Master Answer Record: 73296.

---
### Installing Prerequisites

First thing that you have to do is to upgrade your packages if you have not done it earlier. You can do it using shell command:

```bash
sudo apt-get update
```
After update you have to install necessary packages for PetaLinux tools to work properly. Make sure to install these packages using next shell command:

```bash    
sudo apt-get install gawk python build-essential gcc git make net-tools libncurses5-dev tftpd zlib1g-dev libssl-dev flex bison libselinux1 gnupg wget diffstat chrpath socat xterm autoconf libtool tar unzip texinfo zlib1g-dev gcc-multilib zlib1g:i386 screen pax gzip iproute2 python3 python build-essential git-core automake cpio python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint3 perl bzip2 -y
```

- NOTE: Please carefully enter all necessary packets. If there are packets that are not installed, PetaLinux could crash.

After you installed it is necessary to set bash shell as your default shell. To do so enter following command and selec **NO**:

```bash 
sudo dpkg-reconfigure dash
```
---
### **Installation**


#### 1. Create a folder for PetaLinux and copy installation file
First you have to create a folder where you want to install PetaLinux. It is advised to create a folder in you home directory and copy installer in that folder:

```bash
mkdir -p ~/petalinux/2019.2
cp petalinux-v2019.2-final-installer.run ~/petalinux/2019.2/
cd ~/petalinux/2019.2/
```

#### 2. **Install Petalinux**
Now you can proceed to install PetaLinux. You have to accept all license agreements by putting **y** in terminal. To install PetaLinux follow next shell command:

```bash
chmod +x petalinux-v2019.2-final-installer.run ~/petalinux/2019.2/
./petalinux-v2019.2-final-installer.run
```

#### 3. Set up Environment Variable
```bash
cd
vim .bashrc
source ~/petalinux/2019.2/settings.sh # paste this line and save file
```

Run the command:
```bash
source ~/.bashrc
```

#### 4. Deactivate WebTalk

```bash
petalinux-util --webtalk off
```



## Links used
- [Exercise 12: Linux on Zybo Board (VGA DMA Controller)](https://www.elektronika.ftn.uns.ac.rs/mikroracunarski-sistemi-za-rad-u-realnom-vremenu/wp-content/uploads/sites/99/2018/03/Vezba12_Instaliranje_Linux-a_na_Zybo_ploci_na_primeru_DMA_VGA.pdf)
- [Wiki.trenz Installation Guide](https://wiki.trenz-electronic.de/plugins/viewsource/viewpagesrc.action?pageId=139232257)
- [Download PetaLinux from Xilinx Website](http://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-design-tools.html)
- [Ubuntu Old-Releases](http://old-releases.ubuntu.com/releases/18.04.4/)
- [Ubuntu 18.04.4 Old-Releases](http://old-releases.ubuntu.com/releases/18.04.4/ubuntu-18.04.4-desktop-amd64.iso)
- [PetaLinux Tools Documentation-Reference Guide v2020.2](https://docs.amd.com/viewer/book-attachment/lI01EuQRZ2mtXOLWWVbmSA/vC~8fZCKf~Sqd7uqfK1LRA)
- [PetaLinux 2020.2/3 - Product Update Release Notes and Known Issues](https://adaptivesupport.amd.com/s/article/75775?language=en_US)
- [Vivado Design Suite User Guide](https://docs.amd.com/viewer/book-attachment/8o7OvxKMnG4NMFMc7SYHUA/p_iDDvNiuAkoje4cW6tJNw)
- [Vivado Design Suite 2020.2 Xilinx All OS installer](https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2020.2_1118_1232.tar.gz)

