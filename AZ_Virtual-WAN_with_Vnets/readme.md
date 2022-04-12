# Azure Virtual WAN Terraform Template

This deployment showcases Azure Virtual WAN by routing traffic between two connected Virtual Networks.  No S2S or Peering connections are setup between Azure Virtual Networks.  Instead, resources in both VNets are relying on Azure Virtual WAN to facilitate communication with resources that reside in the remote Virtual Network.  To test routing thru Azure Virtual WAN, a windows VM is setup in each VNet. One of the Virtual Machine's as a public IP so you can remote desktop into that VM.  Once inside the guest operating system of that virtual machine, you can then remote desktop using the private IP of the virtual machine in the remote virtual network.  

## Components Provisioned

The following components are provisioned in Azure :

- Resource Group
- 2 Virtual Networks
- 2 Virtual Machines (1 per Virtual Network)
- 1 Public IP Address assigned to a Virtual Machine
- 1 Azure Virtual WAN

## Azure Virtual WAN Details

To make use of Azure Virtual WAN, a Virtual WAN Hub is created with two virtual WAN Hub Connections (one to each VNET).  It's easy to setup but it can take some time to provision.
  
## Instructions for the template

Within the variables.tf file, you'll need to update four variables.  Add your own subscription ID, tenantID, username and a password for the virtual machine. After that, you should be good to go. When I test, I like to put the files on a file share in Azure Cloud Shell since it comes with terraform installed. To see more details around this check out:

https://docs.microsoft.com/en-us/azure/cloud-shell/example-terraform-bash
