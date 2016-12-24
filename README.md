# Vagrant for WD My Cloud

Vagrant setup for building packages for [WD My Cloud](http://www.wdc.com/mycloud/) running with firmware 4.x

Firmware 4.x broke compatibility with all existing Debian repositories so you can't simply apt-get install new packages anymore. The packages need to be rebuilt and this Vagrant setup provides an environment in which to do it relatively easily.

This sets up a Debian wheezy armhf qemu cowbuilder chroot in a x64 Debian wheezy VM so it should be usable on Mac and Windows. *If you're already using Debian or a derivative like Ubuntu you might want to skip everything about Vagrant and just set up the cowbuilder environment yourself (see [Vagrantfile](Vagrantfile))*

## 1. setting up
This needs to be done only once.

1. Install [VirtualBox](https://www.virtualbox.org/) (tested with 4.3.14)
2. Install [Vagrant](https://www.vagrantup.com/downloads.html) (tested with 1.6.3)
3. Download the package containing custom binutils from [WD Downloads](http://support.wdc.com/downloads.aspx?p=233) and extract the binutils packages into `pbuilder-hooks/`
    
    [gpl-source-wd_my_cloud-04.04.03-113.zip](http://downloads.wdc.com/gpl/gpl-source-wd_my_cloud-04.04.03-113.zip) (575MB) at the time of writing
    ```
curl -O http://downloads.wdc.com/gpl/gpl-source-wd_my_cloud-04.04.03-113.zip
./extract-binutils.sh gpl-source-wd_my_cloud-04.04.03-113.zip
    ```

4. Install and start up the virtual machine
    
    This is going to take some time as it'll download a Debian Linux distribution. Twice. You may want to edit the DEBIANMIRROR variable in `Vagrantfile` to point to a [Debian mirror](https://www.debian.org/mirror/list) close to you in order to reduce the time it takes to download everything.
    ```
vagrant up
    ```

## 2. log in

```
vagrant up
vagrant ssh
```

## 3. build packages
These commands are run in the virtual machine after `vagrant ssh`
```
cd /vagrant/sources
apt-get source transmission
cd transmission-2.52
pdebuild
```

The built package(s) will be placed in `result/` directory that will be created if it doesn't already exist.

## 4. install packages to WD My Cloud
```
scp results/transmission*.deb root@wdmycloud.local:
ssh -l root wdmycloud.local
dpkg -i transmission_*.deb transmission-cli_*.deb transmission-common_*.deb transmission-daemon_*.deb
```

## Notes

The build environment is simply set to replace binutils with the custom binutils with 64k pages that is required to build packages that are compatible with the 4.x firmware. Mostly it's just an ordinary cowbuilder chroot.

cowbuilder is just for quicker(?) builds, could probably just as well use pbuilder

While qemu-debootstrap makes it possible to build the packages for the armhf architecture fairly easily, qemu isn't sufficient for running tests (e.g. curl) successfully which is why tests are disabled with `DEB_BUILD_OPTIONS=nocheck`

Building dependencies and using those packages to (re-)build other packages is not automated. You'll need to manually generate the Packages file for the built packages (`cd /vagrant/results && apt-ftparchive packages . | gzip > Packages.gz`) and *within the cowbuilder chroot* add the `/vagrant/results/` directory to apt sources.list and run `apt-get update`.
