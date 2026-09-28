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
if recovery is required. Do not pass a plaintext key as encrypted_key_material.

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
