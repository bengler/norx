Vagrant::Config.run do |config|
	config.vm.box = 'precise64'
  config.vm.box_url = 'http://files.vagrantup.com/precise64.box'
  config.vm.host_name = 'norx.local'
  config.vm.forward_port 22, 2222 # SSH
  config.vm.forward_port 3000, 3000 # Terrafab
  config.vm.forward_port 3001, 3001 # TileStache
  config.vm.forward_port 9200, 9200 # Elastic Search
  config.vm.customize [
    'modifyvm', :id,
    '--name', 'norx',
    '--memory', '4128'
  ]

  ## Add this if you want to share a a folder from the host system
  ## Params: Logicial name, guest mount point, host mount point
  #config.vm.share_folder "usbdisk", "/mnt/usbdisk", "/Volumes/map_data"

  config.vm.provision :shell, :inline => "sudo apt-get update && sudo apt-get install puppet -y"

  config.vm.provision :puppet, :facter => { "vagrant" => "true" }, :module_path => "#{`pwd`.strip}/puppet/modules" do |puppet|
    puppet.manifests_path = "#{`pwd`.strip}/puppet/manifests"
    puppet.manifest_file = "site.pp"
  end

	config.vm.provision :shell do |sh|
		sh.path = "./sh/base_setup.sh"
	end

end
