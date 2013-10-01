# How to shrink the VM size

The disk image tends to grow out of all proportion during import jobs and other I/O heavy activity when seeding the VM with data.

This is how you can shrink the disk image as you go (if you have limited build space), or preparing the VM image for release after it's finally seeded.

* Boot into Recovery Mode (hold down shift just as it load, and select Recovery Mode, then drop to command line shell from the menu) via Virtualbox's GUI and run:

  ``sudo zerofree -v /dev/mapper/precise64-root``

  ``sudo halt``

* Poweroff the VM

* Clone the disk:

  ``VBoxManage clonehd [FULL_PATH]/norx/box-disk1.vmdk [FULL_PATH]/norx/clone-box-disk1.vmdk``

  It's really important to give it the full path, else it will fail and complain about the disk aleady registered.

* Detach the old disk, and attach the new one to the VM:

  ``VBoxManage storageattach norx --storagectl "SATA Controller" --port 0 --device 0 --medium none``

  ``VBoxManage closemedium disk box-disk1.vmdk``

  ``VBoxManage storageattach norx --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium clone-box-disk1.vmdk``

* Boot the VM normally via VirtualBox GUI again, in order to fix Vagrant boot hang (invalid network configuration).

  ``sudo rm -rf /var/lib/dhcp/*``

  ``sudo halt``

* Power off the VM

* Vagrant should now be able to boot the newly shrunken disk image normally via ``vagrant up``.
