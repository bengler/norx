# Norx - Norway in a Box

A Virtual Machine with everything you need to work with the CCBY licensed datasets from the Norwegian Mapping Authority – Statens Kartverk. The vagrant script sets up a VM for you, seeds it with fresh data from the authorities, imports it into a database and sets up services for tile rendering.

If you would rather just grab a prepopulated VM you should find a download link on our [project page](http://bengler.no/norx)

## Contents

### Base setup

* A vanilla Ubuntu Precise 64 base image from [vagrantup.com](http://vagrantup.com)
* Puppet integration for managing users and passwords

### Data

* The geometry in the N50 dataset
* Sentralt Stedsnavns Register (SSR) – Placenames
* Administrative borders for counties, municipalities, etc.
* 10m x 10m elevation data
* Terrain layers designed by Bengler

### Tools

* PostgreSQL
* Postgis
* OGR / GDAL
* Mapnik
* Tilestache
* Elastic Search
* A simple Leaflet/node-app for checking out the data

## Installation

### Prerequisites
* Optional: If on Mac, install [Homebrew](http://brew.sh/)
* Download and install [VirtualBox](www.virtualbox.org). 

If you don't want to install NORX to the default Virtual Box's image folder, make sure you set another default location for the VMs in VirtualBox's preferences. Having your box on a USB3 SD disk is neat!

* Install vagrant, puppet and puppet-lint (puppet style checker) Ruby gems:
   ``sudo gem install vagrant puppet puppet-lint vagrant-vbguest --no-ri --no-rdoc``

### Install the VM

``git clone https://github.com/bengler/norx``

``cd norx``

``vagrant up``

When it's done, you're ready to talk Norx.

### Browse a map!

``http://127.0.0.1:3000``

### Log into and use the VM

``ssh norx@localhost -p 2222`` (password is 'bengler')


## Management via Vagrant

#### Starting up

``vagrant up``


#### Rebooting the VM with a new Vagrant configuration

``vagrant reload``


#### Pausing

``vagrant suspend``

#### Shutting it down

``vagrant halt``


## Config paths

### The VM itself (host/guest config)

See [``Vagrantfile``](https://github.com/bengler/norx/blob/master/Vagrantfile)

### Tilestache:

Stop and start with ``sudo /etc/init.d/tilestache restart``

Have a look at ``/home/norx/services/tilestache/tilestache.cfg`` for configuration of the worker.

### Mapnik files to Tilestache

Check out our repo for designing layers with TileMill:

https://github.com/bengler/norx_tilemill_simple

Mapnik XML files are put under: ``/home/norx/services/tilestache/*.xml``

### The Leaflet map serving application (Node JS):

``/home/norx/services/leaflet/app.json``


## Building and seeding the VM from scratch

When built from scratch, Norx will expand itself to include :

* [norx_data](https://github.com/bengler/norx_data) for seeding data from Statens Kartverk into the VM
* [norx_services](https://github.com/bengler/norx_services) - TileStache, Elastic Search and node setup
* [norx_leaflet](https://github.com/bengler/norx_leaflet) - a simple node application for browsing the built data

The disk image will grow pretty huge especially during seeding the terrain data from Statens Kartverk, so have at least 80 GB of free disk space!

The complete build and seed will take a couple of hours++, all depending on your internet connection and hardware.

You may see what's going on in [``Vagrantfile``](https://github.com/bengler/norx/blob/master/Vagrantfile) and [``base_setup.sh``](https://github.com/bengler/norx/blob/master/sh/base_setup.sh) - and the above mentioned reposetories.

## More info
Please refer to [the project page](http://bengler.no/norx) or the [wiki](https://github.com/bengler/norx/wiki)

You may also use our [issue tracker](https://github.com/bengler/norx/issues) and contribute to this code.
