# Azure Web Application with SQL Terraform Template

This deployment showcases Azure Web Application setup as a Front-End connected to an Azure SQL DB acting as a backend.  This deployment is built for hosting an ASP.Net core application that uses Azure SQL Database as a backend.  For Example, you should have no problems deploying the following Sample Application from step 1 here:

https://docs.microsoft.com/en-us/azure/app-service/tutorial-dotnetcore-sqldb-app?tabs=azure-portal%2Cvisualstudio-deploy%2Cdeploy-instructions-azure-portal%2Cazure-portal-logs%2Cazure-portal-resources

## Components Provisioned

The following components are provisioned in Azure :

- 1 Resource Group
- 1 App Service Plan
- 1 Web Application
- 1 Azure SQL Server
- 1 Azure SQL DB

## Azure ASP.Net Core Application Details

To deploy the ASP.NET Core Sample Web Application, you'll need to follow steps 1, 4, and 6 from the above article. I used Visual Studio Code to deploy the Sample Web Application and may post a blog with additional details soon.
  
## Instructions for the template

Within the variables.tf file, you'll need to update four variables.  You need to add the following:

- SubscriptionID
- TenantID
- unique web application name
- sql server name
- your public client IP (assuming you will deploy the sample web application)
- Password for SQL Auth

Note: Lots of websites exists for obtaining your public IP.

After that, you should be good to go. When I test, I like to put the files on a Storage Account/file share that's used by Azure Cloud Shell.  Azure Cloud Shell comes with Terraform installed. To see more details around this check out:

https://docs.microsoft.com/en-us/azure/cloud-shell/example-terraform-bash
