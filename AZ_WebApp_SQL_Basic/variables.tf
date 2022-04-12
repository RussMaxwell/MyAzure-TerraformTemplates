variable "subscriptionID" {
    type=string
    default = "<input-your-subscriptionID>"
}

variable "tenantID" {
    type=string
    default = "<input-your-tenantID>"
}

variable "prefix-web" {
    type=string
    default = "Contoso"
}

variable "webapp-name" {
    type=string
    default = "<input-unique-webappName>"
}

variable "sqlservername" {
    type=string
    default = "<input-SqlServer-name>"
}

variable "clientIP" {
    type=string
    default = "<input-publicfacing-IPaddress>"
}

variable "psswrd" {
    type=string
    default = "<input-sqlAuth-password>"
}