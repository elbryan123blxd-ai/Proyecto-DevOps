# CLAUDE.md — Memoria Maestra del Proyecto

> Este archivo es la memoria persistente del proyecto. Lee esto SIEMPRE antes de trabajar
> aquí. Se actualiza al cerrar cada fase. Mantener el idioma español (proyecto de Bryan, español).

## 🎯 Misión y Objetivo

**Megaproyecto final de portafolio DevOps/Cloud para conseguir el primer empleo como
DevOps/Cloud Junior, documentado en un video final de YouTube.**

- Demostrar nivel real de plataforma EKS con GitOps multi-entorno.
- Resultado: repo clonable y funcional + README de portafolio + video de 0 a producción.
- Objetivo de nivel: superar ampliamente el puesto junior (apunta a semi-junior/medio).

## 🏗️ Arquitectura (flujo objetivo confirmado con el usuario)

```
VS Code → GitHub (git push) → GitHub Actions → ECR → (PR repo GitOps) → ArgoCD → EKS → Producción
```

- **Vos cambias** el código en VS Code y haces `git push`.
- **GitHub Actions**: build + tests. Si todo pasa → push a ECR + actualiza el tag de imagen
  en el repo GitOps (via PR, declarativo y auditable).
- **ArgoCD** detecta el cambio y sincroniza el cluster EKS (canary, no corte brusco).
- **Si algo falla**: tests lo frenan o el canary hace rollback automatico.

### Stack confirmado (decisiones del usuario)
| Area | Decision |
|------|----------|
| Arquitectura | EKS + GitOps (ArgoCD) + observabilidad |
| Entornos | dev / staging / prod — 1 cluster, 3 namespaces |
| CI/CD | GitHub Actions (OIDC, sin claves estaticas) |
| App | React + FastAPI (Python) + Python worker + Postgres |
| Secretos | External Secrets Operator + AWS Secrets Manager |
| Nodos | EC2 Managed Node Groups |
| Costo | Encender para video, apagar con un comando (`terraform destroy`) |
| App | App 3 capas propia (cloudops-store / e-commerce) |
| Observabilidad | Prometheus + Grafana + Loki |
| Deploys | ArgoCD Rollouts (canary) con analisis de metricas |
| Contenido | Kustomize overlays por entorno |
| Imagenes | Tag inmutable por SHA + ArgoCD Image Updater |

## 📁 Estructura del monorepo

```
Proyecto-DevOps/
├── app/
│   ├── frontend/                 # React/Vite + Dockerfile + tests
│   ├── api/                      # FastAPI + Dockerfile + tests (CRUD)
│   ├── worker/                   # Python consumer de cola + tests
│   └── docker-compose.yml        # dev local con Postgres
├── terraform/
│   ├── bootstrap/                # S3 remote state + DynamoDB lock (1 vez)
│   ├── envs/
│   │   ├── dev/  ├── staging/  └── prod/   # main.tf + variables.tf + backend.tf + *.tfvars
│   └── modules/
│       ├── vpc/ ├── eks/ ├── rds/ ├── ecr/ ├── iam/ └── argocd/
├── argocd/                       # config GitOps
│   ├── projects/                 # AppProject por entorno
│   ├── applications/             # App-of-Apps
│   └── overlays/ dev/ staging/ prod/   # Kustomize
├── .github/workflows/            # GitHub Actions
├── observability/                # dashboards.json, alertas, datasources
├── docs/                         # arquitectura, costos, guion de video
├── .gitignore
└── README.md                     # diagrama Mermaid + badges + pasos
```

## 📅 Fases y estado de avance

Cada fase = un segmento del video. `[x]` = hecho, `[ ]` = pendiente.

### Fase 0 — Bootstrap + Seguridad ✓ (en curso)
- [x] Crear estructura de carpetas
- [x] .gitignore robusto
- [x] CLAUDE.md + README.md
- [x] Diagrama de arquitectura propio (Mermaid) en README.md y docs/arquitectura.md — flujo limpio: dev → CI → ECR → GitOps → EKS, con observabilidad y rollback.
- [ ] S3 + DynamoDB para remote state (terraform/bootstrap)
- [ ] GitHub OIDC provider + IAM role (asume-role-with-web-identity)

### Fase 1 — App 3 capas ✓ (código creado, falta validar build)
- [x] Dockerfiles multi-stage (api/frontend/worker)
- [x] Tests por servicio
- [x] docker-compose local funcional (app/docker-compose.yml)
- [x] FastAPI conecta a Postgres; worker consume cola
- [ ] Validar `docker compose up --build` local (pendiente de ejecutar)

### Fase 2 — Infra Terraform multi-entorno
- [ ] Modulos reutilizables: vpc, eks, rds, ecr, iam
- [ ] 1 cluster EKS + namespaces por entorno + nodegroups
- [ ] Remote state aislado por entorno

### Fase 3 — GitOps ArgoCD
- [ ] Helm install ArgoCD + ingress
- [ ] App-of-Apps + AppProject por entorno
- [ ] Kustomize overlays por entorno
- [ ] ArgoCD Rollouts (canary) con analisis de metricas

### Fase 4 — CI/CD GitHub Actions
- [ ] PR → build+test (ci-app.yml)
- [ ] merge main → build+push ECR + PR de imagen (cd-build-push.yml)
- [ ] ArgoCD autosincroniza → canary → 100% → verificacion
- [ ] Secretos via External Secrets desde AWS Secrets Manager

### Fase 5 — Observabilidad
- [ ] Prometheus + Grafana + Loki
- [ ] Dashboard de rollout + alerta → auto-rollback (clip estrella del video)

### Fase 6 — Docs + Teardown
- [ ] README pulido + diagrama Mermaid + tabla de costos
- [ ] Guion de video fase a fase (docs/guion-video.md)
- [ ] Workflow terraform-destroy para apagar todo

## 🛠️ Herramientas / Convenciones

- **Terraform** v1.5+ / provider AWS ~> 5.0. Verificar con `terraform fmt` y `terraform validate`.
- **Kubernetes** 1.31 / Helm 3 / kubectl.
- **GitHub Actions**: workflows en `.github/workflows/` (YAML).
- Nada de secretos en git: usar External Secrets + AWS Secrets Manager.
- Idemas en español para comentarios y nombres descriptivos.
- NO ejecutar `terraform apply` contra AWS real sin confirmacion explicita del usuario.

## 🎬 Guion de video (resumen)

[Ver docs/guion-video.md cuando se cree]. Historia: push en VS Code → auto-deploy → canary →
Grafana muestra el rollout y el rollback automatico en vivo.

## 🔗 Enlaces / Referencias

- GitHub: https://github.com/elbryan123blxd-ai/Proyecto-DevOps
- Repo innovador del equipo: la app se llama "cloudops-store".