# Terraform with Azure Firewall

This deployment showcases Azure Firewall by putting it in front of an Azure Virtual Machine to secure inbound and outbound traffic. In this scenario, inbound traffic comes in from the internet to the Azure Firewall (public IP) destined for an Azure VM. The Azure VM is only equipped with a Private IP Address. Outbound traffic is traffic coming from the Azure VM out to the Internet. This terrafrom template includes routing setup within Azure so that all external requests are forwarded to the Azure Firewall. For Example, web traffic generated on the Azure VM is first routed to the firewall and out to the internet.

## Components Provisioned

The following components are provisioned in Azure :

- Resource Group
- Windows Virtual Machine
- Virtual Network with two subnets
- Azure Firewall with Public IP Address
- Route Table that's associated to subnet

## Azure Firewall Rules

To make use of Azure Firewall, two rules are created to handle traffic. From my local pc, I want to RDP to the Azure VM using the Public IP Address of the firewall. I'm using a DNat rule to forward all traffic going to port 4000 to the private IP of the Azure VM on port 3389. For outbound traffic, I have a rule that allows http/https traffic coming from the Azure VNet to the internet. It's locked down to only allow requests to randomsite.com so requests to randomsite.org or randomsite.gov will be blocked by the firewall.  
  
## Instructions for the template

At the very top of main.tf, you have local variables. You'll need add your own subscription ID, tenantID, and a password for the virtual machine. After that, you should be good to go. When I test, I like to put the files on a Storage Account/file share that's used by Azure Cloud Shell.  Azure Cloud Shell comes with Terraform installed. To see more details around this check out:

https://docs.microsoft.com/en-us/azure/cloud-shell/example-terraform-bash
