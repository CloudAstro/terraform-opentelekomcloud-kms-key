variable "key_alias" {
  type        = string
  nullable    = false
  description = "Required key alias. Changing the alias updates the existing key."

  validation {
    condition     = length(trimspace(var.key_alias)) > 0
    error_message = "key_alias must not be empty or whitespace."
  }
}

variable "key_description" {
  type        = string
  default     = null
  description = "Optional description of the KMS key."
}

variable "origin" {
  type        = string
  default     = "kms"
  nullable    = false
  description = "Key material source: kms for KMS-generated material or external for imported material. Choose before creating the key; changing origin is not a supported key conversion."

  validation {
    condition     = contains(["kms", "external"], var.origin)
    error_message = "origin must be kms or external."
  }
}

variable "realm" {
  type        = string
  default     = null
  description = "Optional provider realm override. Omit for provider/service placement; do not hard-code a realm from another region. Changing realm replaces the key."

  validation {
    condition     = var.realm == null ? true : length(trimspace(var.realm)) > 0
    error_message = "realm must be null or non-empty."
  }
}

variable "allow_cancel_deletion" {
  type        = bool
  default     = null
  description = "Allow the provider to cancel pending deletion. This is not a prevent-destroy setting. Omit to retain the provider default."
}

variable "pending_days" {
  type        = string
  default     = null
  description = "Deletion waiting period, 7–1096 whole days. String type is retained for compatibility with the provider and existing callers. Omit for the provider default of 7 days."

  validation {
    condition = var.pending_days == null ? true : try(
      can(regex("^[0-9]+$", var.pending_days)) && tonumber(var.pending_days) >= 7 && tonumber(var.pending_days) <= 1096 && floor(tonumber(var.pending_days)) == tonumber(var.pending_days), false
    )
    error_message = "pending_days must be null or a whole number from 7 to 1096."
  }
}

variable "is_enabled" {
  type        = bool
  default     = null
  description = "Optional enabled state, defaulting to true in the provider. Leave null when first creating an external-origin key."
}

variable "rotation_enabled" {
  type        = bool
  default     = null
  description = "Enable automatic rotation for KMS-generated keys. External-origin keys do not support automatic KMS rotation. Supply rotation_interval when enabling rotation."

  validation {
    condition     = var.origin != "external" || var.rotation_enabled != true
    error_message = "Automatic rotation cannot be enabled for external-origin keys."
  }
}

variable "rotation_interval" {
  type        = number
  default     = null
  description = "Rotation interval in whole days, 30–365. Set only with rotation_enabled = true."

  validation {
    condition     = var.rotation_interval == null ? true : var.rotation_interval >= 30 && var.rotation_interval <= 365 && floor(var.rotation_interval) == var.rotation_interval
    error_message = "rotation_interval must be null or a whole number from 30 to 365."
  }

  validation {
    condition     = var.rotation_enabled == true ? var.rotation_interval != null : var.rotation_interval == null
    error_message = "Supply rotation_interval when rotation is enabled; omit it otherwise."
  }
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "Optional tags for the KMS key."
}

variable "kms_grant" {
  type = map(object({
    name               = optional(string)
    grantee_principal  = string
    operations         = set(string)
    retiring_principal = optional(string)
  }))
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
Grants keyed by stable resource labels. grantee_principal is an existing IAM user
ID. operations is required and must explicitly list the permissions to grant.
The key ID is always taken from the key created by this module. Explicit null
omits grants. Changing grant attributes replaces that grant.
DESCRIPTION

  validation {
    condition = alltrue([for grant in var.kms_grant : try(
      length(trimspace(grant.grantee_principal)) > 0 &&
      (grant.retiring_principal == null ? true : length(trimspace(grant.retiring_principal)) > 0) &&
      (grant.name == null ? true : can(regex("^[a-zA-Z0-9:/_-]{1,255}$", grant.name))), false)
    ])
    error_message = "Grants require a non-empty grantee_principal; optional names must match ^[a-zA-Z0-9:/_-]{1,255}$ and retiring principals must not be blank."
  }

  validation {
    condition = alltrue([for grant in var.kms_grant : try(length(grant.operations) > 0 && alltrue([
      for operation in grant.operations : contains([
        "create-datakey", "create-datakey-without-plaintext", "encrypt-datakey",
        "decrypt-datakey", "describe-key", "create-grant", "retire-grant"
      ], operation)
    ]), false)])
    error_message = "Each grant must contain at least one supported KMS operation."
  }
}

variable "kms_key_material" {
  type = map(object({
    encrypted_key_material = string
    expiration_time        = optional(string)
    import_token           = string
  }))
  default     = {}
  nullable    = false
  sensitive   = true
  description = <<DESCRIPTION
At most one import for this module's external-origin key, keyed by a stable,
non-secret resource label. Supply Base64-wrapped encrypted_key_material and a
matching import_token obtained for this key. expiration_time, if set, is a future
Unix timestamp in seconds. The API checks expiry. Explicit null omits imports.
Values are sensitive but are still stored in Terraform state. This module does
not generate, wrap or retain a backup of the original plaintext key material.
DESCRIPTION

  validation {
    condition     = length(var.kms_key_material) <= 1
    error_message = "Only one key material resource may manage this key."
  }

  validation {
    condition     = length(var.kms_key_material) == 0 || var.origin == "external"
    error_message = "kms_key_material requires origin = external."
  }

  validation {
    condition = alltrue([for material in var.kms_key_material : try(
      length(trimspace(material.encrypted_key_material)) > 0 && length(trimspace(material.import_token)) > 0, false)
    ])
    error_message = "Imported material requires non-empty encrypted_key_material and import_token."
  }

  validation {
    condition = alltrue([for material in var.kms_key_material : try(material.expiration_time == null ? true :
      can(regex("^[0-9]+$", material.expiration_time)) && tonumber(material.expiration_time) > 0 && floor(tonumber(material.expiration_time)) == tonumber(material.expiration_time), false)
    ])
    error_message = "expiration_time must be null or a positive Unix timestamp in whole seconds."
  }
}
