# Docker Swarm Vagrant

This is a Vagrantfile and ansible playbook for spinning up a docker swarm. Based on [vagrant-docker-swarm](https://github.com/tdi/vagrant-docker-swarm) by Dariusz Dwornikowski, modified to use ansible and expose API over TCP. A registry service is also created so you can host your own containers on the swarm.

# Customize

By default `vagrant up` spins up 2 machines: `manager`, `worker1`. You can adjust how many
workers you want in the `Vagrantfile`, by setting the `numworkers` variable. Manager, by default, has address "192.168.10.2", workers have consecutive ips. 

```ruby
numworkers = 2
```

If your provisioner is `Virtualbox`, you can modify the vm allocations for memory and cpu by changing these variables:

```ruby
vmmemory = 512
```

```ruby
numcpu = 1
```

# Run 

```bash
vagrant up 
```

`/etc/hosts` on every machine is populated with an IP address and a name of every other machine, so that names are resolved within the cluster. This mechanism is not idempotent, reprovisioning will append the hosts again. *TODO*: Switch to vagrant host plugin.

# Play

After starting the swarm you can verify the nodes have spun up with: 

```bash
vagrant ssh manager
```

```bash
vagrant@manager:~$ docker node ls
ID                           HOSTNAME  STATUS  AVAILABILITY  MANAGER STATUS
0rtuyz07e0wazmxvoed1llmx3 *  manager   Ready   Active        Leader
4mmca5rxrxxhb0tb7s5du5hpe    worker1   Ready   Active
```

The API is portforwarded by default on 2375, so you can control it from the host:

```
curl localhost:2375/services
[{"ID":"1jep4vx9stpoddvn6rzcg8s93","Version":{"Index":18},"CreatedAt":"2020-03-20T12:47:37.231297551Z","UpdatedAt":"2020-03-20T12:47:37.308790008Z","Spec":{"Name":"registry","Labels":{},"TaskTemplate":{"ContainerSpec":{"Image":"registry:2@sha256:7d081088e4bfd632a88e3f3bcd9e007ef44a796fddfe3261407a3f9f04abe1e7","Init":false,"DNSConfig":{},"Isolation":"default"},"Resources":{"Limits":{},"Reservations":{}},"Placement":{"Platforms":[{"Architecture":"amd64","OS":"linux"},{"OS":"linux"},{"Architecture":"arm64","OS":"linux"}]},"ForceUpdate":0,"Runtime":"container"},"Mode":{"Replicated":{"Replicas":1}},"EndpointSpec":{"Mode":"vip","Ports":[{"Protocol":"tcp","TargetPort":5000,"PublishedPort":5000,"PublishMode":"ingress"}]}},"Endpoint":{"Spec":{"Mode":"vip","Ports":[{"Protocol":"tcp","TargetPort":5000,"PublishedPort":5000,"PublishMode":"ingress"}]},"Ports":[{"Protocol":"tcp","TargetPort":5000,"PublishedPort":5000,"PublishMode":"ingress"}],"VirtualIPs":[{"NetworkID":"xsf859c182q1ujr4gxjjnay0c","Addr":"10.0.0.3/24"}]}}]
```

There is just one service running, the registry service, as expected. You can log in from the python API and start spinning things up! 
