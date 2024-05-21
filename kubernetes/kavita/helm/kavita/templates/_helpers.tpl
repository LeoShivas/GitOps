{{/*
Expand the name of the chart.
*/}}
{{- define "kavita.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kavita.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kavita.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kavita.labels" -}}
helm.sh/chart: {{ include "kavita.chart" . }}
{{ include "kavita.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "kavita.mangaManager.labels" -}}
{{- if .Values.mangaManager.enabled -}}
helm.sh/chart: {{ include "kavita.chart" . }}
{{ include "kavita.mangaManager.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "kavita.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kavita.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: kavita
{{- end }}

{{- define "kavita.mangaManager.selectorLabels" -}}
{{- if .Values.mangaManager.enabled -}}
app.kubernetes.io/name: {{ include "kavita.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: manga-manager
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kavita.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kavita.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
