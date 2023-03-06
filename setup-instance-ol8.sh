#!/bin/bash

main_function() {
USER='opc'

# resize boot volume
/usr/libexec/oci-growfs -y 

#update packages
dnf update -y
#install packages
dnf install wget git git-lfs openssl-devel bzip2-devel libffi-devel  unzip zip rustc cargo -y

#use python3.10
wget https://www.python.org/ftp/python/3.10.9/Python-3.10.9.tgz
tar xzf Python-3.10.9.tgz
cd Python-3.10.9
./configure --enable-optimizations
make altinstall
echo "alias python='python3.10'" >> .bashrc
echo "alias python3='python3.10'" >> .bashrc
source .bashrc
update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.10 1
update-alternatives --set python3 /usr/local/bin/python3.10
pip3.10 install --upgrade pip
pip3.10 install flask

#clone all repos
su -c "git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /home/$USER/stable-diffusion-webui" $USER
su -c "git clone https://github.com/KutsuyaYuki/ABG_extension /home/$USER/stable-diffusion-webui/extensions/ABG_extension" $USER
su -c "git clone https://github.com/zero01101/openOutpaint-webUI-extension /home/$USER/stable-diffusion-webui/extensions/openOutpaint-webUI-extension" $USER
su -c "git clone https://github.com/deforum-art/deforum-for-automatic1111-webui /home/$USER/stable-diffusion-webui/extensions/deforum-for-automatic1111-webui" $USER
su -c "echo https://github.com/C43H66N12O12S2/stable-diffusion-webui/releases/download/linux/xformers-0.0.14.dev0-cp310-cp310-linux_x86_64.whl >> /home/$USER/stable-diffusion-webui/requirements.txt" $USER
su -c "git clone https://github.com/carlgira/bloom-webui.git /home/$USER/bloom-webui" $USER
su -c "git clone https://github.com/carlgira/dreambooth-webui.git /home/$USER/dreambooth-webui" $USER
su -c "git clone https://github.com/carlgira/automatic-image-processing /home/$USER/automatic-image-processing" $USER

#create service for apps

# Stable diffusion service
cat <<EOT >> /etc/systemd/system/stable-diffusion.service
[Unit]
Description=systemd service start stable-diffusion

[Service]
ExecStart=/bin/bash /home/$USER/stable-diffusion-webui/webui.sh --api
User=$USER

[Install]
WantedBy=multi-user.target
EOT

# Bloom service
cat <<EOT >> /etc/systemd/system/bloom.service
[Unit]
Description=systemd service start bloom
[Service]
ExecStart=/bin/bash /home/$USER/bloom-webui/start.sh
User=$USER
[Install]
WantedBy=multi-user.target
EOT

# Dreambooth service

cat <<EOT >> /etc/systemd/system/dreambooth.service
[Unit]
Description=systemd service start dreambooth

[Service]
ExecStart=/bin/bash /home/$USER/dreambooth-webui/start.sh
User=$USER

[Install]
WantedBy=multi-user.target
EOT

cat <<EOT >> /etc/systemd/system/dreambooth.service
[Unit]
Description=systemd service start dreambooth
[Service]
ExecStart=/bin/bash /home/$USER/dreambooth-webui/start.sh
User=$USER
[Install]
WantedBy=multi-user.target
EOT

cat <<EOT >> /etc/systemd/system/automatic-image-processing.service
[Unit]
Description=systemd service start automatic-image-processing
[Service]
ExecStart=/bin/bash /home/$USER/automatic-image-processing/start.sh
User=$USER
[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable stable-diffusion.service bloom.service dreambooth.service automatic-image-processing.service
systemctl start stable-diffusion.service bloom.service dreambooth.service automatic-image-processing.service

}

main_function 2>&1 >> /var/log/startup.log
