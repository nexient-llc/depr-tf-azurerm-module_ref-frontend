#################################################
#Variables associated with resource naming module
##################################################

variable "logical_product_name" {
  type        = string
  description = "(Required) Name of the application for which the resource is created."
  nullable    = false

  validation {
    condition     = length(trimspace(var.logical_product_name)) <= 15 && length(trimspace(var.logical_product_name)) > 0
    error_message = "Length of the logical product name must be between 1 to 15 characters."
  }
}

variable "class_env" {
  type        = string
  description = "(Required) Environment where resource is going to be deployed. For ex. dev, qa, uat"
  nullable    = false

  validation {
    condition     = length(trimspace(var.class_env)) <= 15 && length(trimspace(var.class_env)) > 0
    error_message = "Length of the environment must be between 1 to 15 characters."
  }

  validation {
    condition     = length(regexall("\\b \\b", var.class_env)) == 0
    error_message = "Spaces between the words are not allowed."
  }
}

variable "instance_env" {
  type        = number
  description = "Number that represents the instance of the environment."
  default     = 0

  validation {
    condition     = var.instance_env >= 0 && var.instance_env <= 999
    error_message = "Instance number should be between 1 to 999."
  }
}


variable "instance_resource" {
  type        = number
  description = "Number that represents the instance of the resource."
  default     = 0

  validation {
    condition     = var.instance_resource >= 0 && var.instance_resource <= 100
    error_message = "Instance number should be between 1 to 100."
  }
}

variable "use_azure_region_abbr" {
  description = "Whether to use region abbreviation e.g. eastus -> eus"
  type        = bool
  default     = false
}

variable "resource_types" {
  description = "Map of cloud resource types to be used in this module"
  type = map(object({
    type           = string
    maximum_length = number
  }))

  default = {
    "resource_group" = {
      type           = "rg"
      maximum_length = 63
    }
    "cdn_profile" = {
      type           = "cdn"
      maximum_length = 60
    }
    "cdn_endpoint" = {
      type           = "ep"
      maximum_length = 63
    }
    "storage_account" = {
      type           = "sa"
      maximum_length = 24
    }
    "key_vault" = {
      type           = "kv"
      maximum_length = 24
    }
  }
}

#################################################
#Variables associated with resource group module
##################################################
variable "resource_group" {
  description = "resource group primitive options"
  type = object({
    location = string
  })
  validation {
    condition     = length(regexall("\\b \\b", var.resource_group.location)) == 0
    error_message = "Spaces between the words are not allowed."
  }
}

########################################################
# Variables associated with storage account module
########################################################

variable "storage_account" {
  description = "storage account config"
  type = object({
    account_tier             = string
    account_replication_type = string
    tags                     = map(string)
  })
}

variable "storage_containers" {
  description = "map of storage container configs, keyed polymorphically"
  type = map(object({
    name                  = string
    container_access_type = string
  }))
  default = {}
}

variable "storage_shares" {
  description = "map of storage file shares configs, keyed polymorphically"
  type = map(object({
    name  = string
    quota = number
  }))
  default = {}
}

variable "storage_queues" {
  description = "map of storage queue configs, keyed polymorphically"
  type = map(object({
    name = string
  }))
  default = {}
}

variable "static_website" {
  description = "The static website details if the storage account needs to be used as a static website"
  type = object({
    index_document     = string
    error_404_document = string
  })
  default = null
}

variable "enable_https_traffic_only" {
  description = "Boolean flag that forces HTTPS traffic only"
  type        = bool
  default     = true
}

variable "access_tier" {
  description = "Choose between Hot or Cool"
  type        = string
  default     = "Hot"

}

variable "account_kind" {
  description = "Defines the kind of account"
  type        = string
  default     = "StorageV2"
}

# Blob related inputs

variable "blob_cors_rule" {
  description = "Blob cors rules"
  type = map(object({
    allowed_headers    = list(string)
    allowed_methods    = list(string)
    allowed_origins    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = number
  }))

  default = null
}

variable "blob_delete_retention_policy" {
  description = "Number of days the blob should be retained. Set 0 to disable"
  type        = number
  default     = 0
}

variable "blob_versioning_enabled" {
  description = "Is blob versioning enabled for blob"
  type        = bool
  default     = false
}

variable "blob_change_feed_enabled" {
  description = "Is the blobl service properties for change feed enabled for blob"
  type        = bool
  default     = false
}

variable "blob_last_access_time_enabled" {
  description = "Is the last access time based tracking enabled"
  type        = bool
  default     = false
}

variable "blob_container_delete_retention_policy" {
  description = "Specify the number of days that the container should be retained. Set 0 to disable"
  type        = number
  default     = 0
}

########################################################
# Variables associated with key vault module
########################################################

variable "soft_delete_retention_days" {
  description = "Number of retention days for soft delete"
  type        = number
  default     = 7
}

variable "key_vault_sku" {
  description = "SKU for the key vault - standard or premium"
  type        = string
  default     = "standard"
}

variable "key_vault_access_policies" {
  description = "Additional Access policies for the vault except the current user which are added by default"
  type = map(object({
    object_id               = string
    tenant_id               = string
    key_permissions         = list(string)
    certificate_permissions = list(string)
    secret_permissions      = list(string)
    storage_permissions     = list(string)
  }))

  default = {}
}

# Variables to import pre existing certificates to the key vault
variable "certificates" {
  description = "List of certificates to be imported. The pfx files should be present in the root of the module (path.root) and its name denoted as certificate_name"
  type = map(object({
    certificate_name = string
    password         = string
  }))

  default = {}
}

# Variables to import secrets
variable "secrets" {
  description = "List of secrets (name and value)"
  type        = map(string)
  default     = {}
}

# Variables to import Keys
variable "keys" {
  description = "List of keys to be created in key vault. Name of the key is the key of the map"
  type = map(object({
    key_type = string
    key_size = number
    key_opts = list(string)
  }))
  default = {}
}

variable "custom_tags" {
  description = "Custom Tags"
  type        = map(string)
  default     = {}
}

########################################################
# Variables associated with CDN module
########################################################

variable "cdn_sku" {
  description = "SKU of the CDN profile. Must be either \"Standard_Microsoft\" or \"Standard_Akamai\" or \"Standard_ChinaCdn\" or \"Standard_Verizon\" or \"Premium_Verizon\""
  type        = string
  default     = "Standard_Microsoft"
}

variable "is_cdn_http_allowed" {
  description = "Is http allowed for the endpoint"
  type        = bool
  default     = true
}

variable "is_cdn_https_allowed" {
  description = "Is https allowed for the endpoint"
  type        = bool
  default     = true
}

variable "querystring_caching_behaviour" {
  description = "Among the values IgnoreQueryString, BypassCaching and UseQueryString"
  type        = string
  default     = "IgnoreQueryString"
  validation {
    condition     = (contains(["IgnoreQueryString", "BypassCaching", "UseQueryString"], var.querystring_caching_behaviour))
    error_message = "The querystring_caching_behaviour must be either \"IgnoreQueryString\" or \"BypassCaching\" or \"UseQueryString\"."
  }
}

variable "optimization_type" {
  description = "Optimization type. Possible values:  DynamicSiteAcceleration, GeneralMediaStreaming, GeneralWebDelivery, LargeFileDownload and VideoOnDemandMediaStreaming"
  type        = string
  default     = "GeneralWebDelivery"
}

# Currently only single origin is supported by terraform although multi origin is supported by Azure with origin Groups.
variable "origins" {
  description = "A list of allowed Origins. Currently only 1 origin is supported by Azure for Microsoft CDN. Possible values for hostname are domain name, ipv4 or ipv6 address, Storage account or App Service endpoints. Currently supports only Storage Account or App Service"
  type = list(object({
    name       = string
    hostname   = string
    http_port  = number
    https_port = number
    type       = string
  }))
}

variable "delivery_rules" {
  description = "List of delivery rules for the endpoint. Currently supports only URL Rewrite and Redirect Actions"
  type        = any
  default     = {}
}

# Variables related to custom domain

variable "custom_domain" {
  description = "Inputs related to custom domain. cname_record should be without the zone name. cname_record, dns_zone and dns_rg are required if enable_custom_domain = true. If create_cname_record = false, user should manually create the cname record in the dns zone in the format <cdn_endpoint_name>.azureedge.net"
  type = object({
    enable_custom_domain = bool
    create_cname_record  = bool
    cname_record         = string
    dns_zone             = string
    dns_rg               = string
  })
  default = {
    enable_custom_domain = false
    create_cname_record  = false
    cname_record         = ""
    dns_zone             = ""
    dns_rg               = ""
  }
}

# Variables related to TLS

variable "enable_user_managed_https" {
  description = "Whether to enable HTTPS for the custom domain."
  type        = bool
  default     = false
}

variable "certificate_secret_name" {
  description = "The name of the certificate secret for custom domain in the key-vault. Optional, required only when enable_user_managed_https = true"
  type        = string
  default     = ""
}
