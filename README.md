# terraform-aws-eks-infra

Production-grade AWS infrastructure using Terraform — modular, workspace-driven, with zero hardcoded values.

---

## Project Overview

This project provisions a complete AWS environment for running containerized workloads on EKS. Infrastructure spans VPC networking, a bastion host (SSM-only), an EKS cluster with managed node groups, and an RDS instance — all deployed via reusable Terraform modules.

A single codebase serves both `dev` and `prod` environments via Terraform workspaces. Environment-specific values are isolated in `.tfvars` files. Security group rules are defined as data structures and created dynamically — no copy-paste rule blocks.

---

## Architecture

```
┌─────────────────────────────────────────────┐
│                    VPC                       │
│                                              │
│   ┌──────────────┐   ┌──────────────────┐   │
│   │ Public Subnet │   │  Public Subnet   │   │
│   │   (AZ-1)      │   │    (AZ-2)        │   │
│   │  [Bastion]    │   │  [NAT Gateway]   │   │
│   └──────┬───────┘   └────────┬─────────┘   │
│          │ SSM only            │ outbound    │
│   ┌──────▼───────────────────▼─────────┐   │
│   │           Private Subnets            │   │
│   │  [EKS Control Plane + Node Group]    │   │
│   │  [RDS Instance + Subnet Group]       │   │
│   └──────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

**Traffic flow:**
- Public internet → Load Balancer SG → EKS nodes (NodePort range)
- Bastion → EKS API server (port 443) via SSM Session Manager (no open SSH port)
- EKS nodes → RDS (port 5432/3306) via Security Group reference
- Private subnets → internet via NAT Gateway (outbound only)

---

## Folder Structure

```
.
├── main.tf                  # Root module: calls all child modules
├── variables.tf             # Input variable declarations
├── outputs.tf               # Root-level outputs
├── locals.tf                # name prefixes, tags
├── backend.tf               # S3 + DynamoDB state backend (workspace-aware)
├── dev.tfvars               # Dev environment values
├── prod.tfvars              # Prod environment values
│
└── modules/
    ├── vpc/
    │   ├── main.tf          # VPC, subnets, IGW, NAT Gateway, route tables
    │   ├── variables.tf
    │   ├── locals.tf
    │   └── outputs.tf       # Subnet IDs, VPC ID
    │
    ├── bastion/
    │   ├── main.tf          # EC2 instance with SSM role, no key pair
    │   ├── sg.tf
    │   ├── variables.tf
    │   ├── user-data.sh
    │   └── outputs.tf       # Instance id
    │
    ├── eks/
    │   ├── main.tf          # EKS cluster, node group, IAM roles
    │   ├── variables.tf
    │   ├── locals.tf
    │   ├── iam.tf           
    │   ├── sg.tf
    │   └── outputs.tf       # Cluster endpoint, node SG ID
    │
    └── rds/
        ├── main.tf          # RDS instance, subnet group, parameter group
        ├── sg.tf          
        ├── variables.tf
        └── outputs.tf       # Rds endpoint 
```

---

## Key Features

**Workspace-based environment separation**  
`terraform.workspace` is used in all resource names and tags (`${terraform.workspace}-eks-cluster`). One backend, two state files. No duplicated module directories.

**Dynamic Security Group rules via `locals` + `for_each`**  
SG rules are defined as maps in `locals.tf` and iterated with `for_each` on `aws_security_group_rule`. Adding or removing a rule is a one-line change to a local — not a new resource block. This also makes diffs readable.

**Module output chaining**  
VPC outputs (subnet IDs) feed into EKS and RDS. EKS outputs (node SG ID) feed into RDS security group rules. No values are looked up via data sources mid-run — everything flows through declared outputs.

**No hardcoded values**  
AMI IDs, instance types, CIDR blocks, engine versions — all in `.tfvars`. The same module code deploys both environments.

---

## How to Use

**Prerequisites:** Terraform >= 1.5, AWS CLI configured, S3 bucket for remote backend and statelock.

```bash
# 1. Initialize (downloads providers and modules)
terraform init

# 2. Select or create a workspace
terraform workspace create dev
terraform workspace select dev      # switch to existing
terraform workspace new prod        # or create new

# 3. Review the plan for your environment
terraform plan -var-file="dev.tfvars"

# 4. Apply
terraform apply -var-file="dev.tfvars"
```

To target a specific module during development:
```bash
terraform plan -var-file="dev.tfvars" -target=module.vpc
```

> **Note:** The backend config does not support workspace interpolation in the `key` argument. Use a key like `"env/terraform.tfstate"` — Terraform automatically namespaces state per workspace under the hood.

---

## Security Design

| Layer | Control |
|---|---|
| Bastion access | SSM Session Manager only — no inbound port 22, no key pair stored |
| EKS API server | Private endpoint; Bastion reaches it via SSM port forwarding |
| Node group | No direct public IP; sits in private subnets behind NAT |
| RDS access | SG rules permit traffic only from Bastion SG and EKS node SG |
| LB exposure | Dedicated SG allows 80/443 inbound; nodes only accept traffic from LB SG on NodePort range |
| IAM | Separate roles for EKS cluster, node group, and Bastion (SSM policy only) |

All SG rule sources reference Security Group IDs, not CIDR blocks, wherever possible — scope is as narrow as the architecture allows.

---

## Challenges

**`for_each` with unknown values at plan time**  
Passing module outputs (e.g., a newly-created SG ID) directly into a `for_each` key causes Terraform to error: it can't enumerate a map with unknown keys. Worked around by using a two-pass apply (`-target=module.vpc` first) or restructuring locals to reference known static keys with the dynamic value as a body attribute, not the key.

**Security Group rule conflicts on re-apply**  
Duplicate SG rules cause non-descriptive errors. Using `for_each` with explicit, unique keys per rule makes the resource address predictable and prevents accidental duplication on workspace-switching.

**Backend workspace limitation**  
The `key` argument in `backend "s3"` does not support `${terraform.workspace}` interpolation. Terraform handles workspace state isolation internally, but this means the state key in S3 won't visually reflect the workspace name unless you use a wrapper script or `terraform-backend-config`.

**EKS node group replacement on SG changes**  
Modifying a Security Group attached to the node group's launch template can trigger a full node group replacement. Changes to SG rules (not the SG itself) do not — understanding this distinction matters for prod changes.

---

## Future Improvements

- [ ] Add [Terragrunt](https://terragrunt.gruntwork.io/) for DRY backend config and dependency management across workspaces  
- [ ] Integrate [tfsec](https://github.com/aquasecurity/tfsec) and [checkov](https://www.checkov.io/) into CI for static security scanning  
- [ ] Replace NAT Gateway with VPC endpoints for S3/ECR to reduce data transfer cost  
- [ ] Add IRSA (IAM Roles for Service Accounts) for pod-level AWS permissions instead of node-level IAM  
- [ ] Parameterize RDS snapshot retention and enable automated snapshot-based DR  
- [ ] Add pre-commit hooks for `terraform fmt`, `validate`, and `tflint`
