{{- define "wiki-chart.fullname" -}}
{{ .Release.Name | lower }}
{{- end -}}
