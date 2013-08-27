# Bengler Kartdata VM

## Installation

### Prerequisites
* Optional: If on Mac, install Homebrew (http://brew.sh/)
* Download and install VirtualBox (www.virtualbox.org)
* Install vagrant, puppet and puppet-line (puppet style checker)

   ``sudo gem install vagrant puppet puppet-lint ruby-augeas --no-ri --no-rdoc``

### Install the VM
``cd kartverk_vm``
``vagrant up`` (this will take some time - grab a coffee)

### Access the VM
```ssh kartverk@localhost -p 2200``` (password is 'bengler')
