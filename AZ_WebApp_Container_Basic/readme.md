# Azure Web App Container Terraform Template

This deployment is simple and demonstrates the ability to create a container based Azure Web Application sourced off an image stored in my docker registry.  

## Components Provisioned

The following components are provisioned in Azure :

- Resource Group
- App Service Plan
- Azure Web Application
 
## Instructions for the template

At the very top of main.tf, you have local variables. You'll need add your own subscription ID, tenantID, and unique Web Application name. After that, you should be good to go. When I test, I like to put the files on a file share in Azure Cloud Shell since it comes with terraform installed. To see more details around this check out:

https://docs.microsoft.com/en-us/azure/cloud-shell/example-terraform-bash
