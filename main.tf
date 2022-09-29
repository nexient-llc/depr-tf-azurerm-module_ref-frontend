module "resource_name" {
  source = "github.com/nexient-llc/tf-module-resource_name.git?ref=0.2.0"

  for_each = var.resource_types

  logical_product_name  = var.logical_product_name
  region                = var.resource_group.location
  class_env             = var.class_env
  cloud_resource_type   = each.value.type
  instance_env          = var.instance_env
  instance_resource     = var.instance_resource
  maximum_length        = each.value.maximum_length
  use_azure_region_abbr = var.use_azure_region_abbr
}

module "resource_group" {
  source = "github.com/nexient-llc/tf-azurerm-module-resource_group.git?ref=0.1.0"

  resource_group      = var.resource_group
  resource_group_name = local.resource_group_name

  tags = local.tags

}

module "storage_account" {
  source = "github.com/nexient-llc/tf-azurerm-module-storage_account.git?ref=0.2.0"

  resource_group                         = local.resource_group
  storage_account_name                   = local.storage_account_name
  storage_account                        = var.storage_account
  storage_containers                     = var.storage_containers
  storage_shares                         = var.storage_shares
  storage_queues                         = var.storage_queues
  static_website                         = var.static_website
  enable_https_traffic_only              = var.enable_https_traffic_only
  access_tier                            = var.access_tier
  account_kind                           = var.account_kind
  blob_cors_rule                         = var.blob_cors_rule
  blob_delete_retention_policy           = var.blob_delete_retention_policy
  blob_versioning_enabled                = var.blob_versioning_enabled
  blob_change_feed_enabled               = var.blob_change_feed_enabled
  blob_last_access_time_enabled          = var.blob_last_access_time_enabled
  blob_container_delete_retention_policy = var.blob_container_delete_retention_policy
}

module "key_vault" {
  source = "github.com/nexient-llc/tf-azurerm-module-key_vault.git?ref=0.2.0"

  resource_group             = local.resource_group
  key_vault_name             = local.key_vault_name
  soft_delete_retention_days = var.kv_soft_delete_retention_days
  sku_name                   = var.kv_sku
  access_policies            = var.kv_access_policies
  certificates               = var.certificates
  secrets                    = var.secrets
  keys                       = var.keys

  custom_tags = local.tags
}

module "azure_cdn" {
  source = "github.com/nexient-llc/tf-azurerm-module-cdn.git?ref=0.1.0"

  resource_group                = local.resource_group
  cdn_profile_name              = local.cdn_profile_name
  sku                           = var.cdn_sku
  cdn_endpoint_name             = local.cdn_endpoint_name
  is_http_allowed               = var.is_cdn_http_allowed
  is_https_allowed              = var.is_cdn_https_allowed
  querystring_caching_behaviour = var.querystring_caching_behaviour
  optimization_type             = var.cdn_optimization_type
  origins                       = local.modified_origins
  delivery_rules                = var.cdn_delivery_rules
  custom_domain                 = var.custom_domain
  custom_user_managed_https     = local.custom_user_managed_https

  custom_tags = local.tags

  depends_on = [
    module.key_vault
  ]

}