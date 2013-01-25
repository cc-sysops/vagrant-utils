$chefserver = "http://chef.example.com:4000"
$home = File.expand_path("~")
$user = ENV["USER"]
$time = (Time.now.getutc).to_i
$i = 0
$j = 0
$k = 0

def getNode
  box = $boxes[$i]
	if $multivm
  		if File.exist?(".node-#{box}")
  			puts "[node] Loading node for #{box}..."
  			$i += 1
  			return File.read(".node-#{box}")
  		else
  			node = "#{box}-#{$user}-#{$time}"
  			puts "[node] Using Chef Node: #{node}"
  			$i += 1
  			return node
  		end
  	else
	    if File.exist?(".node")
	    	puts "[node] Loading node for #{box}..."
	    	return File.read(".node")
	    else
	    	node = "#{box}-#{$user}-#{$time}"
	    	puts "[node] Using Chef Node: #{node}"
	    	return node
	    end
	end
end

def setNode
	box = $boxes[$j]
  	if $multivm
  		if !File.exist?(".node-#{box}")
  			File.open ".node-#{box}", "w" do |file|
  				node = "#{box}-#{$user}-#{$time}"
  			    puts "[node] Saving node to .node-#{box}..."
  			    file.write(node)
  			end
  		end
  		$j += 1
  	else
	    if !File.exist?(".node")
		    File.open ".node", "w" do |file|
		      node = "#{box}-#{$user}-#{$time}"
		      puts "[node] Saving node to .node..."
		      file.write(node)
		    end
	    end
	end
end

class NodeRegister
	def initialize app, env
		@app = app
	end

	def call env
		setNode
	end
end

class NodeReload
	def initialize app, env
		@app = app
	end

	def call env
		setNode
	end
end

class NodeRemove
  def initialize app, env
    @app = app
  end

  def call env
  	box = $boxes[$k]
  	if $multivm
  		if File.exist?(".node-#{box}")
  			puts "[node] Removing .node-#{box} file..."
  			File.delete(".node-#{box}")
  		end
  		$k += 1
	else
	    if File.exist?(".node")
	      puts "[node] Removing .node file..."
	      File.delete(".node")
	    end
	end
  end
end

Vagrant.actions[:up].insert_after(Vagrant::Action::VM::Boot, NodeRegister)

Vagrant.actions[:start].insert_after(Vagrant::Action::VM::Boot, NodeReload)

Vagrant.actions[:destroy].insert_after(Vagrant::Action::VM::Destroy, NodeRemove)