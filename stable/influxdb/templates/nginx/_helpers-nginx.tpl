{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "nginx.name" -}}
{{- default .Chart.Name .Values.nginx.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 24 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "nginx.fullname" -}}
{{- if .Values.nginx.fullnameOverride -}}
{{- .Values.nginx.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nginx.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name "nginx" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name "nginx" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper NGINX image name
*/}}
{{- define "nginx.image" -}}
{{- $registryName := .Values.nginx.image.registry -}}
{{- $repositoryName := .Values.nginx.image.repository -}}
{{- $tag := .Values.nginx.image.tag | toString -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 doesn't support it, so we need to implement this if-else logic.
Also, we can't use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.nginx.global }}
    {{- if .Values.nginx.global.imageRegistry }}
        {{- printf "%s/%s:%s" .Values.nginx.global.imageRegistry $repositoryName $tag -}}
    {{- else -}}
        {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper image name (for the metrics image)
*/}}
{{- define "nginx.metrics.image" -}}
{{- $registryName := .Values.nginx.metrics.image.registry -}}
{{- $repositoryName := .Values.nginx.metrics.image.repository -}}
{{- $tag := .Values.nginx.metrics.image.tag | toString -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 doesn't support it, so we need to implement this if-else logic.
Also, we can't use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.nginx.global }}
    {{- if .Values.nginx.global.imageRegistry }}
        {{- printf "%s/%s:%s" .Values.nginx.global.imageRegistry $repositoryName $tag -}}
    {{- else -}}
        {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "nginx.imagePullSecrets" -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 does not support it, so we need to implement this if-else logic.
Also, we can not use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.nginx.global }}
{{- if .Values.nginx.global.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.nginx.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- else if or .Values.nginx.image.pullSecrets .Values.nginx.metrics.image.pullSecrets }}
imagePullSecrets:
{{- range .Values.nginx.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- range .Values.nginx.metrics.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- else if or .Values.nginx.image.pullSecrets .Values.nginx.metrics.image.pullSecrets }}
imagePullSecrets:
{{- range .Values.nginx.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- range .Values.nginx.metrics.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- end -}}