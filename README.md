# 🌐 Azure Enterprise Landing Zone (IaC with Terraform, Azure CLI, Azure DevOps)

## Architecture

This repository contains a production-ready skeleton for deploying an **Azure Enterprise Landing Zone** using **Terraform**, **Azure CLI**, and **Azure DevOps Pipelines**. This project is ideal for showcasing your cloud infrastructure and DevOps skills.

```mermaid
flowchart TB
  %% Azure Enterprise Landing Zone. Color-coded architecture

  subgraph Repo["Repository. azure-enterprise-landing-zone"]
    CORE["modules/core\nManagement Groups\nSubscriptions\nNaming + baseline resources"]
    IDMOD["modules/identity\nEntra ID groups\nRBAC assignments\nPIM-ready roles"]
    NETMOD["modules/network\nHub-Spoke VNets\nDNS + Private DNS\nFirewall / Routing"]
    SECMOD["modules/security\nAzure Policy initiatives\nDefender baselines\nKey Vault guardrails"]
    MONMOD["modules/monitoring\nLog Analytics\nDiagnostic settings\nAlerts + dashboards"]
  end

  subgraph Tenant["Azure Tenant"]
    MG["Management Groups\nPlatform. LandingZones. Sandbox"]
    POL["Azure Policy + Initiatives\nGuardrails. Compliance"]
    ENTRA["Entra ID\nGroups. RBAC. PIM"]
  end

  subgraph Platform["Platform Subscription. Hub"]
    HUBVNET["Hub VNet"]
    FW["Azure Firewall\nEgress control"]
    DNS["Private DNS Zones"]
    SHARED["Shared Services\nKey Vault. ACR. Monitor"]
    GW["VPN/ExpressRoute Gateway"]
  end

  subgraph LandingZones["Landing Zone Subscriptions. Spokes"]
    SPOKEVNET["Spoke VNets\nWorkloads"]
    PE["Private Endpoints"]
    AKS["AKS. App Service. Functions"]
    DATA["Data Services\nStorage. SQL. Cosmos"]
  end

  subgraph Observability["Monitoring Plane"]
    LA["Log Analytics Workspace"]
    AM["Azure Monitor\nMetrics. Logs. Alerts"]
  end

  subgraph Delivery["Delivery"]
    CICD["Azure DevOps Pipelines\nor GitHub Actions"]
    TF["Terraform\nState backend + workspaces"]
    PLAN["Plan → Apply → Validate"]
  end

  %% Relationships
  CORE --> MG
  IDMOD --> ENTRA
  SECMOD --> POL
  NETMOD --> Platform
  NETMOD --> LandingZones
  MONMOD --> Observability

  MG --> Platform
  MG --> LandingZones
  POL --> Platform
  POL --> LandingZones
  ENTRA --> Platform
  ENTRA --> LandingZones

  HUBVNET --> FW
  HUBVNET --> DNS
  HUBVNET --> SHARED
  HUBVNET --> GW
  FW -. controlled egress .-> SPOKEVNET
  DNS -. name resolution .-> PE

  SPOKEVNET --> PE
  SPOKEVNET --> AKS
  SPOKEVNET --> DATA

  LA --> AM
  AM -. signals .-> Platform
  AM -. signals .-> LandingZones

  CICD --> PLAN --> TF
  TF --> CORE
  TF --> IDMOD
  TF --> NETMOD
  TF --> SECMOD
  TF --> MONMOD

  %% Styling
  classDef repo fill:#eef2ff,stroke:#3b82f6,stroke-width:1px,color:#111827;
  classDef tenant fill:#ecfeff,stroke:#06b6d4,stroke-width:1px,color:#111827;
  classDef platform fill:#f0fdf4,stroke:#22c55e,stroke-width:1px,color:#111827;
  classDef spokes fill:#fff7ed,stroke:#f97316,stroke-width:1px,color:#111827;
  classDef obs fill:#fdf2f8,stroke:#ec4899,stroke-width:1px,color:#111827;
  classDef delivery fill:#fefce8,stroke:#eab308,stroke-width:1px,color:#111827;

  class CORE,IDMOD,NETMOD,SECMOD,MONMOD repo;
  class MG,POL,ENTRA tenant;
  class HUBVNET,FW,DNS,SHARED,GW platform;
  class SPOKEVNET,PE,AKS,DATA spokes;
  class LA,AM obs;
  class CICD,TF,PLAN delivery;

  %% Highlight key flows
  linkStyle 0,1,2 stroke:#111827,stroke-width:2px;
  linkStyle 3,4 stroke:#111827,stroke-width:2px;
```

## Governance-first Azure Enterprise Landing Zone

```mermaid
flowchart TB
  %% Governance-first Azure Enterprise Landing Zone

  %% ---------- Styles ----------
  classDef gov fill:#ecfeff,stroke:#06b6d4,stroke-width:1px,color:#111827;
  classDef repo fill:#eef2ff,stroke:#3b82f6,stroke-width:1px,color:#111827;
  classDef platform fill:#f0fdf4,stroke:#22c55e,stroke-width:1px,color:#111827;
  classDef spoke fill:#fff7ed,stroke:#f97316,color:#111827;
  classDef obs fill:#fdf2f8,stroke:#ec4899,color:#111827;
  classDef delivery fill:#fefce8,stroke:#eab308,color:#111827;

  subgraph GOV["Tenant Governance"]
    MG["Management Groups"]
    POL["Azure Policy"]
    ENTRA["Entra ID / RBAC / PIM"]
    MONPLANE["Monitoring Plane"]
  end

  subgraph HUB["Platform Subscription (Hub)"]
    HUBVNET["Hub VNet"]
    FW["Azure Firewall"]
    DNS["Private DNS"]
    GW["VPN / ExpressRoute"]
    SHARED["Shared Services"]
  end

  subgraph LZ["Landing Zones (Spokes)"]
    SPOKEVNET["Spoke VNets"]
    AKS["AKS / App Services"]
    DATA["Data Services"]
  end

  GOV --> HUB
  GOV --> LZ
  HUB --> SPOKEVNET
  SPOKEVNET --> AKS
  SPOKEVNET --> DATA

  class MG,POL,ENTRA gov;
  class MONPLANE obs;
  class HUBVNET,FW,DNS,GW,SHARED platform;
  class SPOKEVNET,AKS,DATA spoke;
```

## 📁 Project Structure
```
azure-enterprise-landing-zone/
├── modules/                        # Reusable Terraform modules
│   ├── core/                      # Resource groups, Key Vaults, Storage
│   ├── network/                   # VNet, Subnets, NSGs
│   ├── monitoring/                # Log Analytics, Alerts
│   ├── identity/                  # Azure AD groups, role assignments
│   └── security/                  # Security Center, Policies (To-Do)
├── environments/
│   ├── dev/                       # Dev environment configuration
│   └── prod/                      # Prod environment configuration (To-Do)
├── diagrams/                      # Architecture diagrams
│   └── architecture.mmd
├── pipelines/                     # Azure DevOps pipelines
│   └── azure-pipelines.yml
├── .gitignore                     # Ignored files
├── LICENSE                        # MIT License
└── README.md                      # Project overview
```

---

## 🚀 Features
- 💠 Modular Infrastructure as Code with Terraform
- 🔐 Key Vault, RBAC, NSGs, Monitoring, and Logging
- 📡 Azure DevOps Pipeline with CI/CD for infra
- 📊 Azure Monitor Baseline Alerts (AMBA)
- 📌 Designed for real-world Enterprise Scenarios

---

## 🧰 Technologies Used
- Terraform v1.x
- Azure CLI
- Azure DevOps Pipelines
- Git + GitHub
- Markdown for documentation

---

## 🛠️ Getting Started
### Prerequisites
- Azure subscription
- Terraform & Azure CLI installed
- Azure DevOps project with service connection

### 1. Clone Repository
```bash
git clone https://github.com/gowrishacv/azure-enterprise-landing-zone.git
cd azure-enterprise-landing-zone
```

### 2. Initialize and Deploy Infra (Manual)
```bash
cd environments/dev
az login
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 3. Azure DevOps Pipeline
Use the `azure-pipelines.yml` file to create a new pipeline.

Set up a service connection in DevOps and name it `AzureSPNConnection` (or update in YAML).

---

## 🧱 Module Breakdown

### modules/core
```hcl
resource "azurerm_resource_group" "main" {
  name     = var.name
  location = var.location
}
```

### modules/network
```hcl
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
}
```

---

## Diagram

The architecture diagram is maintained as Mermaid source.

- Mermaid source: `diagrams/architecture.mmd`

If you want Azure product icons (Bastion, Key Vault, Policy, Firewall, etc.), GitHub Mermaid rendering does not support Azure icon packs directly.
For an icon-based diagram, export a PNG/SVG from diagrams.net (draw.io) and add it here.

- Icon-based export (optional): `diagrams/enterprise-landing-zone.png`

---

## ⚙️ Sample Pipeline (`azure-pipelines.yml`)
```yaml
trigger:
  branches:
    include:
      - main

pool:
  vmImage: 'ubuntu-latest'

steps:
  - task: AzureCLI@2
    inputs:
      azureSubscription: 'AzureSPNConnection'
      scriptType: 'bash'
      scriptLocation: 'inlineScript'
      inlineScript: |
        az account show

  - task: TerraformInstaller@1
    inputs:
      terraformVersion: 'latest'

  - task: TerraformTaskV4@4
    inputs:
      provider: 'azurerm'
      command: 'init'
      workingDirectory: '$(System.DefaultWorkingDirectory)/environments/dev'

  - task: TerraformTaskV4@4
    inputs:
      provider: 'azurerm'
      command: 'plan'
      workingDirectory: '$(System.DefaultWorkingDirectory)/environments/dev'

  - task: TerraformTaskV4@4
    inputs:
      provider: 'azurerm'
      command: 'apply'
      workingDirectory: '$(System.DefaultWorkingDirectory)/environments/dev'
      environmentServiceNameAzureRM: 'AzureSPNConnection'
```

---

## ✅ TODO
- [ ] Add Policy module with built-in & custom policies
- [ ] Add Application Gateway and Firewall module
- [ ] Integrate Azure Kubernetes Service (AKS)
- [ ] Add dynamic Terraform workspaces for multi-env

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

---

## 🙌 Author
**Gowrisha CV**  
🔗 [LinkedIn](https://linkedin.com/in/gowrishacv)  

---

### 💬 Questions?
Open an issue or connect on LinkedIn!
