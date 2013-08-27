# Bengler Kartverk VM

## Installation

### Prerequisites
* Optional: If on Mac, install Homebrew (http://brew.sh/)
* Download and install VirtualBox (www.virtualbox.org)
* Install vagrant, puppet and puppet-line (puppet style checker) gems:
   ``sudo gem install vagrant puppet puppet-lint --no-ri --no-rdoc``

### Install the VM

``git clone https://github.com/bengler/kartverk_vm``

``cd kartverk_vm``

``vagrant up`` (this will take some time - grab a coffee)

### Access the VM

```ssh kartverk@localhost -p 2200``` (password is 'bengler')
