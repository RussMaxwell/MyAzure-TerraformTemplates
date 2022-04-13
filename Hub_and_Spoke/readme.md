# Azure Hub and Spoke Terraform Template

This deployment showcases Azure Hub and Scope architecture.  It contains a Hub Virtual Network with a Scope Virtual Network connected via a Peering Connection.  The On-Premises environment is simulated in Azure with a Virtual Network called onprem-vnet.  The simulated on-premises Virtual Network has a site to site VPN connection established with the Hub and Hub Virtual Network has a site to site VPN Connection established with On-Premises Virtual Network.  After this environmnet is provisioned, a good test is to use Azure Bastion and connect to Spoke VM and disable the Windows Firewall and collect the private IP address.  Next, RDP to the On-Premises Virtual Machine and then launch a web browser and type in the private IP address of the virtual machine that's in the Spoke Virtual Network.

## Components Provisioned

The following components are provisioned in Azure :

- 3 Resource Groups (Hub, Spoke, and On-Premises)
- 3 Virtual Networks (Hub, Spoke, and On-Premises)
- 1 VM provisioned in On-Premises Vnet with Public IP
- 1 VM provisioned in Spoke VNet running IIS
- Azure Bastion in Hub Vnet
- Azure Firewall in Hub Vnet

## Azure Firewall Details

Azure Firewall is used to secure traffic between On-Premises and the Spoke Virtual Network.  For Example, only port 80 traffic coming from On-Premises network is allowed to the Spoke Virtual Network.  To make this magic happen, a route table is attached to the gateway subnet in the hub to route any inbound traffic destined for the Spoke Virtual Network to the private IP Address of the Azure Firewall.  In addition, Firewall allows traffic going out to internet from Spoke Virtual Network.

## Azure Bastion Details

Azure Bastion Service is provisioned in Hub Virtual Network to provide ability to RDP into Virtual Machine in Spoke Virtual Network.

## Instructions for the template

Within the variables.tf file, you'll need to update four variables.  Add your own subscription ID, tenantID, username and a password for the virtual machine. After that, you should be good to go. When I test, I like to put the files on a Storage Account/file share that's used by Azure Cloud Shell.  Azure Cloud Shell comes with Terraform installed. To see more details around this check out:

https://docs.microsoft.com/en-us/azure/cloud-shell/example-terraform-bash
