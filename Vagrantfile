unless Vagrant.has_plugin?("vagrant-disksize")
  raise  Vagrant::Errors::VagrantError.new, "vagrant-disksize plugin is missing. Please install it using 'vagrant plugin install vagrant-disksize' and rerun 'vagrant up'"
end
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.disksize.size = '400GB'

  config.vm.provision "shell", inline: <<-SHELL
  ROOT_DISK_DEVICE="/dev/sda"
  ROOT_DISK_DEVICE_PART="/dev/sda3"
  LV_PATH=`lvdisplay -c | sed -n 1p | awk -F ":" '{print $1;}'`
  FS_PATH=`df / | sed -n 2p | awk '{print $1;}'`
  ROOT_FS_SIZE=`df -h / | sed -n 2p | awk '{print $2;}'`
  echo "The root file system (/) has a size of $ROOT_FS_SIZE"
  echo "> Increasing disk size of $ROOT_DISK_DEVICE to available maximum"
  sgdisk -e $ROOT_DISK_DEVICE
  sgdisk -d 3 $ROOT_DISK_DEVICE
  sgdisk -N 3 $ROOT_DISK_DEVICE
  partprobe  $ROOT_DISK_DEVICE
  pvresize $ROOT_DISK_DEVICE_PART
  lvextend -l 100%VG $LV_PATH
  resize2fs -p $FS_PATH
  pvresize $ROOT_DISK_DEVICE_PART
  ROOT_FS_SIZE=`df -h / | sed -n 2p | awk '{print $2;}'`
  echo "The root file system (/) has a size of $ROOT_FS_SIZE"
  apt-get update
  apt-get -y install ca-certificates curl gnupg lsb-release
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update
  apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
  groupadd docker
  usermod -aG docker vagrant
  newgrp docker 
  systemctl enable docker.service
  systemctl enable containerd.service
  service docker start
  docker run hello-world
  apt-get update
  apt-get -y install build-essential python3.8-dev python3.8-venv qt5-default python3-pyqt5.qtwebengine libpq-dev postgresql python3-pip rsync elinks
  apt-get -y install texinfo vim remake elinks
  python3 -m pip install --upgrade pip setuptools
  cat > requirements.txt <<REQ
alembic==1.4.0
google-api-python-client==2.5.0
google-auth==1.30.1
google-cloud-error-reporting==1.1.2
google-cloud-logging==1.15.1
google-cloud-secret-manager==2.4.0
clusterfuzz==0.0.1a0
Jinja2==2.11.3
numpy==1.22.0
MarkupSafe==2.0.1
Orange3==3.28.0
pandas==1.2.4
psutil==5.9.0
testresources==2.0.1
psycopg2-binary==2.8.4
pyfakefs==3.7.1
pytest==6.1.2
python-dateutil==2.8.1
pytz==2019.3
# PyYAML==5.4
redis==3.5.3
rq==1.4.3
scikit-posthocs==0.6.2
scipy==1.6.2
seaborn==0.11.1
sqlalchemy==1.3.19
protobuf==3.20.1

# Needed for development.
pylint==2.7.4
pytype==2021.4.15
yapf==0.30.0
REQ
  python3 -m pip install -r requirements.txt
  echo core >/proc/sys/kernel/core_pattern
  SHELL
end
