# ISSessions CTF Cloud Infrastructure

Cloud infrastructure I built and operated as the cloud infrastructure engineer for the [ISSessions Cybersecurity Club](https://github.com/issessions) Capture-The-Flag event at Sheridan College, 2021-2022.

The annual CTF had historically been a small in-person event for a single college's cybersecurity club. The 2021 edition moved to the cloud out of COVID necessity.

As cloud infrastructure engineer for the 2022 edition, I Terraformed the inherited deployment and shifted it to an event-window provisioning model that tears down between contests. The contest scaled to country-spanning with a record 167 participants while infrastructure cost dropped roughly 71% versus the prior year's always-on cloud deployment.

## What I built

- **Terraform-driven CTF environment on Google Cloud Platform.** Provisions the full contest stack only during the event window and tears down afterward, cutting infrastructure cost roughly 71% versus an always-on deployment. Two-stage layout: an `initialize` stage for project bootstrap, and a `deploy` stage for the contest infrastructure itself.
- **Kubernetes-based architecture on GKE.** Consolidated the compute footprint into a single cluster, removing standalone compute instances. Helm charts for repeatable deployment of contest services (CTFd, Elastic Stack, Ambassador edge stack, Redis, WireGuard access server).
- **Homelab mirror on VMware vSphere with MicroK8s.** Used as a staging environment to validate Terraform and Helm changes before promoting them to GCP. Same Helm charts, same Terraform modules, different target.
- **Self-hosted Elastic Stack via Helm** for contest telemetry and event monitoring, plus a parallel Elastic Cloud SaaS deployment for comparison.
- **CI/CD pipeline for contest challenges** (in the [`issessions/ISSessionsCTF2022`](https://github.com/issessions/ISSessionsCTF2022) repo). PR-triggered GitHub Actions workflow that built challenge manifests, built and pushed Docker images to `gcr.io/issessions`, uploaded challenges to CTFd via API, and provisioned per-team accounts in both CTFd and Elastic Stack with credential emails to participants.

## Tech stack

Terraform · Kubernetes (GKE for production, MicroK8s for the homelab cluster) · Helm · Ansible · Docker · Google Cloud Platform · VMware vSphere · Elastic Stack (self-hosted on Kubernetes and SaaS) · WireGuard · Python · LDAP · GitHub Actions


## Caveat

A data-loss incident during the project cost roughly six weeks of commits, so this repo represents an earlier iteration rather than the final shipping version of the infrastructure. (This was 2022, so for once I can't blame the gap on a hallucinating AI.)

