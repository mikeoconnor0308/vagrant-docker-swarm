# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

auto = ENV['AUTO_START_SWARM'] || true
# TODO make this support secure connection.
guest_docker_port = ENV['MANAGER_DOCKER_PORT'] || 2375 
forward_docker_port = true
host_docker_port = ENV['DOCKER_PORT'] || 2375 

manager_ip = "192.168.10.2"

# Increase numworkers if you want more nodes
numworkers = 1

# Increase vmmemory if you want more memory in the vm's
vmmemory = 512
# Increase numcpu if you want more cpu's per vm
numcpu = 1

# Vagrant version requirement
Vagrant.require_version ">= 1.8.4"

instances = []

(1..numworkers).each do |n| 
  instances.push({:name => "worker#{n}", :ip => "192.168.10.#{n+2}"})
end

File.open("./hosts", 'w') { |file| 
  instances.each do |i|
    file.write("#{i[:ip]} #{i[:name]} #{i[:name]}\n")
  end
}



Vagrant.configure("2") do |config|
    config.vm.provider "virtualbox" do |v|
     	v.memory = vmmemory
  	v.cpus = numcpu
    end
    
    config.vm.define "manager" do |i|
      i.vm.box = "ubuntu/bionic64"
      i.vm.hostname = "manager"
      i.vm.network "private_network", ip: "#{manager_ip}"

      config.vm.provision 'ansible', run: 'always', type: :ansible_local do |ansible|
        ansible.galaxy_role_file = 'provision/requirements.yml'
        ansible.playbook = 'provision/docker.yml'
      end

      # i.vm.provision "shell", path: "./provision.sh"
      if forward_docker_port
        i.vm.network "forwarded_port", guest: guest_docker_port, host: guest_docker_port
        i.vm.provision "shell", path: "./provision_remote.sh", privileged: true, env: {"DOCKER_PORT" => "#{guest_docker_port}"}
      end
      if File.file?("./hosts") 
        i.vm.provision "file", source: "hosts", destination: "/tmp/hosts"
        i.vm.provision "shell", inline: "cat /tmp/hosts >> /etc/hosts", privileged: true
      end 
      if auto 
        i.vm.provision "shell", inline: "docker swarm init --advertise-addr #{manager_ip}"
        i.vm.provision "shell", inline: "docker swarm join-token -q worker > /vagrant/token"
      end
    end 

  instances.each do |instance| 
    config.vm.define instance[:name] do |i|
      i.vm.box = "ubuntu/bionic64"
      i.vm.hostname = instance[:name]
      i.vm.network "private_network", ip: "#{instance[:ip]}"

      config.vm.provision 'ansible', run: 'always', type: :ansible_local do |ansible|
        ansible.galaxy_role_file = 'provision/requirements.yml'
        ansible.playbook = 'provision/docker.yml'
      end   
       
      if File.file?("./hosts") 
        i.vm.provision "file", source: "hosts", destination: "/tmp/hosts"
        i.vm.provision "shell", inline: "cat /tmp/hosts >> /etc/hosts", privileged: true
      end 
      if auto
        i.vm.provision "shell", inline: "docker swarm join --advertise-addr #{instance[:ip]} --listen-addr #{instance[:ip]}:2377 --token `cat /vagrant/token` #{manager_ip}:2377"
      end
    end 
  end
end
