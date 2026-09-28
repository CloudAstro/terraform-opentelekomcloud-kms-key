output "kms_key" {
  value       = opentelekomcloud_kms_key_v1.kms_key
  description = "Key metadata object, including id, key_alias, key_state, realm and scheduled_deletion_date. Does not contain the plaintext key. This output describes the key resource and does not wait for optional material import."
}

output "kms_grant" {
  value       = opentelekomcloud_kms_grant_v1.this
  description = "Grant objects keyed by the kms_grant input labels. Empty when no grants are configured."
}

output "key_material" {
  value       = opentelekomcloud_kms_key_material_v1.this
  sensitive   = true
  description = "Sensitive import resource objects keyed by kms_key_material labels; includes import inputs and status. Empty when no material is imported."
}
