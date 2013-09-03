# Bengler Kartverk VM

## Installation

### Prerequisites
* Optional: If on Mac, install Homebrew (http://brew.sh/)
* Download and install VirtualBox (www.virtualbox.org)
* Install vagrant, puppet and puppet-line (puppet style checker) gems:
   ``sudo gem install vagrant puppet puppet-lint vagrant-vbguest --no-ri --no-rdoc``

### Install the VM

``git clone https://github.com/bengler/kartverk_vm``

``cd kartverk_vm``

``vagrant up`` (this will take some time - grab a coffee)

### Access the VM

```ssh kartverk@localhost -p 2222``` (password is 'bengler')


### How to shrink the VM size

The disk image tends to grow dynamically out of porportions during import jobs and other usage.

* Boot into Recovery Mode via Virtualbox's GUI and run:

	``sudo zerofree -v /dev/mapper/precise64-root``

	``sudo halt``

* Poweroff the VM

* Clone the disk:

	``VBoxManage clonehd ./kartverk/box-disk1.vmdk ./kartverk/clone-box-disk1.vmdk``

* Detach the old disk, and attach the new one to the VM:

	``VBoxManage storageattach kartverk --storagectl "SATA Controller" --port 0 --device 0 --medium none``

	``VBoxManage closemedium disk box-disk1.vmdk``

	``VBoxManage storageattach kartverk --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium clone-box-disk1.vmdk``

* Boot the VM normally via VirtualBox GUI again, in order to fix Vagrant boot hang (invalid network configuration).

	``sudo -Rf /var/lib/dhcp/*``

	``sudo halt``

* Power off the VM

* Vagrant should now be able to boot the new shrinked disk image normally via ``vagrant up``.
