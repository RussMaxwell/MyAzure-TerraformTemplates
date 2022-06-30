# Terraform with Azure Application Gateway

This deployment showcases Azure Load Balancer by putting it in front of two Azure Virtual Machines.  The virtual machines are deployed with the following:

    1. Windows 2016 Server
    2. IIS Deployed
    3. Windows Firewall Inbound Port Rule allowing Port 80 traffic

In this scenario, inbound web traffic comes in from the internet to Azure App Gateway and loadbalanced to one of the Azure Virtual Machines.  Both VM's are running a fresh install of IIS.  

## Components Provisioned

The following components are provisioned in Azure :

- Resource Group
- 1 Virtual Network (2 subnets and 1 Network Security Group)
- 2 Windows Virtual Machines (no public IPs)
- Azure Application Gateway with Static Public IP Address

## Azure Application Gateway

Azure Application Gateway is provisioned using the Standard_v2 SKU.  The App Gateway is associated with the Frontend subnet and tied to a public static IP.  The App Gateway is setup with a backend address pool containing both VM's NIC's. App Gateway Listener is setup to listen for port 80 traffic and a routing rule is setup to forward traffic to the backend pool.

## Instructions for the template

Within variables.tf, you'll need add your own subscription ID, tenantID, username, and a password for the virtual machines. After that, you should be good to go. When I test, I like to put the files on a Storage Account/file share that's used by Azure Cloud Shell.  Azure Cloud Shell comes with Terraform installed. To see more details around this check out:

https://docs.microsoft.com/en-us/azure/cloud-shell/example-terraform-bash
