locals {
  resource_group_name  = module.resource_name["resource_group"].recommended_per_length_restriction
  cdn_profile_name     = module.resource_name["cdn_profile"].recommended_per_length_restriction
  cdn_endpoint_name    = module.resource_name["cdn_endpoint"].recommended_per_length_restriction
  key_vault_name       = module.resource_name["key_vault"].recommended_per_length_restriction
  storage_account_name = module.resource_name["storage_account"].lower_case

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
}