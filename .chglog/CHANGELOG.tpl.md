<!-- markdownlint-disable MD033 -->

## Changelog

<p align="center">
  <a href="https://protonvpn.com" target="_blank" rel="noreferrer">
    <img src="https://static.prasadt.com/logos/proton/scalable/protonvpn-wide.svg" height="64" alt="protonvpn">
  </a>
  <a href="https://ghcr.io/tprasadtp/protonvpn" target="_blank" rel="noreferrer">
    <img src="https://static.prasadt.com/logos/software/docker-engine-wide.svg" height="64" alt="protonvpn">
  </a>
</p>

{{ if .Versions -}}
<a name="unreleased"></a>
## [Unreleased]

{{ if .Unreleased.CommitGroups -}}
{{ range .Unreleased.CommitGroups -}}
### {{ .Title }}
{{ range .Commits -}}
- {{ if .Scope }}**{{ .Scope }}:** {{ end }}{{ .Subject }} ([{{ .Hash.Short }}]({{ $.Info.RepositoryURL }}/commits/{{ .Hash.Long }}))
{{ end }}
{{ end -}}
{{ end -}}
{{ end -}}

{{- if  .Unreleased.NoteGroups -}}
{{ range .Unreleased.NoteGroups -}}
### {{ .Title }}
{{ range .Notes -}}
{{ .Body }}
{{ end -}}
{{ end -}}
{{ end -}}


{{ range .Versions }}
<a name="{{ .Tag.Name }}"></a>
## {{ if .Tag.Previous }}[{{ .Tag.Name }}]{{ else }}{{ .Tag.Name }}{{ end }} - {{ datetime "2006-01-02" .Tag.Date }}
{{ range .CommitGroups -}}
### {{ .Title }}
{{ range .Commits -}}
- {{ if .Scope }}**{{ .Scope }}:** {{ end }}{{ .Subject }} ([{{ .Hash.Short }}]({{ $.Info.RepositoryURL }}/commits/{{ .Hash.Long }})
{{ end }}
{{ end -}}

{{- if .RevertCommits -}}
### Reverts
{{ range .RevertCommits -}}
- {{ .Revert.Header }}
{{ end }}
{{ end -}}

{{- if .MergeCommits -}}
### Merged Pull Requests
{{ range .MergeCommits -}}
- {{ if .Scope }}**{{ .Scope }}:** {{ end }}{{ .Subject }} by @{{ .Author.Name }}
{{ end }}
{{ end -}}

{{- if .NoteGroups -}}
{{ range .NoteGroups -}}
### {{ .Title }}
{{ range .Notes -}}
{{ .Body }}
{{ end -}}
{{ end -}}
{{ end -}}
{{ end -}}


<!-- old changelog ported here for compatibility -->
<!-- header 3.1.0 is added by the git-chglog -->

- **FIX** Unreachable ports/Connection Timeouts. Disable internal protonvpn's internal killswitch. This should fix #18, #15, #11. This was enabled in 2.2.6+. Killswitch is not reliable anyway inside container.
- _(Internal)_ Update base docker image.

## 3.0.0

- **NEW**: (🍒) Support connecting to random server [#14](https://github.com/tprasadtp/protonvpn-docker/pull/14).
by [Milutin Jovanović](https://github.com/tprasadtp/protonvpn-docker/pull/14).
- **BREAKING CHANGE**: Version tags prior to this release always matched included protonvpn-cli version.
From this release onwards that will no longer be the case. Use image label `io.github.tprasadtp.metadata.upstream.version`,
to check version of included cli.
- _(Fix)_ Config issues with visionary plan [#16](https://github.com/tprasadtp/protonvpn-docker/issues/16)

## 2.2.6

- **BREAKING CHANGE**: `PROTONVPN_SERVER` and `PROTONVPN_COUNTRY` are now mutually exclusive.
- **BREAKING CHANGE**: DNS argument(`--dns`) is no longer mandatory to run the image.
- **NEW**: Support split tunnel settings.
- **NEW**: Support for disabling DNS leak protection.
- _(Internal)_ Update protonvpn-cli to 2.2.6.
- _(Internal)_ Removes included templates.
- _(Internal)_ Update s6 overlay.
- _(Internal)_ Update base docker image.
- _(Internal)_ Use CLI request headers for API endpoint
- _(Internal)_ Use updated configs fields during container init (`api_domain`).
- _(CI/CD)_ Added support for GitHub container registry.
- _(Internal)_ Changes health-check url to `https://ipinfo.io` as ProtonVPN API is inconsistent.

{{ if .Versions }}
<!-- tag references -->
[Unreleased]: {{ .Info.RepositoryURL }}/compare/{{ $latest := index .Versions 0 }}{{ $latest.Tag.Name }}...HEAD
{{ range .Versions -}}
{{ if .Tag.Previous -}}
[{{ .Tag.Name }}]: {{ $.Info.RepositoryURL }}/compare/{{ .Tag.Previous.Name }}...{{ .Tag.Name }}
{{ end -}}
{{ end -}}
{{ end }}
