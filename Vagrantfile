# -*- mode: ruby -*-
# vi: set ft=ruby :
#
DEBIANMIRROR="ftp.nl.debian.org"

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "chef/debian-7.6"

  config.vm.provider "virtualbox" do |vm|
      vm.memory = 1024
      vm.cpus = 2
  end

  config.vm.provision "shell", run: "always", inline: <<EOF
set -e
set -x

install --owner=root --group=root --mode=0664 /vagrant/etc/environment /etc/environment
install --owner=root --group=root --mode=0440 /vagrant/etc/sudoers_pbuilder /etc/sudoers.d/01_pbuilder

sed -e 's,@DEBIANMIRROR@,#{DEBIANMIRROR},g' < /vagrant/etc/sources.list.tmpl > /etc/apt/sources.list
sed -e 's,@DEBIANMIRROR@,#{DEBIANMIRROR},g' < /vagrant/etc/pbuilderrc.tmpl > /etc/pbuilderrc
EOF

  config.vm.provision "shell", inline: <<EOF
apt-get update

apt-get -y install qemu-user-static binfmt-support packaging-dev cowbuilder

cowbuilder --create \
    --debootstrap qemu-debootstrap \
    --debootstrapopts --variant=buildd \
    --debootstrapopts --arch=armhf
EOF
end
