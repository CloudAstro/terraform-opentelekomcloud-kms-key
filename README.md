<!-- BEGINNING OF PRE-COMMIT-OPENTOFU DOCS HOOK -->
# OpenTelekomCloud KMS Key Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE)

This module manages one OTC customer-managed key, optional grants and an optional
external key material import. Existing resource addresses and output names are
retained for callers of the original module.

# Features

- **Key Management**: Alias, description, enabled state, deletion waiting period and tags.
- **Rotation**: Configurable automatic rotation for KMS-generated keys.
- **Grants**: Explicit permissions for existing IAM users.
- **External Material**: One sensitive import resource for an external-origin key.
- **Validation**: Origin, deletion period, rotation settings, grants and import constraints.

# Setup Requirements

Configure OTC authentication and region through supported provider environment
variables such as `OS_AUTH_URL`, `OS_USERNAME`, `OS_PASSWORD`, `OS_DOMAIN_NAME`,
`OS_PROJECT_NAME` and `OS_REGION`. Neither example contains personal IDs,
credentials, a fixed region or required input variables.

The full example discovers the currently authenticated IAM user. Use token or
username/password authentication with older provider versions; permanent AK/SK
support in that data source depends on the provider version. Temporary AK/SK
credentials are not supported by the auth-scope data source.

# Example Usage

The [default example](examples/default/main.tf) creates a minimal KMS-generated
key. The [full example](examples/full/main.tf) adds rotation, a deletion waiting
period, tags and a describe-only grant to the authenticated user. KMS generates
the key material, so these examples do not generate or wrap plaintext keys locally:

```hcl
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
```
<!-- markdownlint-disable MD033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12 |
| <a name="requirement_opentelekomcloud"></a> [opentelekomcloud](#requirement\_opentelekomcloud) | >= 1.36.35 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_opentelekomcloud"></a> [opentelekomcloud](#provider\_opentelekomcloud) | >= 1.36.35 |

## Resources

| Name | Type |
|------|------|
| [opentelekomcloud_kms_grant_v1.this](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/kms_grant_v1) | resource |
| [opentelekomcloud_kms_key_material_v1.this](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/kms_key_material_v1) | resource |
| [opentelekomcloud_kms_key_v1.kms_key](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/kms_key_v1) | resource |

<!-- markdownlint-disable MD013 -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_key_alias"></a> [key\_alias](#input\_key\_alias) | Required key alias. Changing the alias updates the existing key. | `string` | n/a | yes |
| <a name="input_allow_cancel_deletion"></a> [allow\_cancel\_deletion](#input\_allow\_cancel\_deletion) | Allow the provider to cancel pending deletion. This is not a prevent-destroy setting. Omit to retain the provider default. | `bool` | `null` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Optional enabled state, defaulting to true in the provider. Leave null when first creating an external-origin key. | `bool` | `null` | no |
| <a name="input_key_description"></a> [key\_description](#input\_key\_description) | Optional description of the KMS key. | `string` | `null` | no |
| <a name="input_kms_grant"></a> [kms\_grant](#input\_kms\_grant) | Grants keyed by stable resource labels. grantee\_principal is an existing IAM user<br/>ID. operations is required and must explicitly list the permissions to grant.<br/>The key ID is always taken from the key created by this module. Explicit null<br/>omits grants. Changing grant attributes replaces that grant. | <pre>map(object({<br/>    name               = optional(string)<br/>    grantee_principal  = string<br/>    operations         = set(string)<br/>    retiring_principal = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_kms_key_material"></a> [kms\_key\_material](#input\_kms\_key\_material) | At most one import for this module's external-origin key, keyed by a stable,<br/>non-secret resource label. Supply Base64-wrapped encrypted\_key\_material and a<br/>matching import\_token obtained for this key. expiration\_time, if set, is a future<br/>Unix timestamp in seconds. The API checks expiry. Explicit null omits imports.<br/>Values are sensitive but are still stored in Terraform state. This module does<br/>not generate, wrap or retain a backup of the original plaintext key material. | <pre>map(object({<br/>    encrypted_key_material = string<br/>    expiration_time        = optional(string)<br/>    import_token           = string<br/>  }))</pre> | `{}` | no |
| <a name="input_origin"></a> [origin](#input\_origin) | Key material source: kms for KMS-generated material or external for imported material. Choose before creating the key; changing origin is not a supported key conversion. | `string` | `"kms"` | no |
| <a name="input_pending_days"></a> [pending\_days](#input\_pending\_days) | Deletion waiting period, 7–1096 whole days. String type is retained for compatibility with the provider and existing callers. Omit for the provider default of 7 days. | `string` | `null` | no |
| <a name="input_realm"></a> [realm](#input\_realm) | Optional provider realm override. Omit for provider/service placement; do not hard-code a realm from another region. Changing realm replaces the key. | `string` | `null` | no |
| <a name="input_rotation_enabled"></a> [rotation\_enabled](#input\_rotation\_enabled) | Enable automatic rotation for KMS-generated keys. External-origin keys do not support automatic KMS rotation. Supply rotation\_interval when enabling rotation. | `bool` | `null` | no |
| <a name="input_rotation_interval"></a> [rotation\_interval](#input\_rotation\_interval) | Rotation interval in whole days, 30–365. Set only with rotation\_enabled = true. | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Optional tags for the KMS key. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_material"></a> [key\_material](#output\_key\_material) | Sensitive import resource objects keyed by kms\_key\_material labels; includes import inputs and status. Empty when no material is imported. |
| <a name="output_kms_grant"></a> [kms\_grant](#output\_kms\_grant) | Grant objects keyed by the kms\_grant input labels. Empty when no grants are configured. |
| <a name="output_kms_key"></a> [kms\_key](#output\_kms\_key) | Key metadata object, including id, key\_alias, key\_state, realm and scheduled\_deletion\_date. Does not contain the plaintext key. This output describes the key resource and does not wait for optional material import. |

## Modules

No modules.

## 🌐 Additional Information

- Intended public address: `CloudAstro/kms-key/opentelekomcloud`, published from `terraform-opentelekomcloud-kms-key`.
- Use `module.kms.kms_key.id` or `module.kms.kms_key.key_alias`. The existing `kms_key`, `kms_grant` and `key_material` outputs are retained.
- After configuring the provider environment, run `terraform init`, `terraform plan` and `terraform apply` inside an example directory. These operations create a real key and, for the full example, a grant. No workload encryption is performed.
- Region is selected by the provider. The examples omit `realm` so they do not assume a particular availability zone or region.

## External Key Material

Set `origin = "external"` to create a key awaiting import. Leave `is_enabled`
unset on initial creation and do not enable automatic rotation. Obtain import
parameters for that key, wrap your material using the supported KMS algorithm,
and supply **one** `kms_key_material` entry with the matching `import_token` and
`encrypted_key_material`. Obtain those values through your controlled import
process; this module accepts already-wrapped material.

The map key is a public Terraform resource label. Its values and the
`key_material` output are marked sensitive, but tokens and wrapped material
remain in state. Protect state access and retain the original material separately
if recovery is required. Do not pass a plaintext key as encrypted\_key\_material.

Import tokens expire. The provider's import-parameters data source returns null
parameters after a key leaves Pending Import. A continuously refreshed data
source and local wrapping script therefore are not a reliable repeatable example.
The full example uses KMS-generated material; external import remains supported
as a separately controlled workflow.

Changing an import token, wrapped material or expiration setting can replace the
material resource. Its deletion removes the imported material immediately; the
key's `pending_days` is **not** a grace period for deleting imported material.
Grants wait for a configured import. The `kms_key` output deliberately remains
independent so callers can obtain import parameters using the key ID.

## 📚 Resources

- [KMS Key Resource](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/kms_key_v1)
- [KMS Grant Resource](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/kms_grant_v1)
- [KMS Material Resource](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/kms_key_material_v1)
- [KMS Import Parameters](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/data-sources/kms_key_material_parameters_v1)
- [Authentication Scope](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/data-sources/identity_auth_scope_v3)
- [Contributing](CONTRIBUTING.md)

## ⚠️ Notes

- Destroy schedules key deletion after `pending_days`; it does not wait for that period to elapse. Once key deletion completes, data requiring that key cannot be recovered through it. Do not destroy a key still used by workloads.
- `allow_cancel_deletion` is a recovery control, not deletion protection. There is no hard-coded prevent-destroy rule in this module.
- Rotation requires both `rotation_enabled = true` and an interval of 30–365 days. Imported keys require a separate material lifecycle.
- Grant operations are required and never default to broad permissions. Null grant/material maps omit the optional resources. Use stable, non-secret map keys.
- The unused nested `key_id` inputs were removed: grants and imports always belong to this module's key. At most one material resource is allowed because one key cannot be independently managed by multiple imports.
- Compared with the old full example, local plaintext generation, shell wrapping, duplicate imports and undeclared random/external provider dependencies are removed. External import values must now be supplied through the caller's import workflow.
- Generate this README with `terraform-docs .`; edit `_header.md`, `_footer.md` and Terraform descriptions. The shared workflows assume a standalone repository root. Release Please reads the configured initial version `1.0.0`.

## 🧾 License

[Apache License 2.0](LICENSE), as declared in the existing module documentation.
<!-- END OF PRE-COMMIT-OPENTOFU DOCS HOOK -->