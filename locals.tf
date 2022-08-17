locals {
  resource_group_name  = module.resource_name["resource_group"].recommended_per_length_restriction
  cdn_profile_name     = module.resource_name["cdn_profile"].recommended_per_length_restriction
  cdn_endpoint_name    = module.resource_name["cdn_endpoint"].recommended_per_length_restriction
  key_vault_name       = module.resource_name["key_vault"].recommended_per_length_restriction
  storage_account_name = length(module.resource_name["storage_account"].lower_case) > var.resource_types["storage_account"].maximum_length ? module.resource_name["storage_account"].recommended_per_length_restriction : module.resource_name["storage_account"].lower_case

  resource_group = {
    location = var.resource_group.location
    name     = module.resource_group.resource_group.name
  }

  storage_account = {
    name    = local.storage_account_name
    rg_name = module.resource_group.resource_group.name
  }

  default_tags = {
    provisioner = "Terraform"
  }

  tags = merge(var.custom_tags, local.default_tags)

  # Primary origin is always the storage account provisioned as a dependent storage account module (module.storage_account.storage_account)
  primary_origin          = element(var.origins, 0)
  other_origins           = length(var.origins) > 1 ? slice(var.origins, 1, length(var.origins)) : []
  modified_primary_origin = merge(local.primary_origin, { hostname = nonsensitive(module.storage_account.storage_account.primary_web_host) })
  modified_origins        = concat([local.modified_primary_origin], local.other_origins)

  # The key_vault_name and key_vault_rg needs to be populated from other dependent modules
  custom_user_managed_https = {
    enable_custom_https     = var.enable_user_managed_https
    key_vault_name          = module.key_vault.key_vault_name
    key_vault_rg            = local.resource_group_name
    certificate_secret_name = var.certificate_secret_name
  }
}