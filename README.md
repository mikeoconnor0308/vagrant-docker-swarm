# Docker Swarm Vagrant

This is a Vagrantfile and ansibe playbook for spinning up a docker swarm. Based on [vagrant-docker-swarm](https://github.com/tdi/vagrant-docker-swarm) by Dariusz Dwornikowski, modified to use ansible and expose API over TCP.

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
[]
```

There are no services running, as expected. You can log in from the python API and start spinning things up! 
