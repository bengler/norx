# Norx - Norway in a Box

A Virtual Machine with everything you need to work with the CCBY licensed datasets from the Norwegian Mapping Authority – Statens Kartverk. The vagrant script sets up a VM for you, seeds it with fresh data from the authorities, imports it into a database and sets up services for tile rendering.

If you would rather just grab a prepopulated VM you should find a download link on our [project page](http://bengler.no/norx)

## Contents

### Data

* The geometry in the N50 dataset
* Sentralt Stedsnavns Register (SSR) – Placenames
* 10m x 10m elevation data
* Terrain layers designed by Bengler

### Tools

* PostgreSQL
* Postgis
* OGR / GDAL
* Mapnik
* Tilestache
* Elastic Search

## Installation

When built from scratch, the built machine expands itself with code from the following reposetories from Bengler (github.com/bengler):

* norx_data (seeding data from Statens Kartverk)
* norx_services (TileStache and Elastic Search index for places)
* norx_leaflet (A simple demo app run locally to confirm that the installation went OK)

### Prerequisites
* Optional: If on Mac, install Homebrew (http://brew.sh/)
* Download and install VirtualBox (www.virtualbox.org). 

If you don't want to install NORX to the default Virtual Box's image folder, make sure you set another default location for the VMs in VirtualBox's preferences.

This VM will grow pretty huge when it's completely built from scratch, so have at least 70 GB of free disk space before proceeding!

* Install vagrant, puppet and puppet-line (puppet style checker) gems:
   ``sudo gem install vagrant puppet puppet-lint vagrant-vbguest --no-ri --no-rdoc``

### Install the VM

``git clone https://github.com/bengler/norx``

``cd norx``

``vagrant up`` (this will take some time - grab a coffee or a night's sleep)

When it's done, you're ready to talk Norx.

### Browse a map!

``http://127.0.0.1:3000``

### Log into and use the VM

``ssh norx@localhost -p 2222`` (password is 'bengler')


## Management via Vagrant

If you do modifications to the build scripts.

### Starting up

``vagrant up``


### Reloading the VM with a new configuration:

``vagrant reload``


### Shutting it down

``vagrant suspend``


## Config paths

The VM runs two main applications, TileStache and a simple Leaflet application working on the internal datasets.

### Tilestache:

Stop and start with ``sudo /etc/init.d/tilestache restart``

Have a look at ``/home/norx/services/tilestache/tilestache.cfg`` for configuration of the worker.

### Mapnik files to Tilestache

Check out our repo for designing layers with TileMill:

https://github.com/bengler/norx_tilemill_simple

Mapnik XML files are put under: ``/home/norx/services/tilestache/*.xml``

### The Leaflet map serving application (Node JS):

``/home/norx/services/leaflet/app.json``

## More information

Please refer to the markdown under /docs, http://bengler.no/norx or http://github.com/bengler/norx

