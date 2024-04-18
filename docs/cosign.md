# Cosign

All artifacts provided by this repository are signed using [cosign].

## Verify Cosign signature

- Install [`cosign`][cosign].
- Verify cosign signature
    ```bash
    cosign verify \
        --certificate-identity-regexp "^https://github.com/tprasadtp/protonvpn-docker" \
        --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
        --certificate-github-workflow-repository "tprasadtp/protonvpn-docker" \
        ghcr.io/tprasadtp/protonwire:<image-tag>
    ```

[cosign]: https://docs.sigstore.dev/system_config/installation/
