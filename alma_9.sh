#!/bin/bash
read -p "Are you Gilles? (y/n): " answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
    echo "Continuing installation..."
else
    echo "This script is only meant for Gilles. This script is not recommended for anyone else."
    exit 1
fi

dnf upgrade -y
dnf update

dnf config-manager --set-enabled crb
dnf update

dnf install epel-release -y
dnf upgrade -y
dnf update

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
dnf update


read -p "Install personal apps? (y/n): " answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
    flatpak install flathub com.spotify.Client
    flatpak install flathub com.discordapp.Discord
    dnf install gnome-tweak-tool -y

    rpm --import https://downloads.1password.com/linux/keys/1password.asc
    sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
    dnf install 1password -y

    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
    dnf check-update
    dnf install code -y
else
    echo "Skipping personal apps."
fi


mkdir -p ~/.ssh
touch ~/.ssh/authorized_keys
curl -s https://github.com/gillesvink.keys >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

sudo yum remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


read -p "Machine contains Nvidia GPU? (y/n): " answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
    dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/cuda-rhel9.repo
    dnf makecache
    dnf install -y kernel-devel-$(uname -r) kernel-headers-$(uname -r) gcc make dkms acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig freeglut-devel libX11-devel libXi-devel libXmu-devel make mesa-libGLU-devel freeimage-devel glfw-devel
    dnf module install nvidia-driver -y
else
    echo "Skipping Nvidia driver install."
fi


read -p "Install Nuke? (y/n): " answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
    dnf install mesa-libGLU -y
    nuke_url="https://thefoundry.s3.amazonaws.com/products/nuke/releases/15.1v1/Nuke15.1v1-linux-x86_64.tgz"
    nuke_temp_files=/tmp/nuke_temp_files
    nuke_filename=$(basename "$nuke_url")
    mkdir ${nuke_temp_files}
    curl -o ${nuke_temp_files}/${nuke_filename} ${nuke_url}
    tar zxvf ${nuke_temp_files}/${nuke_filename} -C ${nuke_temp_files}
    ${nuke_temp_files}/${nuke_filename%.*}.run --accept-foundry-eula --prefix=/usr/local 
    rm -rf ${nuke_temp_files}
    echo "alias nuke='/usr/local/Nuke15.1v1/Nuke15.1'" >> ~/.bashrc

else
    echo "Skipping Nuke install"
fi

dnf install gcc-toolset-12 -y
echo "source /opt/rh/gcc-toolset-12/enable" >> ~/.bashrc


mkdir ~/Code

