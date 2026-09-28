resource "opentelekomcloud_kms_key_v1" "kms_key" {
  allow_cancel_deletion = var.allow_cancel_deletion
  key_alias             = var.key_alias
  key_description       = var.key_description
  origin                = var.origin
  realm                 = var.realm
  pending_days          = var.pending_days
  is_enabled            = var.is_enabled
  rotation_interval     = var.rotation_interval
  rotation_enabled      = var.rotation_enabled
  tags                  = var.tags
}

resource "opentelekomcloud_kms_grant_v1" "this" {
  for_each = var.kms_grant

  key_id             = opentelekomcloud_kms_key_v1.kms_key.id
  name               = each.value.name
  grantee_principal  = each.value.grantee_principal
  operations         = each.value.operations
  retiring_principal = each.value.retiring_principal

  depends_on = [opentelekomcloud_kms_key_material_v1.this]
}

resource "opentelekomcloud_kms_key_material_v1" "this" {
  # Only resource labels are public; import values retain their sensitive marks.
  for_each = nonsensitive(toset(keys(var.kms_key_material)))

  encrypted_key_material = var.kms_key_material[each.key].encrypted_key_material
  expiration_time        = var.kms_key_material[each.key].expiration_time
  import_token           = var.kms_key_material[each.key].import_token
  key_id                 = opentelekomcloud_kms_key_v1.kms_key.id
}
