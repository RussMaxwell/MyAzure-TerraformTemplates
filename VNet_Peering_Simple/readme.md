# Virtual Network Peering Simple - Terraform 

This terraform template deploys two Virtual Networks connected with Virtual Network Peering.  To validate communication, a virtual machine is provisioned in each Virtual Network.  A public IP is assigned to both Virtual Machines.  A simple test is to RDP into one virtual machine and then RDP from that VM to the remote Virtual Machine using its Private IP address.

## Components Provisioned

The following components are provisioned in Azure :

- 2 Resource Groups
- 2 Virtual Networks both peered
- 2 public IP addresses

## Instructions for the template

At the very top of main.tf, you have local variables. You'll need add your own subscription ID, tenantID. At the top of peeringSetup.tf, you have one local variable and will need to add a password for your Virtual Machines.  After that, you should be good to go. When I test, I like to put the files on a Storage Account/file share that's used by Azure Cloud Shell.  Azure Cloud Shell comes with Terraform installed. To see more details around this check out:

https://docs.microsoft.com/en-us/azure/cloud-shell/example-terraform-bash
