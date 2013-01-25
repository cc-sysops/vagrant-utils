#Description

A collection of Vagrant-related utilities to assist your workflow

##Chef Nodes

The annoying thing about using vagrant with a chef server is the fact that it will auto-register the node/client, but won't remove it when you're done. This is the solution we use.

###Generate Unique Nodes

Copy the **node.rb** and **Vagrantfile** into the **.vagrant.d** folder within your home directory. This Vagrantfile acts globally on any box using chef-client provisioning.  If you already have a global Vagrantfile, simply add the following to the top.

```ruby

	require_relative "node.rb"

```

An example of provisioning:

```ruby

	# -*- mode: ruby -*-
	# vi: set ft=ruby :

	$mutlivm = false
	$boxes = [“client-wordpress”]

	Vagrant::Config.run do |config|

 		config.vm.box = "precise64"

  		config.vm.box_url = "http://files.vagrantup.com/precise64.box"

 		config.vm.forward_port 80, 8080

  		config.vm.provision :chef_client do |chef|

    		chef.chef_server_url = $chefserver
    		chef.validation_key_path = “#{$home}/.chef/validation.pem"
    		chef.node_name = getNode
    		chef.environment = "vagrant"
    		chef.add_role "wordpress"
    	
    	end

	end

```

**$multivm:** Change to true if you are provisioning a multi-vm environment

**$boxes:** Include the machines you’re provisioning as an array. (Used in the node name)

**$chefserver:** Modify the variable in the **node.rb** file if you always use the same server, or simply include the string as you normally do.

**$home:** Developing on multiple platforms? This will always grab the correct path so you can use the same Vagrantfile in Mac/Windows/Linux environments.

**getNode:** This will generate a unique node name based on the pattern: **boxname-username-timestamp**

###Remove ‘dem Nodes

While the above script will avoid conflicts in node/client registration by using a new name every time you destroy a box, you will soon find your Chef server jam-packed with old boxes you’ve long since destroyed. Because destroying nodes/clients requires you to have knife configured on your machine, it isn’t an ideal solution for most developers. That’s why we wrote a script you can add to your crontab to periodically delete the old copies. Simply upload the **remove_nodes.sh** file to your Chef server (or any other computer with knife configured) and set it up as you would any other cron job.
