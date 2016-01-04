#!/bin/bash -x

# makes a Vagrant box from an ISO install CD/DVD (eg: ubuntu)

# does most of this stuff
# http://jayunit100.blogspot.com/2014/10/building-vagrant-virtualbox-box-from-iso.html


# on mac, open VirtualBox app
# hit "New" in the upper left bar
# Name: xenial
# Type: Linux
# Version: Ubuntu (64-bit)
# VirtualBox setup:
#   Create a virtual hard disk now
#     [Expert Mode]
#     VMDK [check, non default]
#     25 GB
#     [Create]
# [power on VM]
# pick the iso you downloaded previously, eg:
#   wget http://cdimage.ubuntu.com/ubuntu-server/daily/current/xenial-server-amd64.iso
# step through the ubuntu setup, etc:
#   make hostname "vagrant" (not "ubuntu", etc.)
#   make a non-root user "vagrant"
#   make vagrant pw the obvi one

# start VM, log in as user "vagrant"
# sudo passwd root
# (make pw the obvi one)
# then continue w/ this script (in a root shell on VM)


apt-get update;
apt-get install  linux-headers-generic  linux-headers-virtual  build-essential;
reboot;


# go to VirtualBox main menu [Machine]:
#   [Settings]
#   [Storage]
#   click the *Additions.iso
#   check the "Live CD/DVD" box
# go to VirtualBox main menu [Devices]
#   => Insert Guest Additions CD Image
# log back into VM as root.
# mount the guest additions:
mkdir -p /mnt/vboxadditions;
mount /dev/cdrom /mnt/vboxadditions;
sh /mnt/vboxadditions/VBoxLinuxAdditions.run;



# gist extracted/extended from:
#    http://jayunit100.blogspot.com/2014/04/insecure-keys-for-devtest-ssh.html
for U in /root  /home/vagrant; do
  mkdir -p $U/.ssh;
  wget --no-check-certificate https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant     -O $U/.ssh/id_rsa;
  wget --no-check-certificate https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -O $U/.ssh/id_rsa.pub;
  chmod 600 $U/.ssh/id_*;
  cat  $U/.ssh/id_rsa.pub >| $U/root/.ssh/authorized_keys;
done

chown -R vagrant.vagrant /home/vagrant/.ssh;


apt-get install openssh-server;

# NOW VERIFY YOU CAN SSH FROM INSIDE VM TO ITSELF!
ssh vagrant@vagrant hostname -f;
ssh    root@vagrant hostname -f;


if ( ! fgrep -q 'vagrant' /etc/sudoers ); then
  echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers;
fi


# now do this outside in the host
# cd ~/VirtualBox\ VMs/;
# vagrant package  --base xenial  --out /var/tmp/x.box
# cd /petabox/vagrant/xenail  # (or wherever, already has Vagrantfile set to box named 'ubuntu/xenial64' )
# vagrant box add  'ubuntu/xenial64'   /var/tmp/x.box
# vagrant up
