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
{{ if .Unreleased.CommitGroups -}}
<a name="unreleased"></a>
## [Unreleased]
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
- {{ if .Scope }}**{{ .Scope }}:** {{ end }}{{ .Subject }} ([{{ .Hash.Short }}]({{ $.Info.RepositoryURL }}/commits/{{ .Hash.Long }}))
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

{{ if .Versions }}
<!-- tag references -->
[Unreleased]: {{ .Info.RepositoryURL }}/compare/{{ $latest := index .Versions 0 }}{{ $latest.Tag.Name }}...HEAD
{{ range .Versions -}}
{{ if .Tag.Previous -}}
[{{ .Tag.Name }}]: {{ $.Info.RepositoryURL }}/compare/{{ .Tag.Previous.Name }}...{{ .Tag.Name }}
{{ end -}}
{{ end -}}
{{ end }}
