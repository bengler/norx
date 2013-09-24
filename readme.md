# Norx - Norway in a Box

A Virtual Machine with everything you need to work with the CCBY licensed datasets from the Norwegian Mapping Authority – Statens Kartverk.

The vagrant script sets up a VM for you, seeds it with fresh data from the authorities, imports it into a database and sets up services for tile rendering.

If you would rather just grab a prepopulated VM you should find a download link on our [project page](http://bengler.no/norx)

## Contents

### Data

* The geometry in the N50 dataset
* Sentralt Stedsnavns Register (SSR) – Placenames
* 10m x 10m elevation data

### Tools

* PostgreSQL
* Postgis
* OGR / GDAL
* Mapnik
* Tilestache
* HAProxy
* Elastic Search

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

The disk image tends to grow dynamically out of porportions during import jobs and other I/O heavy usage.

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
