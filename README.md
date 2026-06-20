# AWS Network Traffic Analysis

[![Terraform Check](https://github.com/hubertwojcik/aws-network-traffic-analysis/actions/workflows/terraform-check.yml/badge.svg)](https://github.com/hubertwojcik/aws-network-traffic-analysis/actions/workflows/terraform-check.yml)

> IaaS cloud environment on AWS for network traffic analysis, anomaly detection, and automated security incident response.

## Overview

This project designs and deploys an AWS IaaS environment focused on **network security monitoring**. VPC Flow Logs are collected, stored in S3, and queried via Athena to detect threats. AWS GuardDuty provides automated anomaly detection, and a semi-automated incident response playbook enables rapid containment of suspicious instances.

The entire infrastructure is managed as code using **Terraform**, ensuring reproducibility and version-controlled configuration.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                        VPC                          │
│                                                     │
│   ┌──────────┐      ┌──────────┐                   │
│   │  EC2 #1  │─────▶│  EC2 #2  │  (test traffic)   │
│   └──────────┘      └──────────┘                   │
│         │                 │                         │
│         └────────┬────────┘                         │
│                  ▼                                   │
│           VPC Flow Logs                             │
└──────────────────┼──────────────────────────────────┘
                   │
         ┌─────────▼──────────┐
         │     Amazon S3      │  (encrypted with KMS)
         └─────────┬──────────┘
                   │
        ┌──────────▼──────────┐
        │    AWS Glue + Athena │  (SQL analysis)
        └──────────┬──────────┘
                   │
         ┌─────────▼──────────┐        ┌─────────────────┐
         │   AWS GuardDuty    │───────▶│  EventBridge    │
         └────────────────────┘        └────────┬────────┘
                                                │
                                       ┌────────▼────────┐
                                       │  Lambda Playbook │
                                       │ (isolate + snap) │
                                       └─────────────────┘
```

## Features

- **Infrastructure as Code** — full environment provisioned with Terraform
- **VPC Flow Logs collection** — captured and stored in S3 with KMS encryption
- **SQL-based traffic analysis** — Athena queries over Glue-cataloged flow log data
- **Automated threat detection** — GuardDuty monitors for anomalies and suspicious behavior
- **Incident response playbook** — Lambda-driven automation to:
  - Swap Security Group of a compromised instance to a deny-all group (isolation)
  - Create EBS snapshot for forensic preservation
- **Optional DPI** — Traffic Mirroring + Suricata for deep packet inspection

## Tech Stack

| Category | Technology |
|---|---|
| Infrastructure | Terraform |
| Compute | AWS EC2 |
| Networking | AWS VPC, Security Groups, Traffic Mirroring |
| Storage | Amazon S3 |
| Encryption | AWS KMS |
| Analysis | AWS Athena, AWS Glue |
| Detection | AWS GuardDuty |
| Automation | AWS EventBridge, AWS Lambda |
| DPI (optional) | Suricata |
| Testing | nmap, curl |

## Test Scenarios

| Scenario | Method | Detection |
|---|---|---|
| Port scan | `nmap` sweep within VPC | Athena query on Flow Logs |
| Beaconing (C2-like) | Periodic HTTP connections | Athena — repeated connections to same dst |
| Data exfiltration | High-volume outbound transfer | Athena + GuardDuty |
| SSH brute-force | Repeated failed SSH attempts | GuardDuty |

## Project Structure

```
.
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── vpc.tf
│   ├── ec2.tf
│   ├── s3.tf
│   ├── kms.tf
│   ├── athena.tf
│   ├── guardduty.tf
│   ├── eventbridge.tf
│   └── lambda/
│       └── isolate_instance.py
├── athena-queries/
│   ├── port_scan.sql
│   ├── beaconing.sql
│   └── exfiltration.sql
└── README.md
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- AWS CLI configured with appropriate permissions
- An AWS account with GuardDuty, Athena, and Glue enabled

## Deployment

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

To destroy the environment:

```bash
terraform destroy
```

## Incident Response Playbook

When GuardDuty triggers a high-severity finding, EventBridge routes the event to a Lambda function that automatically:

1. Identifies the affected EC2 instance
2. Replaces its Security Group with a **deny-all** group (network isolation)
3. Creates an **EBS snapshot** of attached volumes for forensic analysis

The playbook can also be triggered manually for any instance ID.

## License

MIT
