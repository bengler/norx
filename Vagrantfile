Vagrant::Config.run do |config|
	config.vm.box = 'precise64'
  config.vm.box_url = 'http://files.vagrantup.com/precise64.box'
  config.vm.host_name = 'kartverk.bengler.no'
  config.vm.customize [
    'modifyvm', :id,
    '--name', 'kartverk',
    '--memory', '2056'
  ]

  ## Add this if you want to share a a folder from the host system!
  #config.vm.share_folder "usbdisk", "/mnt/usbdisk", "/Volumes/ssd_video"

  config.vm.provision :shell, :inline => "sudo apt-get update && sudo apt-get install puppet -y"

  config.vm.provision :puppet, :facter => { "vagrant" => "true" }, :module_path => "#{`pwd`.strip}/puppet/modules" do |puppet|
    puppet.manifests_path = "#{`pwd`.strip}/puppet/manifests"
    puppet.manifest_file = "site.pp"
  end

	config.vm.provision :shell do |sh|
		sh.path = "./sh/base_setup.sh"
	end

end
