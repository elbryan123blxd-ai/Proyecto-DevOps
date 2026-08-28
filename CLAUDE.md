# CLAUDE.md — Memoria Maestra del Proyecto (MEJORADO)

> **Este archivo es la memoria persistente del proyecto. Léelo SIEMPRE antes de trabajar aquí.**
> **Se actualiza al cerrar cada fase. Idioma: español (proyecto de Bryan).**
>
> **Última actualización: 2026-08-27 - Fase 4 cerrada + staging verde: CD multi-env (build 1 vez, dev+staging auto, prod con gate manual `workflow_dispatch`), 6 repos ECR por entorno, /health 200 en dev y staging**

## ⚠️ ANTES DE TRABAJAR — Chequeos obligatorios

### 1. Servicios huérfanos de Terraform
- **NUNCA** dejes recursos Terraform en estado "pending" o "destroy failed"
- Si un `terraform destroy` falla, **siempre** revisa los errores de dependency antes de reintentar
- Servicios huérfanos comunes: subnets con DependencyViolation, EIPs sin liberar, IGWs atachados a VPCs eliminadas
- **Procedimiento si falla destroy**: `terraform force-unlock <lock-id>` si está bloqueado, luego revisar plan

### 2. DynamoDB + S3 bucket — SIEMPRE ACTIVOS
- **Estos recursos NUNCA se destruyen automáticamente**
- Son el backend de estado remoto de Terraform
- **Comandos prohibidos**: `terraform destroy` sobre el backend o `aws s3 rm` sobre el bucket de state
- Si necesitas limpiar, solo destruir recursos de `envs/` (dev/staging/prod), NUNCA el bootstrap
- **Estado actual**: Backend cambiado de S3 a **local** para $0 costos, pero el patrón S3+DynamoDB está documentado para reactivación

### 3. GitHub Actions — Push seguro
- **Verifica** que `secrets.AWS_ACCOUNT_ID` y `role/github-actions-cloudops` estén configurados antes de push
- Los workflows requieren OIDC (`aws-actions/configure-aws-credentials`), **nunca** claves estáticas en git
- Si falla un push a GH Actions:
  1. Revisa logs para credenciales OIDI inválidas
  2. Verifica que el role IAM en AWS aún existe y tiene los policies correctos
  3. **NUNCA hagas push** si los secrets están incompletos

### 4. Seguridad — Comandos críticos los aplicas tú
Los siguientes comandos son **de alta riesgo** y los ejecutarás tú directamente, **nunca** desde un workflow sin revisión explícita:
- `terraform apply` — contra AWS real
- `terraform destroy` — sobre entornos
- `aws eks update-cluster-config` — cambios de cluster
- `aws s3 rm --recursive` — sobre buckets

## 🎯 Misión y Objetivo

Megaproyecto final de portafolio DevOps/Cloud para conseguir empleo documentado en video de YouTube.
- Demostrar plataforma EKS con GitOps multi-entorno
- Reposo clonable y funcional + README de portafolio + video de 0 a producción
- Objetivo: superar ampliamente puesto junior (apunta a semi-junior/medio)

## 🏗️ Arquitectura (flujo confirmado)

```
VS Code → GitHub (git push) → GitHub Actions → ECR → (PR repo GitOps) → ArgoCD → EKS → Producción
```

- Cambias código en VS Code y haces `git push`
- GitHub Actions: build + tests. Si todo pasa → push a ECR + actualiza tag en repo GitOps (via PR, declarativo)
- ArgoCD detecta cambio y sincroniza cluster EKS (canary, no corte brusco)
- Si algo falla: tests lo frenan o el canary hace rollback automático

## 📁 Estructura del monorepo

```
Proyecto-DevOps/
├── app/
│   ├── frontend/                 # React/Vite + Dockerfile + tests
│   ├── api/                      # FastAPI + Dockerfile + tests (CRUD)
│   ├── worker/                   # Python consumer de cola + tests
│   └── docker-compose.yml        # dev local con Postgres
├── terraform/
│   ├── bootstrap/                # S3 remote state + DynamoDB lock (NUNCA destruir)
│   ├── envs/
│   │   ├── dev/  ├── staging/  └── prod/   # main.tf + variables.tf + backend.tf + *.tfvars
│   └── modules/
│       ├── vpc/ ├── eks/ ├── rds/ ├── ecr/ ├── iam/ └── argocd/
├── argocd/                       # config GitOps
│   ├── projects/                 # AppProject por entorno
│   ├── applications/             # App-of-Apps
│   └── overlays/ dev/ staging/ prod/   # Kustomize
├── .github/workflows/            # GitHub Actions (CI/CD + infra + destroy)
├── observability/                # Prometheus + Grafana + Loki
├── docs/                         # arquitectura, costos, guion de video
├── .gitignore
├── README.md                     # diagrama Mermaid + badges + pasos
```

## 📅 Fases y estado de avance

Cada fase = un segmento del video. Marcá cada tarea con `x` cuando esté lista: `[ ]` → `[x]`.

### Fase 0 — Bootstrap + Seguridad
- [ ] Crear estructura de carpetas
- [ ] .gitignore robusto (ignora state Terraform, .env, docker volumes)
- [ ] CLAUDE.md + README.md mejorados
- [ ] Diagrama de arquitectura propio (Mermaid) en README.md
- [ ] **Backend local** en lugar de S3 para $0 costos — DynamoDB + S3 backup opcional
- [ ] GitHub OIDC provider + IAM role (asume-role-with-web-identity)
- [ ] **Chequeo**: Verificar que ningún workflow use claves estáticas

### Fase 1 — App 3 capas
- [x] Dockerfiles multi-stage (api/frontend/worker)
- [x] Tests por servicio (pytest para API, vitest/jest para frontend)
- [x] docker-compose local funcional (`app/docker-compose.yml`)
- [x] FastAPI conecta a Postgres; worker consume cola
- [x] Validar `docker compose up --build` local (ejecutar antes de push)
- [x] **Chequeo**: `docker compose ps` — ningún container en estado exited/error

### Fase 2 — Infra Terraform multi-entorno
- [x] Modulos reutilizables: vpc, eks, rds, ecr, iam, argocd
- [x] 1 cluster EKS + namespaces por entorno + nodegroups
- [x] **Remote state local** — state file guardado en ./terraform/terraform.tfstate
- [x] Entornos dev/staging/prod con destroy controlado
- [ ] **DynamoDB lock table** activa para prevenir concurrent writes
- [x] **Chequeo**: `terraform fmt` y `terraform validate` en cada env antes de apply

### Fase 3 — GitOps ArgoCD
- [x] Helm install ArgoCD + ingress
- [x] App-of-Apps + AppProject por entorno
- [x] Kustomize overlays por entorno (replicas 1/2/3)
- [x] ArgoCD Rollouts (canary) con análisis de metricas
- [x] ArgoCD Image Updater para detectar actualizaciones de imagen
- [x] **Chequeo**: Después de ArgoCD sync, verificar que todos los pods estén Ready

### Fase 4 — CI/CD GitHub Actions
- [x] PR → build+test (ci-app.yml) — **verifica logs si falla**
- [x] merge main → build+push ECR + PR de imagen (cd-build-push.yml)
- [x] ArgoCD autosincroniza → canary → 100% → verificación
- [x] Secretos via External Secrets desde AWS Secrets Manager (o local en dev)
- [x] **Chequeo**: Después de merge main, revisar que el PR de gitops se creó correctamente

> **Nota Fase 4**: el GitOps es monorepo → el CD hace **commit directo a main** (no PR) + `git pull --rebase` antes del push (evita rejected non-fast-forward). Estrategia multi-env: **build 1 vez, promover el mismo artefacto** (`sha-<7>`).
> - **Push a main (auto)**: build + push a repos dev **y** staging (`cloudops-dev-*`/`cloudops-staging-*`) + commit GitOps `promover sha-X a dev+staging` (2 overlays).
> - **Prod**: gate manual `workflow_dispatch` (job `promote-prod`) → repos `cloudops-prod-*` + overlay prod. **OJO**: prod queda verde recién tras Fase 5, porque `overlays/prod/frontend.yaml` corre análisis canary contra `prometheus-server.prometheus:9090` (sin Prometheus el rollout aborta).
> - Repos ECR (11): viejos `cloudops-api`/`cloudops-frontend` + 9 por entorno. Lifecycle mantiene últimas 10 imágenes.
> - **Secretos**: `cloudops-store-secrets` manual por namespace (dev/staging/prod apuntan al RDS único de dev; cluster único + comparación ArgoCD IgnoreExtraneous). Fase 4 no externalizó Secrets Manager.
> - **Capacidad**: nodegroup dev = 2 nodos (ArgoCD 9 pods + kube-system 4 + apps 18). Fase 5 (Prometheus/Grafana/Loki +~8 pods) requiere 3er nodo (+~$30/mes) o recortar dex/notifications/applicationset.
> - Canary (base, dev/staging): pasos 5→25→50→100% sin análisis; el `analysis` solo en prod. Ver gotchas OIDC abajo.

### Fase 5 — Observabilidad
- [ ] Prometheus + Grafana + Loki instalados en cluster EKS
- [ ] Dashboard de rollout + alerta → auto-rollback (clip estrella del video)
- [ ] **Chequeo**: `kubectl get pods -n monitoring` — todos los pods Running

### Fase 6 — Docs + Teardown
- [ ] README pulido + diagrama Mermaid + tabla de costos
- [ ] Guion de video fase a fase (docs/guion-video.md)
- [ ] Terraform destroy ejecutado + backend local + recursos AWS eliminados manualmente para $0 costos
- [ ] Workflow terraform-destroy ejecutado - costos AWS en proceso de destrucción
- [ ] **Chequeo**: Verificar que DynamoDB + S3 backend sigan activos con state local

## 🛠️ Herramientas / Convenciones mejoradas

### Terraform
- **Versión**: v1.5+ / provider AWS ~> 5.0
- **Siempre ejecuta**: `terraform fmt` y `terraform validate` antes de commit
- **NUNCA** hacer `terraform apply` contra AWS real sin confirmación explícita
- **Estado**: Backend local en `terraform/terraform.tfstate`
- **Lock**: DynamoDB table para prevenir concurrent terraform runs (siempre activa)

### Editor (VS Code) — Terraform
- **Abrí el repositorio como carpeta raíz** (Proyecto-DevOps). terraform-ls indexa los root modules solos (`terraform/envs/dev|staging|prod`, `bootstrap`); también detecta los módulos (argocd, vpc, eks...).
- Si el editor marca **`Unexpected block: Blocks of type "set"/"dynamic"/"kubernetes" are not expected here`** en el módulo argocd → **NO es un error del código** (el `terraform validate` desde `terraform/envs/dev` da Success). El Language Server no cargó los schemas de los providers helm/kubernetes.
- **Fix**: Paleta de comandos → `Terraform: Initialize Workspace` sobre `terraform/envs/dev` (equivale a `terraform init` para los schemas) → `Developer: Reload Window` para reiniciar terraform-ls.
- `terraform.languageServer.rootModules` está **deprecated/no-op** (ext >= 2.24) — no usarlo; la extensión resuelve los roots recursivamente.
- `terraform validate` (CLI) es la fuente de verdad: si dice Success, el error es del editor, no del repo.
- `.vscode/settings.json` commiteado: format-on-save (`terraform fmt`), enhanced validation y `ignoreDirectoryNames` (node_modules, .git...). Está en `paths-ignore` del CD → editar config no dispara build.

### GitHub Actions
- **OIDC**: Usar `aws-actions/configure-aws-credentials` con role ARN
- **NUNCA** commit de secrets en GitHub (usar External Secrets o secrets encrypted)
- **Workflows requeridos permissions**: `id-token: write`, `contents: write`, `pull-requests: write`
- **Antes de push**: `git status` y `git lint` si está configurado

### Gotchas OIDC GitHub → AWS IAM (Fase 4, aprendido a fuego)
- **`sub` nuevo formato**: `repo:owner@<owner_id>/repo@<repo_id>:ref:refs/heads/<branch>` (p. ej. `repo:elbryan123blxd-ai@285740204/Proyecto-DevOps@1348831287:ref:refs/heads/main`). NO se puede matchear por nombre del repo en el `sub` real.
- **AWS ignora los claims `repository` y `repository_owner`** al evaluar la trust policy (limitación de servicio, aws-actions/configure-aws-credentials#306). Si pones condiciones con esos claims, IAM sigue con `Not authorized to perform sts:AssumeRoleWithWebIdentity` aunque el token sea válido.
- **Trust policy que FUNCIONA**: `aud=sts.amazonaws.com` (StringEquals) + `sub=repo:elbryan123blxd-ai@*/*:*` (StringLike). El nombre del repo va en el wildcard, no en claims.
- **Thumbprints**: son de CA/TLS, NO validan el issuer. Los tokens GitHub se firman con kids `38826b17-...` (thumbprint `ca435a63...`), `38e9b30b...`, `4f3e9ad8...` del JWKS. Probar thumbprints extra (canónico `6938fd4d`, raíz ISRG `ab9d0263`) NO arregla nada si la trust policy está mal. GitHub sumó una 4ª llave al JWKS **sin x5c** (no firma tokens todavía).
- **Diagnóstico utile**: workflow temporal con `actions/jwt-github-action` (imprimir header+claims) + `aws sts assume-role-with-web-identity` crudo con `aws:RequestTag`… ver qué claim llega al asumir. Hacerlo en branch aparte para no disparar el CD.

### Kubernetes / K8s
- **kubectl context**: Verificar `kubectl config current-context` antes de aplicar
- **ArgoCD**: Usar `argocd app sync <app>` para sync manual, o esperar auto-sync
- **Rollouts**: `kubectl rollout status deployment/<app> -n <namespace>`
- **Namespaces**: Cada entorno (dev/staging/prod) tiene su propio namespace

### Aplicación
- **Docker local**: `docker compose up -d --build` en `app/`
- **Frontend**: Puerto 5173 (React/Vite)
- **API**: Puerto 8000 (FastAPI) - health check en `/`
- **Worker**: Consume cola de Postgres o Redis
- **DB**: postgres://dbadmin:dbadmin@localhost:5432/appdb

### Costos
- **Topología actual**: NAT activo en los 3 entornos (2 NATs por entorno = HA). Nodos EKS en subnets privadas, RDS en privadas, endpoint del control plane público (para kubectl desde la laptop).
- **Con todo encendido (3 entornos, 2 NATs c/u)**: ~$250-300/mes aprox (2 NATs = ~$66/mes/env + EKS + RDS + EIPs).
- **Previous**: ~$130/mes con todo encendido
- **Motivo del salto**: ahora hay 3 ambientes (antes ~1), NATs por HA y RDS por ambiente.
- **Parar la sangría**: en Fase 6 `terraform destroy` por env → volver a ~$0 (solo quedan los ~$2/mes de DynamoDB lock si el bootstrap se llegó a aplicar).
- **DynamoDB cost**: ~$1-2/mes (mantener table de lock) — **siempre activa**
- **Notas**: 2 NAT gateways por entorno generan EIPs (gratis mientras el NAT exista). Si sobra alguna subnet privada huérfana de installs viejos → DependencyViolation al destruir, resolver con AWS Console.

## 🔧 Procedimientos mejorados

### Si falla un push a GitHub Actions

1. Revisa los logs del workflow fallido
2. Verifica que `AWS_ACCOUNT_ID` y el role IAM existan
3. Si es error de OIDC, confirma que el trust policy del role permita `sts:AssumeRoleWithWebIdentity`
4. **NUNCA** reintentar push si no resolviste el error raíz

### Si terraform destroy falla (DependencyViolation)

1. Lista recursos con problemas: `terraform plan - destroy -var-file=env.tfvars`
2. Forzar eliminación de recursos huérfanos en AWS Console
3. O usar `terraform force-unlock <lock-id>` si está bloqueado
4. Reintentar `terraform destroy` después

### Antes de cualquier `terraform apply`

1. `terraform init` en el directorio del entorno
2. `terraform fmt` — formatear todos los archivos
3. `terraform validate` — validar sintaxis y referencias
4. `terraform plan` — revisar qué va a cambiar
5. **Confirmar** manualmente que los cambios son esperados

### Estado de remote state (DynamoDB + S3)

```
Tu situación actual: Backend LOCAL en terraform/terraform.tfstate
Motivo: $0 costos, sin recursos AWS activos para state

Patrón documentado (para reactivar cuando necesites team collaboration):
- S3 bucket: guardar estado remoto redundante
- DynamoDB table: lock optimista para writes concurrentes
- NUNCA destruir estos desde los workflows de destroy
- Si reactivas S3+DynamoDB: actualizar backend.tf con los nuevos nombres
```

## 🎬 Guion de video (resumen)

Push en VS Code → validación CI → auto-deploy a ECR → ArgoCD canary → Grafana monitorea → rollback si falla.

## 🎯 Colocación de Fase 3 (GitOps) — cuando el cluster esté activo

Los manifests viven en `argocd/` (monorepo). ArgoCD + Rollouts + Image Updater se instalan vía el módulo terraform `modules/argocd`.

### 1. Secret de la app (obligatorio ANTES del sync)

El `DATABASE_URL` apunta al RDS (endpoint solo se conoce tras el apply). Los manifests referencian el Secret `cloudops-store-secrets`; crearlo en cada namespace:

```powershell
kubectl create secret generic cloudops-store-secrets -n dev `
  --from-literal=DATABASE_URL="postgresql://dbadmin:<pass>@<rds-endpoint>:5432/appdb"
```

- Las Applications tienen `argocd.argoproj.io/compare-options: IgnoreExtraneous` → ArgoCD no lo borra ni revierte (selfHeal).
- En Fase 4 esto se reemplaza por External Secrets desde AWS Secrets Manager.

### 2. Aplicar GitOps

```powershell
kubectl apply -f argocd/projects/
kubectl apply -f argocd/applications/root.yaml   # App-of-Apps: crea las 3 apps
argocd app list      # cloudops-store-{dev,staging,prod}
```

### 3. Demo de la UI de ArgoCD ($0, sin Load Balancer)

```powershell
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | openssl base64 -d
kubectl port-forward -n argocd svc/argocd-server 8080:443   # UI en https://localhost:8080
```

### 4. Chequeo del checklist

`kubectl get pods -n dev` (y staging/prod): todo Running/Ready.

### Notas

- El `base/` no fija namespace: cada overlay lo define (dev/staging/prod), coincide con namespaces de Terraform.
- `canary`: pasos 5→25→50→100% en `base/frontend/rollout.yaml`; el `analysis` con métricas se activa solo en `overlays/prod` (requiere Prometheus, Fase 5).
- Image Updater: `image-list` + `update-strategy: latest` en los overlays; el chart usa credenciales ECR por IRSA — se termina de habilitar con el role en Fase 4, hasta entonces no asume role.

## 🔗 Enlaces / Referencias

- GitHub: https://github.com/elbryan123blxd-ai/Proyecto-DevOps
- Repo innovador del equipo: la app se llama "cloudops-store"
- Video final: pendiente de subir a YouTube