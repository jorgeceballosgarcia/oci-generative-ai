#!/bin/bash

main_function() {
USER='opc'

# resize boot volume
#/usr/libexec/oci-growfs -y 

# Resize root partition
printf "fix\n" | parted ---pretend-input-tty /dev/sda print
VALUE=$(printf "unit s\nprint\n" | parted ---pretend-input-tty /dev/sda |  grep lvm | awk '{print $2}' | rev | cut -c2- | rev)
printf "rm 3\nIgnore\n" | parted ---pretend-input-tty /dev/sda
printf "unit s\nmkpart\n/dev/sda3\n\n$VALUE\n100%%\n" | parted ---pretend-input-tty /dev/sda
pvresize /dev/sda3
pvs
vgs
lvextend -l +100%FREE /dev/mapper/ocivolume-root
xfs_growfs -d /


#update packages
dnf update -y
#install packages
#dnf install wget git git-lfs openssl-devel bzip2-devel libffi-devel unzip zip rustc cargo -y

#use python3.10
# wget https://www.python.org/ftp/python/3.10.9/Python-3.10.9.tgz
# tar xzf Python-3.10.9.tgz
# cd Python-3.10.9
# ./configure --enable-optimizations
# make altinstall
# echo "alias python='python3.10'" >> .bashrc
# echo "alias python3='python3.10'" >> .bashrc
# source .bashrc
# update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.10 1
# update-alternatives --set python3 /usr/local/bin/python3.10
# pip3.10 install --upgrade pip 
# pip3.10 install flask diffusers transformers accelerate scipy safetensors xformers


dnf install wget git git-lfs jq python3.11 python3.11-devel.x86_64 python3.11-pip libsndfile rustc cargo unzip zip -y

update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
update-alternatives --set python3 /usr/bin/python3.11

#clone all repos
#su -c "git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /home/$USER/stable-diffusion-webui" $USER
#su -c "cd /home/$USER/stable-diffusion-webui; git checkout 685f963" $USER
#su -c "git clone https://github.com/KutsuyaYuki/ABG_extension /home/$USER/stable-diffusion-webui/extensions/ABG_extension" $USER
#su -c "git clone https://github.com/zero01101/openOutpaint-webUI-extension /home/$USER/stable-diffusion-webui/extensions/openOutpaint-webUI-extension" $USER
#su -c "git clone https://github.com/deforum-art/deforum-for-automatic1111-webui /home/$USER/stable-diffusion-webui/extensions/deforum-for-automatic1111-webui" $USER
#su -c "echo https://github.com/C43H66N12O12S2/stable-diffusion-webui/releases/download/linux/xformers-0.0.14.dev0-cp310-cp310-linux_x86_64.whl >> /home/$USER/stable-diffusion-webui/requirements.txt" $USER

#last version sd
#su -c "git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /home/$USER/stable-diffusion-webui" $USER
su -c "pip3.11 install --upgrade pip" $USER
su -c "pip3.11 install flask diffusers transformers accelerate scipy safetensors xformers" $USER
su -c "mkdir -p /home/$USER/sd; cd /home/$USER/sd; wget -q https://raw.githubusercontent.com/AUTOMATIC1111/stable-diffusion-webui/master/webui.sh" $USER
#su -c "cd /home/$USER/stable-diffusion-webui; mkdir -p stable-diffusion-webui/models/Stable-diffusion; cd stable-diffusion-webui/models/Stable-diffusion; wget https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors; wget https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned.ckpt" $USER


#2.1
#https://huggingface.co/stabilityai/stable-diffusion-2-1/resolve/main/v2-1_768-ema-pruned.ckpt

# su -c "git clone https://github.com/carlgira/bloom-webui.git /home/$USER/bloom-webui" $USER
# su -c "cd /home/$USER/bloom-webui; git checkout f21a51d" $USER
# su -c "git clone https://github.com/carlgira/dreambooth-webui.git /home/$USER/dreambooth-webui" $USER
# su -c "cd /home/$USER/dreambooth-webui; git checkout f21a51d" $USER
# su -c "git clone https://github.com/carlgira/automatic-image-processing.git /home/$USER/automatic-image-processing" $USER

#create service for apps

# Stable diffusion service
cat <<EOT >> /etc/systemd/system/stable-diffusion.service
[Unit]
Description=systemd service start stable-diffusion

[Service]
User=$USER
ExecStart=/bin/bash /home/$USER/sd/webui.sh --api --xformers


[Install]
WantedBy=multi-user.target
EOT

# # Bloom service
# cat <<EOT >> /etc/systemd/system/bloom.service
# [Unit]
# Description=systemd service start bloom

# [Service]
# User=$USER
# ExecStart=/bin/bash /home/$USER/bloom-webui/start.sh

# [Install]
# WantedBy=multi-user.target
# EOT

# Dreambooth service

# cat <<EOT >> /etc/systemd/system/dreambooth.service
# [Unit]
# Description=systemd service start dreambooth

# [Service]
# User=$USER
# ExecStart=/bin/bash /home/$USER/dreambooth-webui/start.sh

# [Install]
# WantedBy=multi-user.target
# EOT

# cat <<EOT >> /etc/systemd/system/automatic-image-processing.service
# [Unit]
# Description=systemd service start automatic-image-processing

# [Service]
# User=$USER
# ExecStart=/bin/bash /home/$USER/automatic-image-processing/start.sh

# [Install]
# WantedBy=multi-user.target
# EOT

systemctl daemon-reload
# systemctl enable stable-diffusion.service bloom.service dreambooth.service automatic-image-processing.service
# systemctl start stable-diffusion.service bloom.service dreambooth.service automatic-image-processing.service
systemctl enable stable-diffusion.service 
systemctl start stable-diffusion.service 

su -c "pip3.11 uninstall bitsandbytes; git clone https://github.com/TimDettmers/bitsandbytes.git; cd /home/$USER/bitsandbytes; export LD_LIBRARY_PATH=/usr/local/cuda/lib64/:$LD_LIBRARY_PATH; export CUDA_HOME=/usr/local/cuda; CUDA_VERSION=120 make cuda11x;" $USER
# cd /home/$USER/bitsandbytes; /home/opc/sd/stable-diffusion-webui/venv/bin/python3.11 setup.py install
cd /home/$USER/bitsandbytes; python3.11 setup.py install
cp /home/$USER/bitsandbytes/build/lib/bitsandbytes/libbitsandbytes_cuda120.so /home/$USER/sd/stable-diffusion-webui/venv/lib/python3.11/site-packages/bitsandbytes
chown opc:opc /home/$USER/sd/stable-diffusion-webui/venv/lib/python3.11/site-packages/bitsandbytes/libbitsandbytes_cuda120.so
su -c "cd /home/$USER/sd/stable-diffusion-webui/models/Stable-diffusion; wget https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned.ckpt; wget https://huggingface.co/Justin-Choo/epiCRealism-Natural_Sin_RC1_VAE/resolve/main/epicrealism_naturalSinRC1VAE.safetensors" $USER

}

main_function 2>&1 >> /var/log/startup.log
