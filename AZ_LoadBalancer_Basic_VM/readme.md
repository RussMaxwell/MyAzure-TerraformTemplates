# Terraform with Azure Load Balancer

This deployment showcases Azure Load Balancer by putting it in front of two Azure Virtual Machines that are part of the same availability set.  The virtual machines are deployed with the following:

    1. Windows 2016 Server
    2. IIS Deployed
    3. Windows Firewall Inbound Port Rule allowing Port 80 traffic

In this scenario, inbound web traffic comes in from the internet to Azure Load Balancer and loadbalanced to one of the Azure Virtual Machines.  

## Components Provisioned

The following components are provisioned in Azure :

- Resource Group
- 1 Virtual Network (1 subnet and 1 Network Security Group)
- 2 Windows Virtual Machines
- Availability Set
- Azure Loadbalancer with Public IP Address

## Azure Load Balancer

Azure Load Balancer is provisioned using the basic SKU.  To make use of Azure Firewall, a load balance rule is created to route web traffic to the backend pool where both Virtual Machines are associated.  In addition, two nat rules are created to allow remote desktop to each virtual machine.  Atlanta VM is accessible via RDP by using the public IP of Azure Load Balancer with port 45200.  Boston VM is accessible via RDP by using the public IP of Azure Load balancer with port 14100.

## Instructions for the template

Within variables.tf, you'll need add your own subscription ID, tenantID, username, and a password for the virtual machines. After that, you should be good to go. When I test, I like to put the files on a Storage Account/file share that's used by Azure Cloud Shell.  Azure Cloud Shell comes with Terraform installed. To see more details around this check out:

https://docs.microsoft.com/en-us/azure/cloud-shell/example-terraform-bash
