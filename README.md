# Technical test 2 #
This Vagrant test is done with puppet, it deploys the machines
passing by the constant GLOBAL_FACTS as puppet facts
and creating the vm with the behaviour defined on HOSTS.

The parameters that a guest have:
 * exposed - if it's true, the port 80 will be exposed, bridged through the port 80 of the physical machine.
 * hostname - hostname of the guest
 * role - this is the role that will be passed to puppet as a facter with the name instance_role
if you have the class on puppet, directory puppet/modules/instance_roles/manifests/roles/ the 
guest will apply the class automatically on up or provision

## Installation ##
Clone the repo:
```
git clone https://github.com/temp-omarti/test-2.git test-2
```
Install the submodules:
```
cd test-2
git submodule init
git submodule update
```
If you have vagrant installed with Virtualbox, let's start!:
```
vagrant up
```
If you don't have Virtualbox, please check another box for your virtualitzation environment.

With this you will have a publify published on the port 80 of your physical host.

Configure your publify, and start writing posts! 

Enjoy it! ;)
