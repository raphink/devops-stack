output "argocd_auth_token" {
  description = "The token to set in ARGOCD_AUTH_TOKEN environment variable."
  value       = jwt_hashed_token.argocd.token
}

output "app_of_apps_values" {
  description = "App of Apps values"
  value       = helm_release.app_of_apps.values
}
