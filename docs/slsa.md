# SLSA

<div align="center">

[![slsa-badge-level3][slsa-badge-level3]][slsa-level3]

</div>

All _artifacts_ provided by this repository meet [SLSA L3][slsa-level3].

## Verify SLSA provenance

- Install `slsa-verifier` from [slsa-verifier] project.
- Get digest of image index/manifest. GHCR UI provides the digest in the UI.
  alternatively, `docker`, `crane` or `cosign triangulate --type=digest` command
  can be used.

    ```bash
    docker images \
        --digests \
        --format "Image={{.Repository}}:{{.Tag}} Digest={{.Digest}}" \
        ghcr.io/tprasadtp/protonwire
    ```

- Verify Image

    ```bash
    slsa-verifier verify-image \
       --source-uri=github.com/tprasadtp/protonvpn-docker \
        ghcr.io/tprasadtp/protonwire@<IMAGE_DIGEST>
    ```

[cosign]: https://docs.sigstore.dev/system_config/installation/
[slsa-verifier]: https://github.com/slsa-framework/slsa-verifier
[slsa-badge-level3]: ./images/slsa-level3-logo.svg
[slsa-level3]: https://slsa.dev/spec/v1.0/levels#build-l3
