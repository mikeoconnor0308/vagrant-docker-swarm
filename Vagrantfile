# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.



manager_ip = "192.168.10.2"

numworkers = 1
vmmemory = 512
numcpu = 1

# TODO make this support secure connection.
guest_docker_port = ENV['MANAGER_DOCKER_PORT'] || 2375 
host_docker_port = ENV['DOCKER_PORT'] || 2375 

# Vagrant version requirement
Vagrant.require_version ">= 1.8.4"


instances = []

(1..numworkers).each do |n| 
  instances.push({:name => "worker#{n}", :ip => "192.168.10.#{n+2}"})
end


# TODO switch to using vagrant host plugin?
require 'fileutils'

dirname = './tmp'
unless File.directory?(dirname)
  FileUtils.mkdir_p(dirname)
end

File.open("./tmp/hosts", 'w') { |file| 
  instances.each do |i|
    file.write("#{i[:ip]} #{i[:name]} #{i[:name]}\n")
  end
}

groups = {
  "managers" => ["manager"],
  "workers" => ["worker[1:#{numworkers}]"]
}

Vagrant.configure("2") do |config|
    config.vm.provider "virtualbox" do |v|
     	v.memory = vmmemory
  	  v.cpus = numcpu
    end
    
    config.vm.define "manager" do |manager|
      manager.vm.box = "ubuntu/bionic64"
      manager.vm.hostname = "manager"
      manager.vm.network "private_network", ip: "#{manager_ip}"
      manager.vm.network "forwarded_port", guest: guest_docker_port, host: host_docker_port

      if File.file?("./hosts") 
        manager.vm.provision "file", source: "./tmp/hosts", destination: "/tmp/hosts"
        manager.vm.provision "shell", inline: "cat /tmp/hosts >> /etc/hosts", privileged: true
      end 

      manager.vm.provision 'ansible', run: 'always', type: :ansible_local do |ansible|
        ansible.galaxy_role_file = 'provision/requirements.yml'
        ansible.verbose = 'v'
        ansible.playbook = 'provision/swarm.yml'
        ansible.extra_vars = {
          docker_port: guest_docker_port,
          advertise_address: manager_ip
        }
        ansible.groups = groups
      end
      # We need to pass this token from one playbook to another, and securely.
      manager.vm.provision "shell", inline: "docker swarm join-token -q worker > /vagrant/tmp/token"
    end 

  instances.each do |instance| 
    config.vm.define instance[:name] do |worker|
      worker.vm.box = "ubuntu/bionic64"
      worker.vm.hostname = instance[:name]
      worker.vm.network "private_network", ip: "#{instance[:ip]}"

      if File.file?("./hosts") 
        worker.vm.provision "file", source: "hosts", destination: "/tmp/hosts"
        worker.vm.provision "shell", inline: "cat /tmp/hosts >> /etc/hosts", privileged: true
      end 

      worker.vm.provision 'ansible', run: 'always', type: :ansible_local do |ansible|
        ansible.galaxy_role_file = 'provision/requirements.yml'
        ansible.playbook = 'provision/swarm.yml'
        ansible.extra_vars = {
          worker_ip: instance[:ip],
          manager_ip: manager_ip
        }
        ansible.groups = groups
      end
      # Is there a way to pass the swarm token variable to ansible?
      worker.vm.provision "shell", inline: "docker swarm join --advertise-addr #{instance[:ip]} --listen-addr #{instance[:ip]}:2377 --token `cat /vagrant/tmp/token` #{manager_ip}:2377"
    end 
  end
end


