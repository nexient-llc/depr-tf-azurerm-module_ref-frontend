logical_product_name = "vvcfrontend"
class_env = "prod"
resource_group = {
  location = "eastus"
}

use_azure_region_abbr = true

# Storage account
storage_account = {
  account_tier = "Standard"
  account_replication_type = "LRS"
  tags = {
    "provisioner" = "Terraform"
  }
}

blob_cors_rule = {
  cors = {
  allowed_headers = ["Content-Type"]
  allowed_methods = ["GET", "PUT", "POST"]
  allowed_origins = ["nexient.com"]
  exposed_headers = ["Content-Type", "Max-Age"]
  max_age_in_seconds = 3600
  }
  cors2 = {
  allowed_headers = ["Content-Type"]
  allowed_methods = ["GET", "PUT"]
  allowed_origins = ["nexient.com"]
  exposed_headers = ["Content-Type", "Max-Age"]
  max_age_in_seconds = 3600
  }
}

storage_containers = {
  test = {
    name = "testdata"
    container_access_type = "blob"
  }
}

static_website = {
  index_document = "index.html"
  error_404_document = "error.html"
}

# Key Vault

kv_access_policies = {
    # Access Policy for AzureFrontDoor-Cdn, mandatory for access certs from Key Vault. The Object ID is copied from an existing KeyVault which had this access policy added
    "azure-frontdoor-cdn" = {
        tenant_id = ""
        object_id = "a84f0a79-b9df-4c8f-bc8d-309eed0402b4"
        certificate_permissions = [
        "Get"
        ]
        key_permissions = [
            "Get", "List", "Delete", "Create", "Purge"
        ]
        secret_permissions = [
            "Get", "List", "Delete", "Set", "Purge"
        ]
        storage_permissions = [
            "Get", "List", "Delete", "Set"
        ]
    }
}

certificates = {
    "azurecdn-dsahoo-com" = {
        certificate_name = "azurecdn.dsahoo.com.pfx"
        password = ""
    }
}

secrets = {
    db_name = "vanilla-vc-dev"
    password = "my-secret-password"
    username = "my-db-username"
}

# CDN

origins = [
  {
    name       = "primary"
    # hostname is empty as it will pull the value from the storage_account variable defined above
    hostname   = ""
    http_port  = 80
    https_port = 443
    type       = "Storage Account"
  }
]

cdn_delivery_rules = {
  RedirectRules = {
    properties = {
      name  = "RedirectRules"
      order = 1
    }
    
    request_scheme_condition = {
      match_values = ["HTTP"]
      operator     = "Equal"
    }

    url_redirect_action = {
      redirect_type = "PermanentRedirect"
      protocol      = "Https"
      hostname      = "azurecdn.dsahoo.com"
    }
  },
  RewriteRules = {
    properties = {
      name  = "ReWriteRules"
      order = 2
    }
    
    request_uri_condition = {
      negate_condition = false
      operator         = "Any"
    }

    url_path_condition = {
      match_values = [
        "."
      ]
      negate_condition = true
      operator         = "Contains"
    }

    url_rewrite_action = {
      destination             = "/index.html"
      preserve_unmatched_path = false
      source_pattern          = "/"
    }
  }
}

custom_domain = {
  enable_custom_domain = true
  create_cname_record = false
  # Make sure the cname_record exists 
  cname_record = "azurecdn.dsahoo.com"
  # Can be empty when cname_record is fqdn
  dns_zone = ""
  dns_rg = ""
}

enable_user_managed_https = true
# secret name must exist in key-vault certificates above
certificate_secret_name = "azurecdn-dsahoo-com"