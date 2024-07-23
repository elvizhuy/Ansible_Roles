#!/bin/bash

is_ubuntu=`awk -F '=' '/PRETTY_NAME/ { print $2 }' /etc/os-release | egrep Ubuntu -i`
is_centos=`awk -F '=' '/PRETTY_NAME/ { print $2 }' /etc/os-release | egrep Rocky -i`

# Function to set up the hostname
function set_hostname() {
    new_hostname="$NEW_HOSTNAME"

    # Validate the hostname (optional)
    if [[ ! "$new_hostname" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        echo "Invalid hostname. Please use alphanumeric characters, dots, and dashes."
        return 1
    fi

    # Set the hostname
    sudo echo "$new_hostname" > /etc/hostname
    sudo hostnamectl set-hostname "$new_hostname"

    # Update /etc/hosts with the new hostname
    sudo sed -i "s/127.0.1.1.*/127.0.1.1\t$new_hostname/" /etc/hosts

    echo "Hostname set to $new_hostname."
}

# Function to install basic tools on Ubuntu
function ubuntu_basic_install() {
    sudo apt -y update
    sudo apt -y install git wget net-tools epel-release htop vim nano nmon telnet rsync sysstat lsof nfs-common cifs-utils chrony resolvconf
	sudo "nameserver 8.8.8.8" > /etc/resolvconf/resolv.conf.d/head
	sudo resolvconf --enable-updates
	sudo resolvconf -u	
	sudo systemctl restart resolvconf && systemctl enable resolvconf
    sudo timedatectl set-timezone Asia/Ho_Chi_Minh
    sudo ufw disable 
    sudo systemctl start chronyd
    sudo systemctl restart chronyd
    sudo chronyc sources
    sudo timedatectl set-local-rtc 0
}

# Function to install basic tools on CentOS
function centos_basic_install() {
    sudo yum update -y
    sudo yum install -y epel-release
    sudo timedatectl set-timezone Asia/Ho_Chi_Minh
    sudo yum install -y git wget net-tools epel-release htop vim nano nmon telnet rsync sysstat lsof nfs-utils cifs-utils chrony resolvconf
	sudo echo "nameserver 8.8.8.8" > /etc/resolvconf/resolv.conf.d/head
	sudo resolvconf --enable-updates
	sudo resolvconf -u	
	sudo systemctl restart resolvconf && systemctl enable resolvconf
    sudo systemctl stop firewalld
    sudo systemctl disable firewalld
    sudo systemctl mask --now firewalld
    sudo systemctl enable chronyd
    sudo systemctl restart chronyd
    sudo chronyc sources
    sudo timedatectl set-local-rtc 0
}

# Function to enable limiting resources
function enable_limiting_resources() {
    echo "Enable limiting resources"
    
    sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

    echo 'GRUB_CMDLINE_LINUX="cdgroup_enable=memory swapaccount=1"' | sudo tee -a /etc/default/grub
    sudo update-grub
}

# Function to set up SSH keys for the 'root' user
function setup_ssh_keys_root() {
    sudo mkdir -p /root/.ssh && sudo touch /root/.ssh/authorized_keys && sudo chmod 700 /root/.ssh && sudo chmod 600 /root/.ssh/authorized_keys
    sudo cat <<EOF > /root/.ssh/authorized_keys
#Jenkins52
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFwLR6DpxhpkEWUTpYgBfjS2++FknUWTZJzkAALwijP0d2kSr0Q0jipKWRX1KtqOOsb/ZFwRr7MLmfqJ8x+Dl+81fbE5PX8eifLwAaD6RyAS4xo87eS8xIvLmavL6gELP5Dm6y1npnNIkEiXMYYKDFm8nb3xlQv89EdBMV+2jCdfhwRKFk8l4O3Yw3klL5Kvs4d2T/n/3zYOgfmh/8XXuXraBJIyEVOGzQcd+0xzz4+vs9u6IAgxXaknPoksycsTjCENaN4Fy8ylpKYrYOzLZkSh7IEjUoXHEXwvfWNc7jNW1KbRRrVSmusBDDC+eNbjw7tlp1LACjzoHQQOnHBLFb @isofh-jenkins52

#System
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDXcEw6kzgLXC+ikODdz/Q6r4YsApCglOQwZwzqNOXLbOMFMIB0nln9eevcQcsCf0e4wm6nYP+wOooSUpTVlun7zfUcqj5N3LVKJGvKMLKOghUtOIlJGysy+wn/Nb9mM1Yd67LGnzMJSQrwQCuy8Czgryeqcve9XbKlO6eNoUNeH/JnaqEMdcC70Yu1Sb8eHJV4T2Ub5sWrCe/l3HoKmZuub0beWpouwEmAWgV44tX3KtZNyM67GozbSN0urUgvH//qq16gL7HjfMdAWkNkYmM0TDSXqauvozf4whhgDyo5O4fgLGJJxRgAzCtCgN67y5Er6we4o/WmsCuCF4512iUl @system
    
#Minh-CTO
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2VWlYeeDegqIDIQbQh/PZgouGv7LYmUMEOZEQPwSKuYg+teuyBcTNYqRdzjS0dDX1PPPS39xgHm5sa0G6L73L9hRONTMBicqXMdO7aNEFPucfBkfhJ8tDok5xE1e+dtMwwybqmUjfRi6fxao/AM606FOUa1MN4d9w3Qhu1NyiAlCjcyw+qeAGnD1yz3LRxKEq0H5uGSKW672fwx7UvX91wByw+WqYo2UkwVKW9vqa4jvAi0haPJPvENlFpJ3jQ+hJ+ewZWSi4YXmZ8cQkBNWGdZzuOb3VOTWyJIAjiBpeti+arChguoMmFeY3WNFlICfLZ4IbmRtIh3FL/QexYBJYKhjML+Ub3AgUU9t63Lj+9WD7s4QOejH5s3x/V8eP/ZomJetnB6x5zmbu+d6/znoe2J/PIUjHsp7b0qu4XP0/dIY/YqdIjOgOVckHCmjekXnOuXmdxvUOn7GO4uSgHcUh15eCJss1Jahl8q2xrnB8JCEbSMi/PAasKRAxZEKECxigkE7cvbF0UlsYJrFtWY+56BsqTH+64mN/0EtP4bnkoc/2SBt0WBIX6WJfptnfyhd02D0SvEpl22r443JaW2HhL7QUZMwmKm1ZU1rra8oYqB18mG1f4RJlpn9fgvskDFNxGuhoiVMZdWeM935UaO2O+v8LwLO5K8LIpK/avwXw6Q== vanminh.ph23@gmail.com
EOF
}

# Create user isofh
function create_user() {
    if [ "$CREATE_USER" == 'y' ]; then
        user="$USERNAME"
        userpassword="$PASSWORD"
        if [ "$user" == 'isofh' ]; then
            useradd -ms /bin/bash isofh
            echo "isofh ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

            echo -e "$userpassword\n$userpassword" | passwd isofh

            echo "Created the user 'isofh' and set the password successfully."
        else
            echo "Invalid username, exiting."
            exit 1
        fi
    fi
}

# Function to set up SSH keys for the 'isofh' user
function setup_ssh_keys_isofh() {
	echo "Setup ssh key for user 'isofh'"
    sudo mkdir -p /home/isofh/.ssh && sudo touch /home/isofh/.ssh/authorized_keys && sudo chmod 700 /home/isofh/.ssh && sudo chmod 600 /home/isofh/.ssh/authorized_keys
	sudo chown -R isofh:isofh /home/isofh/.ssh
    sudo cat <<EOF > /home/isofh/.ssh/authorized_keys
#Jenkins52
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFwLR6DpxhpkEWUTpYgBfjS2++FknUWTZJzkAALwijP0d2kSr0Q0jipKWRX1KtqOOsb/ZFwRr7MLmfqJ8x+Dl+81fbE5PX8eifLwAaD6RyAS4xo87eS8xIvLmavL6gELP5Dm6y1npnNIkEiXMYYKDFm8nb3xlQv89EdBMV+2jCdfhwRKFk8l4O3Yw3klL5Kvs4d2T/n/3zYOgfmh/8XXuXraBJIyEVOGzQcd+0xzz4+vs9u6IAgxXaknPoksycsTjCENaN4Fy8ylpKYrYOzLZkSh7IEjUoXHEXwvfWNc7jNW1KbRRrVSmusBDDC+eNbjw7tlp1LACjzoHQQOnHBLFb @isofh-jenkins52

#System
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDXcEw6kzgLXC+ikODdz/Q6r4YsApCglOQwZwzqNOXLbOMFMIB0nln9eevcQcsCf0e4wm6nYP+wOooSUpTVlun7zfUcqj5N3LVKJGvKMLKOghUtOIlJGysy+wn/Nb9mM1Yd67LGnzMJSQrwQCuy8Czgryeqcve9XbKlO6eNoUNeH/JnaqEMdcC70Yu1Sb8eHJV4T2Ub5sWrCe/l3HoKmZuub0beWpouwEmAWgV44tX3KtZNyM67GozbSN0urUgvH//qq16gL7HjfMdAWkNkYmM0TDSXqauvozf4whhgDyo5O4fgLGJJxRgAzCtCgN67y5Er6we4o/WmsCuCF4512iUl @system
    
#Minh-CTO
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2VWlYeeDegqIDIQbQh/PZgouGv7LYmUMEOZEQPwSKuYg+teuyBcTNYqRdzjS0dDX1PPPS39xgHm5sa0G6L73L9hRONTMBicqXMdO7aNEFPucfBkfhJ8tDok5xE1e+dtMwwybqmUjfRi6fxao/AM606FOUa1MN4d9w3Qhu1NyiAlCjcyw+qeAGnD1yz3LRxKEq0H5uGSKW672fwx7UvX91wByw+WqYo2UkwVKW9vqa4jvAi0haPJPvENlFpJ3jQ+hJ+ewZWSi4YXmZ8cQkBNWGdZzuOb3VOTWyJIAjiBpeti+arChguoMmFeY3WNFlICfLZ4IbmRtIh3FL/QexYBJYKhjML+Ub3AgUU9t63Lj+9WD7s4QOejH5s3x/V8eP/ZomJetnB6x5zmbu+d6/znoe2J/PIUjHsp7b0qu4XP0/dIY/YqdIjOgOVckHCmjekXnOuXmdxvUOn7GO4uSgHcUh15eCJss1Jahl8q2xrnB8JCEbSMi/PAasKRAxZEKECxigkE7cvbF0UlsYJrFtWY+56BsqTH+64mN/0EtP4bnkoc/2SBt0WBIX6WJfptnfyhd02D0SvEpl22r443JaW2HhL7QUZMwmKm1ZU1rra8oYqB18mG1f4RJlpn9fgvskDFNxGuhoiVMZdWeM935UaO2O+v8LwLO5K8LIpK/avwXw6Q== vanminh.ph23@gmail.com
EOF
}

#Function install Prometheus Grafana agents
function install_prometheus_grafana_agents(){
sudo docker run -d \
    --name node-exporter-isofh \
    --restart unless-stopped \
    --publish 19100:9100 \
    --volume /proc:/host/proc:ro \
    --volume /sys:/host/sys:ro \
    --volume /:/rootfs:ro \
    prom/node-exporter:latest \
    --path.procfs /host/proc \
    --path.rootfs /rootfs \
    --path.sysfs /host/sys \
    --collector.filesystem.mount-points-exclude "^/(sys|proc|dev|host|etc)($$|/)"

sudo docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=19093:8080 \
  --detach=true \
  --restart always \
  --name=cadvisor-isofh \
  --privileged \
  --device=/dev/kmsg \
  gcr.io/cadvisor/cadvisor:latest

sudo docker run -d \
  --name container-exporter \
  -v "/var/run/docker.sock:/var/run/docker.sock" \
  -p 19094:19092 \
  nguyenngochuy/container-exporter:v20.10.14 \
  -listen-address=:19092
}

# Function to set file limits
function set_file_limits() {
    echo "Setting file limits"
    
    # Set sysctl parameters
    echo "fs.file-max=100000" | sudo tee -a /etc/sysctl.conf
    echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
    
    # Set limits for users
    echo "* soft nofile 100000" | sudo tee -a /etc/security/limits.conf
    echo "* hard nofile 100000" | sudo tee -a /etc/security/limits.conf
}

# Function to configure bash aliases and functions
function configure_bash_aliases() {
	echo "alias dils='docker image ls'
	alias dirm='docker image rm'
	
	alias dcls='docker container ls -a --size'
	alias dcrm='docker container rm'
	
	alias dcb='docker build . -t'
	
	alias dr='docker restart'
	
	alias dl='docker logs'
	
	alias ds='docker stats'
	
	alias din='docker inspect'
	
	alias dcc='docker cp'
	
	alias dload='docker load -i'
	
	alias dlf='docker logs -f --tail 100'

    function dcl() {
        sudo truncate -s 0 \$(docker inspect --format='{{.LogPath}}' \$1)
    }
    
    function drun() {
        docker run --rm \$3 --name \$2 -it \$1 /bin/bash
    }
    
    function drun_network_host() {
        docker run --rm --network=host \$3 --name \$2 -it \$1 /bin/bash
    }
    
    function dsave() {
        docker save -o \$2 \$1
    }
    
    function dexec() {
        container=\$1
        docker exec -it \$container /bin/bash
    }
    
    function dt() {
        for i in \$(docker container ls --format "{{.Names}}"); do
            echo Container: \$i
            docker top \$i -eo pid,ppid,cmd,uid
        done
    }" | sudo tee -a /home/isofh/.bashrc
}

# Function to install Docker on Ubuntu
function ubuntu_docker_install() {
    sudo apt-get -y update
    sudo apt-get remove -y docker docker-engine docker.io containerd runc
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common git vim 
	
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo \
		"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
		$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get -y update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    sudo bash -c 'touch /etc/docker/daemon.json' && sudo bash -c "echo -e '{\n\t\"bip\": \"55.55.1.1/24\"\n}' > /etc/docker/daemon.json"

    sudo systemctl enable docker.service
    sudo systemctl start docker
    sudo usermod -aG docker isofh

    echo "Docker has been installed successfully."
}

# Function to install Docker on CentOS
function centos_docker_install() {
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2 git vim
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum -y install docker-ce docker-ce-cli containerd.io

    sudo bash -c 'touch /etc/docker/daemon.json' && sudo bash -c "echo -e '{\n\t\"bip\": \"55.55.1.1/24\"\n}' > /etc/docker/daemon.json"

	sudo systemctl enable docker.service
	sudo systemctl start docker
	
    #is_docker_success=$(sudo docker run hello-world | grep -i "Hello from Docker")
    #if [ -z "$is_docker_success" ]; then
    #    echo "Error: Docker installation failed."
     #   exit
    #fi

	sudo usermod -aG docker isofh
	echo "Docker has been installed successfully."		
}

# Function to install Docker Compose
function docker_compose_install() {
    COMPOSE_VERSION=$(git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oE "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)
    sudo sh -c "curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose"
    sudo chmod +x /usr/local/bin/docker-compose
    sudo sh -c "curl -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"
    docker-compose --version
    echo "Docker-compose has been installed successfully."
}

# Function to install Docker
function docker_install() {
	if [ ! -z "$is_ubuntu" ]; then
		ubuntu_docker_install
	elif [ ! -z "$is_centos" ]; then
		centos_docker_install
	fi
}

# Function to reboot the server
function reboot_server() {
    if [ "$REBOOT" == 'y' ]; then
        /sbin/reboot
    fi
}

############################################################

echo "Run with root privileges"

# Set up the hostname
set_hostname

# Set up SSH keys for the 'root' user
setup_ssh_keys_root

###--------
# Create user isofh
create_user

if [ "$ADD_SSH_KEY" == "y" ]; then
    # Set up SSH keys for the 'isofh' user
    setup_ssh_keys_isofh
else
    echo "Skipping SSH key setup."
fi

if [ "$ADD_ALIASES" == "y" ]; then
    # Add aliases for the user 'isofh'
    configure_bash_aliases
    echo "Aliases added for user isofh."
else
    echo "Skipping alias setup for user isofh."
fi

###--------
# Linux - Basic tools
echo "Installing basic tools for Linux"
if [ ! -z "$is_ubuntu" ]; then
	ubuntu_basic_install
elif [ ! -z "$is_centos" ]; then
	centos_basic_install
fi

###--------
# Enable limiting resources
enable_limiting_resources

###--------
# Set file limits
set_file_limits

###--------

###--------
# Install Docker
if [ ! -z "$is_ubuntu" ]; then
	is_docker_exist=`dpkg -l | grep docker -i`
elif [ ! -z "$is_centos" ]; then
	is_docker_exist=`rpm -qa | grep docker`
else
	echo "Error: Current Linux release version is not supported, please use either centos or ubuntu. "
	exit
fi
if [ ! -z "$is_docker_exist" ]; then
	echo "Warning: docker already exists. "
fi

if [ "$INSTALL_DOCKER" == "y" ]; then
	docker_install
	docker_compose_install
else
	echo "Docker not installed"
fi

# Install node exporter / container exporter / cadvisor
install_prometheus_grafana_agents

###--------
# Reboot the server
reboot_server

echo "Script execution completed."
