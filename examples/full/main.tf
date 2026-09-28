# Discover the authenticated IAM user instead of requiring a personal user ID.
# Use token or username/password authentication with older provider versions.
data "opentelekomcloud_identity_auth_scope_v3" "current" {
  name = "kms-example"
}

module "kms" {
  source = "../.."

  key_alias             = "kms-full-example"
  key_description       = "KMS-generated key with rotation and a limited example grant"
  origin                = "kms"
  is_enabled            = true
  allow_cancel_deletion = false
  pending_days          = "30"
  rotation_enabled      = true
  rotation_interval     = 90

  tags = {
    environment = "example"
    managed_by  = "terraform"
  }

  kms_grant = {
    describe = {
      name              = "kms-example-describe"
      grantee_principal = data.opentelekomcloud_identity_auth_scope_v3.current.user_id
      operations        = ["describe-key"]
    }
  }
}
