# AKS Terraform Project

Multi-environment AKS infrastructure with Azure DevOps self-hosted agents powered by KEDA and workload identity.

**At a glance:**
- **Environments**: dev, UAT, prod — each with its own tfvars and state backend
- **Compute**: AKS with system/app/agent node pools, workload identity, OIDC
- **CI agents**: Self-hosted Azure DevOps agents, scale-to-zero via KEDA
- **Multi-tenant**: Onboard apps to the shared cluster via `app_workloads`

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Azure Resource Group (per environment)                 │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │  VNet                                            │   │
│  │  ┌────────────────┐  ┌────────────────────────┐  │   │
│  │  │ AKS Subnet     │  │ Agents Subnet          │  │   │
│  │  │ (system + app) │  │ (ADO build agents)     │  │   │
│  │  └────────────────┘  └────────────────────────┘  │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │  AKS Cluster                                     │   │
│  │  ├─ System Node Pool (AzureLinux, zones 1-2-3)   │   │
│  │  ├─ App Node Pool    (AzureLinux, zones 1-2-3)   │   │
│  │  └─ Agents Node Pool (tainted, scale-to-zero)    │   │
│  │                                                  │   │
│  │  Features:                                       │   │
│  │  ├─ OIDC Issuer + Workload Identity              │   │
│  │  ├─ KEDA (workload autoscaler)                   │   │
│  │  ├─ Azure CNI + Network Policy                   │   │
│  │  └─ Automatic patch upgrades                     │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Workload Identity                               │   │
│  │  └─ Managed Identity → Federated Credential      │   │
│  │     (bound to K8s SA in ado-agents namespace)    │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │  ADO Agents (Kubernetes resources)               │   │
│  │  ├─ Namespace + ServiceAccount                   │   │
│  │  ├─ KEDA TriggerAuthentication (PAT)             │   │
│  │  └─ KEDA ScaledJob (azure-pipelines trigger)     │   │
│  │     → Scales 0→N based on ADO queue depth        │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## Project Structure

```
.
├── main.tf                          # Root module — orchestrates all child modules
├── variables.tf                     # Input variables
├── outputs.tf                       # Outputs
├── environments/
│   ├── dev.tfvars                   # Dev environment values
│   ├── uat.tfvars                   # UAT environment values
│   ├── prod.tfvars                  # Production environment values
│   ├── backend-dev.hcl              # Dev state backend config
│   ├── backend-uat.hcl              # UAT state backend config
│   └── backend-prod.hcl            # Prod state backend config
└── modules/
    ├── networking/                   # VNet, subnets, NSGs
    ├── aks/                         # AKS cluster + node pools
    ├── workload-identity/           # Managed identity + federated credential
    └── ado-agents/                  # K8s namespace, SA, KEDA ScaledJob
```

## Prerequisites

- Terraform >= 1.5
- Azure CLI (`az login`)
- An Azure Storage Account for remote state
- An Azure DevOps organization with the managed identity registered as a service principal
- The managed identity must have **Agent Pool Administrator** role in Azure DevOps for agent registration
- The managed identity must have **Reader** access on the ADO org/project for KEDA queue-depth polling

## Quick Start

### 1. Configure Remote State Backend

Create an Azure Storage Account for Terraform state, then update the `environments/backend-*.hcl` files with your storage account details.

### 2. Initialize & Plan (example: dev)

```bash
# Initialize with the dev backend
terraform init -backend-config=environments/backend-dev.hcl

# Plan with the dev tfvars
terraform plan -var-file=environments/dev.tfvars

# Apply
terraform apply -var-file=environments/dev.tfvars
```

### 3. Switch Environments

```bash
# Re-init for UAT (use -reconfigure to switch backends)
terraform init -backend-config=environments/backend-uat.hcl -reconfigure

terraform plan -var-file=environments/uat.tfvars
terraform apply -var-file=environments/uat.tfvars
```

### 4. Connect to the Cluster

```bash
az aks get-credentials \
  --resource-group rg-myapp-dev-eus2 \
  --name aks-myapp-dev-eus2
```

## Environment Differences

| Setting                  | Dev            | UAT            | Prod             |
|--------------------------|----------------|----------------|------------------|
| SKU Tier                 | Free           | Standard       | Standard         |
| Private Cluster          | No             | No             | Yes              |
| Azure Policy             | Disabled       | Enabled        | Enabled          |
| System Pool VM Size      | D2s_v5         | D4s_v5         | D4s_v5           |
| App Pool VM Size         | D2s_v5         | D4s_v5         | D8s_v5           |
| App Pool Max Nodes       | 3              | 6              | 20               |
| Agent Pool Max Replicas  | 3              | 5              | 10               |
| Log Analytics            | Optional       | Optional       | Required         |

## Security Best Practices

- **Workload Identity**: ADO agents use federated credentials (no long-lived secrets in the cluster).
- **Node Taints**: Agents node pool uses `workload=ado-agent:NoSchedule` to isolate build workloads.
- **Network Segmentation**: Separate subnets for application workloads and build agents.
- **Zero Secrets**: No PAT tokens — agents authenticate via service principal with federated credentials (workload identity).
- **KEDA Pod Identity**: KEDA authenticates to Azure DevOps using `azure-workload` pod identity, eliminating secret rotation.
- **Private Cluster**: Enabled in production to prevent public API server access.
- **Azure Policy**: Enforced in UAT and production for governance.

## KEDA Scaling

The Azure DevOps agents use a KEDA `ScaledJob` with the `azure-pipelines` trigger:

- **Polling Interval**: 30 seconds
- **Scale-to-Zero**: When no jobs are queued, agents scale down to `minReplicaCount`
- **Max Replicas**: Configurable per environment
- **Job Timeout**: 4 hours (`activeDeadlineSeconds: 14400`)

When a pipeline is queued in the configured pool, KEDA detects pending demand and creates a new agent Job pod to service it. Once the pipeline completes, the pod terminates.

## Onboarding Applications to the Shared Cluster

This is a **shared cluster** — multiple applications are onboarded via the `app_workloads` variable. Each entry in the map creates a fully isolated tenant with:

| Resource | Purpose |
|---|---|
| Kubernetes Namespace | Logical isolation |
| Managed Identity | Azure access via workload identity |
| Federated Credential | OIDC binding to the K8s service account |
| Service Account | Pod identity with `azure.workload.identity/use` label |
| Resource Quota | *(optional)* CPU/memory/pod limits per namespace |
| Limit Range | *(optional)* Default container requests/limits |
| Network Policy | *(optional)* Default-deny ingress + allow-same-namespace |
| Role Assignments | *(optional)* Azure RBAC for the app identity |

### Adding a New Application

Add an entry to `app_workloads` in your environment's `.tfvars`:

```hcl
app_workloads = {
  # Existing apps...
  api = {
    namespace            = "api"
    service_account_name = "api-sa"
  }

  # New app — just add a new key:
  payments = {
    namespace              = "payments"
    service_account_name   = "payments-sa"
    resource_quota_enabled = true
    resource_quota = {
      "requests.cpu"    = "4"
      "requests.memory" = "8Gi"
      "limits.cpu"      = "8"
      "limits.memory"   = "16Gi"
      "pods"            = "20"
    }
    network_policy_enabled = true
    role_assignments = {
      storage_reader = {
        scope = "/subscriptions/__SUB_ID__/resourceGroups/__RG__/providers/Microsoft.Storage/storageAccounts/__SA__"
        role  = "Storage Blob Data Reader"
      }
    }
  }
}
```

Then run `terraform plan` / `terraform apply` — the `for_each` instantiates a new `app-workload` module for the new key.

### Retrieving App Identity Info

After apply, use the output to get each app's managed identity client ID (needed for your app's Azure SDK configuration):

```bash
terraform output -json app_workloads
```

### Per-Environment Guardrails

| Feature | Dev | UAT | Prod |
|---|---|---|---|
| Resource Quotas | Off (flexible) | On | On (larger limits) |
| Limit Ranges | Off | Off | On |
| Network Policies | Off | On | On |

## Customization

- Update `__REPLACE_*__` placeholders in tfvars and backend files
- Add role assignments to the workload identity module for specific Azure access needs
- Swap the ADO agent container image for a custom one with your build tools
- Add additional node pools by extending the `modules/aks/main.tf`
