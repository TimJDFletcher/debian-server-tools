#!/bin/bash --version
#
# Install VMware tools Tools for virtual machines hosted on VMware
#
# VERSION       :0.4.0
# DATE          :2015-05-16
# AUTHOR        :Viktor Szépe <viktor@szepe.net>
# LICENSE       :The MIT License (MIT)
# URL           :https://github.com/szepeviktor/debian-server-tools
# BASH-VERSION  :4.2+
# DOCS          :http://partnerweb.vmware.com/comp_guide2/sim/interop_matrix.php
# UPSTREAM      :https://github.com/vmware/open-vm-tools

##
## Deprecated!
## VMware recommends that you use the open-vm-tools that come with these operating systems.
##

exit 0

# Wheezy
# https://packages.debian.org/wheezy-backports-sloppy/open-vm-tools

# Get current tool version
vmtoolsd --version

# uninstall
vmware-uninstall-tools.pl 2>&1 | tee vmware-uninstall.log
rm -vrf /usr/lib/vmware-tools

# Add VMware tools Debian repository
# http://packages.vmware.com/tools/versions
echo "deb http://packages.vmware.com/tools/esx/latest/ubuntu precise main" \
    > /etc/apt/sources.list.d/vmware-tools.list
# https://help.ubuntu.com/community/VMware/Tools
wget -qO- http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub | apt-key add -
apt-get update

# Fake upstart
dpkg-divert --local --rename --add /sbin/initctl
ln -vs /bin/true /sbin/initctl

# Install vmware-tools
apt-get install -y vmware-tools-services vmware-tools-user

# Symlink init script
ln -sv /etc/vmware-tools/init/vmware-tools-services /etc/init.d/vmware-tools-services

# Prepend this to
editor /etc/vmware-tools/init/vmware-tools-services
# and on every update


### BEGIN INIT INFO
# Provides:          vmware-tools-services
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description: The VMware Tools Daemon service enables fundamental host/guest functionality between a VM and its host.
# Short-Description: Enables VMware host/guest functionality.
### END INIT INFO


# Enable init script
# without start and stop https://lists.debian.org/debian-devel/2013/05/msg01109.html
update-rc.d vmware-tools-services defaults

# Start service
service vmware-tools-services start

# Tests
service vmware-tools status
ps aux | grep -v "grep" | egrep "vmtoolsd"
vmtoolsd --version
# http://www.firetooth.net/confluence/display/public/VMware+Tools+for+Linux
/usr/lib/vmware-tools/sbin/vmware-checkvm -p
/usr/lib/vmware-tools/sbin/vmware-checkvm -h
vmware-toolbox-cmd stat sessionid
