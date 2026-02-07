# -----------------------------------------------------------------------------
# Namespace for Azure DevOps agents
# -----------------------------------------------------------------------------
resource "kubernetes_namespace" "ado_agents" {
  metadata {
    name = var.ado_agent_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "purpose"                      = "ado-agents"
    }
  }
}

# -----------------------------------------------------------------------------
# Service Account with workload identity annotations
# -----------------------------------------------------------------------------
resource "kubernetes_service_account" "ado_agent" {
  metadata {
    name      = var.ado_agent_service_account
    namespace = kubernetes_namespace.ado_agents.metadata[0].name
    annotations = {
      "azure.workload.identity/client-id" = var.ado_agent_client_id
    }
    labels = {
      "azure.workload.identity/use" = "true"
    }
  }
}

# -----------------------------------------------------------------------------
# KEDA TriggerAuthentication — uses workload identity (pod identity) to
# authenticate against Azure DevOps for queue-depth polling.
# Requires the managed identity to have "Reader" on the ADO org or project.
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "keda_trigger_auth" {
  manifest = {
    apiVersion = "keda.sh/v1alpha1"
    kind       = "TriggerAuthentication"
    metadata = {
      name      = "azdevops-trigger-auth"
      namespace = kubernetes_namespace.ado_agents.metadata[0].name
    }
    spec = {
      podIdentity = {
        provider   = "azure-workload"
        identityId = var.ado_agent_client_id
      }
    }
  }
}

resource "kubernetes_manifest" "keda_scaled_job" {
  manifest = {
    apiVersion = "keda.sh/v1alpha1"
    kind       = "ScaledJob"
    metadata = {
      name      = "ado-agent-scaledjob"
      namespace = kubernetes_namespace.ado_agents.metadata[0].name
    }
    spec = {
      jobTargetRef = {
        parallelism                 = 1
        completions                 = 1
        activeDeadlineSeconds       = 14400
        backoffLimit                = 0
        template = {
          metadata = {
            labels = {
              "app"                             = "ado-agent"
              "azure.workload.identity/use"     = "true"
            }
          }
          spec = {
            serviceAccountName = kubernetes_service_account.ado_agent.metadata[0].name
            restartPolicy      = "Never"
            nodeSelector = {
              "workload" = "ado-agent"
            }
            tolerations = [
              {
                key      = "workload"
                operator = "Equal"
                value    = "ado-agent"
                effect   = "NoSchedule"
              }
            ]
            containers = [
              {
                name  = "ado-agent"
                image = "ghcr.io/microsoft/azure-pipelines-agent:latest"
                env = [
                  {
                    name  = "AZP_URL"
                    value = var.ado_org_url
                  },
                  {
                    name  = "AZP_POOL"
                    value = var.ado_pool_name
                  },
                  {
                    name  = "AZP_AUTH"
                    value = "SP"
                  },
                  {
                    name  = "AZP_CLIENT_ID"
                    value = var.ado_agent_client_id
                  },
                  {
                    name  = "AZP_TENANT_ID"
                    value = var.azure_tenant_id
                  }
                ]
                resources = {
                  requests = {
                    cpu    = "500m"
                    memory = "1Gi"
                  }
                  limits = {
                    cpu    = "2"
                    memory = "4Gi"
                  }
                }
              }
            ]
          }
        }
      }
      pollingInterval = 30
      minReplicaCount = var.agent_replicas_min
      maxReplicaCount = var.agent_replicas_max
      successfulJobsHistoryLimit = 3
      failedJobsHistoryLimit     = 3
      triggers = [
        {
          type = "azure-pipelines"
          metadata = {
            organizationURL            = var.ado_org_url
            poolName                   = var.ado_pool_name
            targetPipelinesQueueLength = "1"
          }
          authenticationRef = {
            name = "azdevops-trigger-auth"
          }
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.keda_trigger_auth]
}
