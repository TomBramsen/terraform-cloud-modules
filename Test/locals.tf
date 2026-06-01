locals {
  # Map T-shirt sizes to actual cloud VM SKUs / Flavors
  node_sku_mapping = {
    azure = {
      small  = "Standard_B2ms"
      medium = "Standard_D2s_v5"
      large  = "Standard_D4s_v5"
    }
    ovh = {
      small  = "b2-7"
      medium = "b2-15"
      large  = "d2-8"
    }
  }

  # Dynamically resolve the native SKU/Flavor name based on the active provider
  resolved_node_sku = lookup(
    local.node_sku_mapping[var.cloud_settings.cloud_provider],
    var.node_config.node_size,
    var.node_config.node_size # Fallback if a direct hardware string is passed
  )
}