# Release Notes

{{ if .Versions -}}
{{ range .Versions -}}
<a name="{{ .Tag.Name }}"></a>
## {{ if .Tag.Previous }}[{{ .Tag.Name }}]{{ else }}{{ .Tag.Name }}{{ end }} - {{ datetime "2006-01-02" .Tag.Date }}

{{ if .NoteGroups -}}
{{ range .NoteGroups -}}
### {{ if eq .Title "BREAKING CHANGES" }}⚠️{{ end }} {{ .Title }}
{{ range .Notes -}}
{{ .Body }}
{{ end -}}
{{ end }}
{{ end -}}

{{ range .CommitGroups -}}
### {{ .Title }}
{{ range .Commits -}}
- {{ if .Scope }}**{{ .Scope }}:** {{ end }}{{ .Subject }} ([{{ .Hash.Short }}]({{ $.Info.RepositoryURL }}/commit/{{ .Hash.Long }}))
{{ end }}
{{ end -}}

{{- if .RevertCommits -}}
### Reverts
{{ range .RevertCommits -}}
- {{ .Revert.Header }} ([{{ .Hash.Short }}]({{ $.Info.RepositoryURL }}/commit/{{ .Hash.Long }}))
{{ end }}
{{ end -}}

{{- if .MergeCommits -}}
### Merged Pull Requests
{{ range .MergeCommits -}}
- {{ if .Scope }}**{{ .Scope }}:** {{ end }}{{ .Subject }} by @{{ .Author.Name }}
{{ end }}
{{ end -}}
{{ end -}}
{{ end -}}

{{ if .Versions }}
<!-- tag references -->
{{ range .Versions -}}
{{ if .Tag.Previous -}}
[{{ .Tag.Name }}]: {{ $.Info.RepositoryURL }}/compare/{{ .Tag.Previous.Name }}...{{ .Tag.Name }}
{{ end -}}
{{ end -}}
{{ end -}}

<!-- diana:{diana_urn_flavor}:{remote}:{source}:{version}:{remote_path}:{type} -->
<!-- diana:2:github:tprasadtp/templates::common/chglog/RELEASE_NOTES.md.tpl:static -->
