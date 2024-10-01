{{/*
Expand the name of the chart.
*/}}
{{- define "hoppscotch.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hoppscotch.fullname" -}}
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
{{- define "hoppscotch.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hoppscotch.labels" -}}
helm.sh/chart: {{ include "hoppscotch.chart" .context }}
{{ include "hoppscotch.selectorLabels" . }}
app.kubernetes.io/version: {{ .context.Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .context.Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "hoppscotch.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hoppscotch.name" .context }}-{{ .name }}
app.kubernetes.io/instance: {{ .context.Release.Name }}
{{- end }}

{{- define "hoppscotch.admin.url" -}}
{{ .Values.admin.url | default (printf "%s/%s" .Values.global.baseUrl "admin") }}
{{- end }}

{{- define "hoppscotch.backend.url" -}}
{{ .Values.backend.url | default (printf "%s/%s" .Values.global.baseUrl "api") }}
{{- end }}

{{/*
Frontend env variables
*/}}
{{- define "hoppscotch.env.frontend" -}}
{{- /* Base URLs */}}
- name: VITE_BASE_URL
  value: {{ .Values.global.baseUrl | quote }}
- name: VITE_SHORTCODE_BASE_URL
  value: {{ .Values.global.shortcodeBaseUrl | default .Values.global.baseUrl | quote }}
- name: VITE_ADMIN_URL
  value: {{ include "hoppscotch.admin.url" . | quote }}

{{- /* Backend URLs */}}
- name: VITE_BACKEND_GQL_URL
{{- if .Values.backend.url }}
  value: {{ printf "%s/%s" .Values.backend.url "graphql" | quote }}
{{- else }}
  value: {{ printf "%s/%s" .Values.global.baseUrl "api/graphql" | quote }}
{{- end }}
- name: VITE_BACKEND_WS_URL
{{- if .Values.backend.websocketUrl }}
  value: {{ printf "%s/%s" .Values.backend.websocketUrl "graphql" | quote }}
{{- else }}
  value: {{ printf "%s/%s" (regexReplaceAll "^http(s?)(:.*)" .Values.global.baseUrl "ws${1}${2}") "api/graphql" | quote }}
{{- end }}
- name: VITE_BACKEND_API_URL
{{- if .Values.backend.url }}
  value: {{ printf "%s/%s" .Values.backend.url "v1" | quote }}
{{- else }}
  value: {{ printf "%s/%s" .Values.global.baseUrl "api/v1" | quote }}
{{- end }}

{{- /* Terms Of Service And Privacy Policy Links (Optional) */}}
- name: VITE_APP_TOS_LINK
  value: {{ .Values.global.tosLink | quote }}
- name: VITE_APP_PRIVACY_POLICY_LINK
  value: {{ .Values.global.privacyPolicyLink | quote }}
- name: ENABLE_SUBPATH_BASED_ACCESS
  value: {{ .Values.global.enableSubpathBasedAccess | quote }}
{{- end -}}

{{/* Credentials */}}
{{- define "hoppscotch.secrets.database.password" -}}
{{- $secretName := printf "%s-postgres" (include "hoppscotch.fullname" .)}}
{{- if (lookup "v1" "Secret" .Release.Namespace $secretName).data }}
{{- (lookup "v1" "Secret" .Release.Namespace $secretName).data.POSTGRES_PASSWORD}}
{{- else -}}
{{- .Values.postgres.auth.password | default (randAlphaNum 24) }}
{{- end -}}
{{- end -}}

{{- define "hoppscotch.secrets.database.username" -}}
{{- .Values.postgres.auth.username | default "postgres" }}
{{- end -}}

{{- define "hoppscotch.secrets.database.database" -}}
{{- .Values.postgres.auth.database | default "postgres" }}
{{- end -}}
