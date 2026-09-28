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
