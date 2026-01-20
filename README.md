# Penpot GCP Deployment

Infra GCP Penpot (front/back) via Terraform. Deux environnements (staging/prod), domaine `pen-pot.com`, DNS géré manuellement (registrar ou Cloud DNS en console). Les services managés (Cloud SQL, MemoryStore, GCS) sont utilisés pour la prod/staging ; les conteneurs Docker locaux ne servent qu’aux tests.

**Stacks Terraform**
- `terraform/gcp/core/ip` : IP statiques prod + staging (front/back, bastion, monitoring) – state dédié, à appliquer en premier.
- `terraform/gcp` : infra GCP (VPC/subnets/PSA, firewall, compute front/back/bastion/monitoring, Cloud SQL + MemoryStore via PSA, bucket GCS assets).

**Prérequis rapides**
- Buckets backend Terraform distincts : `penpot-prod` et `penpot-staging` (à créer avant). Prefixes utilisés : `terraform/state/ip`, `terraform/state/dns`, `terraform/state/infra` selon le stack.
- ADC : `gcloud auth application-default login` + `gcloud config set project <PROJECT_ID>`.
- Rôles minimum : `compute.instanceAdmin.v1`, `compute.networkAdmin`, `cloudsql.admin`, `servicenetworking.networksAdmin`, `dns.admin`, `iam.serviceAccountUser`, accès GCS au bucket backend.
- Remplir les `terraform.tfvars` (staging/prod) : `project_id`, `ssh_allowed_cidrs`, `cloudsql_password`, tailles VM/disques si besoin.

## Terraform (ordre d’exécution recommandé)
```sh
# 0. IPs (core) — à faire pour chaque environnement (bucket backend adapté)
# Staging
terraform -chdir=terraform/gcp/core/ip-staging init -backend-config=backend.hcl
terraform -chdir=terraform/gcp/core/ip-staging plan -var-file=terraform.tfvars
terraform -chdir=terraform/gcp/core/ip-staging apply -var-file=terraform.tfvars
# Prod
terraform -chdir=terraform/gcp/core/ip-prod init -backend-config=backend.hcl
terraform -chdir=terraform/gcp/core/ip-prod plan -var-file=terraform.tfvars
terraform -chdir=terraform/gcp/core/ip-prod apply -var-file=terraform.tfvars
# (destroy: même commandes avec destroy)

# 1. DNS (manuel) — après IP, créer la zone chez le registrar (ou via Cloud DNS en console) et ajouter les enregistrements A :
# Prod : app.pen-pot.com -> IP front prod ; grafana.pen-pot.com -> IP monitoring prod
# Staging : staging.app.pen-pot.com -> IP front staging ; staging.grafana.pen-pot.com -> IP monitoring staging

# 2. Infra staging
terraform -chdir=terraform/gcp init -backend-config=environments/staging/backend.hcl
terraform -chdir=terraform/gcp plan -var-file=environments/staging/terraform.tfvars
terraform -chdir=terraform/gcp apply -var-file=environments/staging/terraform.tfvars
# destroy: terraform -chdir=terraform/gcp destroy -var-file=environments/staging/terraform.tfvars

# 3. Infra prod
terraform -chdir=terraform/gcp init -backend-config=environments/prod/backend.hcl
terraform -chdir=terraform/gcp plan -var-file=environments/prod/terraform.tfvars
terraform -chdir=terraform/gcp apply -var-file=environments/prod/terraform.tfvars
# destroy: terraform -chdir=terraform/gcp destroy -var-file=environments/prod/terraform.tfvars
```

### Dépannage Cloud SQL déjà existante (409 instanceAlreadyExists)
Si une instance Cloud SQL existe déjà mais n’est pas dans le state Terraform (erreur 409), importe-la au lieu de la recréer :
```sh
# remplacer staging/PROJECT_ID/INSTANCE_NAME selon l’environnement
terraform -chdir=terraform/gcp import -var-file=environments/staging/terraform.tfvars \
  module.datastores.google_sql_database_instance.postgres \
  projects/<PROJECT_ID>/instances/<INSTANCE_NAME>

# importer la base si déjà créée
terraform -chdir=terraform/gcp import -var-file=environments/staging/terraform.tfvars \
  module.datastores.google_sql_database.penpot \
  projects/<PROJECT_ID>/instances/<INSTANCE_NAME>/databases/penpot

# importer l’utilisateur si déjà créé
terraform -chdir=terraform/gcp import -var-file=environments/staging/terraform.tfvars \
  module.datastores.google_sql_user.app \
  projects/<PROJECT_ID>/instances/<INSTANCE_NAME>/users/penpot_app
```
Ensuite relancer `terraform apply` avec le bon `-var-file`. Remplace `staging`/`PROJECT_ID`/`INSTANCE_NAME` selon l’environnement.

Notes infra :
- VMs : `penpot-front` (Traefik/reverse proxy) exposé public ; `penpot-back` (API) en privé ; `bastion` SSH ; `monitoring` (Prom/Grafana) en privé.
- Datastores privés via PSA : Cloud SQL Postgres (IPv4 désactivé), MemoryStore (Valkey/Redis), GCS pour les assets (backend `assets-s3` avec endpoint GCS + clés HMAC).
- IP statiques : issues du state `core/ip` (terraform_remote_state). Ne pas détruire ce state pour éviter de changer les IP/DNS ; pour un teardown complet, lever `prevent_destroy` et détruire dans l’ordre DNS puis IP.
- Connexion Service Networking : `deletion_policy = "ABANDON"` pour éviter les blocages au destroy. Si teardown complet, supprimer peering/plage PSA manuellement si nécessaire.
- Bucket assets : `force_destroy = true` pour faciliter les tests (purge auto au destroy). Durcir plus tard si besoin.
- SA dédié au bucket assets (role `storage.objectAdmin`). Générer une clé HMAC (hors Terraform) et injecter dans l’app/CI :
  - `PENPOT_ASSETS_STORAGE_BACKEND=assets-s3`
  - `PENPOT_STORAGE_ASSETS_S3_ENDPOINT=https://storage.googleapis.com`
  - `PENPOT_STORAGE_ASSETS_S3_BUCKET=<bucket>`
  - `PENPOT_STORAGE_ASSETS_S3_REGION=europe-west9`
  - `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` (clé HMAC du SA)

## Terraform helpers (format/validate)
```sh
terraform fmt -recursive
terraform validate
```

## Ansible (collections + test run)
```sh
cd ansible
ansible-galaxy collection install -r requirements.yml -p collections
```
```sh
cd ansible
ansible-playbook -i inventory.ini playbooks/playbook.yml --check
```

### Secrets .env Penpot (GCP Secret Manager)
- Secrets attendus (versions `latest`) : AWS (`PENPOT_AWS_ACCESS_KEY_ID[_PROD]`, `PENPOT_AWS_SECRET_ACCESS_KEY[_PROD]`), DB (`PENPOT_DB_USER[_PROD]`, `PENPOT_DB_PASSWORD[_PROD]`), clé applicative (`PENPOT_SECRET_KEY[_PROD]`), Google OAuth (`PENPOT_GOOGLE_CLIENT_ID[_PROD]`, `PENPOT_GOOGLE_CLIENT_SECRET[_PROD]`), SMTP (`PENPOT_SMTP_HOST[_PROD]`, `PENPOT_SMTP_USERNAME[_PROD]`, `PENPOT_SMTP_PASSWORD[_PROD]`).
- Vars par environnement :
  - `group_vars/staging.yml` : domaine staging, IDs de secrets sans suffixe.
  - `group_vars/prod.yml` : domaine prod, IDs de secrets suffixés `_PROD`.
- Fichiers d’outputs Terraform (staging et prod) attendus par `playbooks/penpot_env.yml` :
  ```sh
  cd terraform/gcp
  terraform output -json > ../../ansible/terraform-outputs-staging.json
  terraform output -json > ../../ansible/terraform-outputs-prod.json
  ```
- Rendu du `.env` (lookup Secret Manager, nécessite `GOOGLE_APPLICATION_CREDENTIALS` vers la clé SA) :
  ```sh
  cd ansible
  # staging
  ansible-playbook -i inventory.ini playbooks/penpot_env.yml -e env=staging
  # prod
  ansible-playbook -i inventory.ini playbooks/penpot_env.yml -e env=prod
  ```
  Le template `ansible/templates/penpot.env.j2` fait les lookups GCP (`google.cloud.gcp_secret_manager`). Les vars non sensibles (flags, tailles, télémétrie, SMTP defaults) sont dans `group_vars/<env>.yml`. Le projet GCP pour les lookups est `penpot_gcp_project`. Clé SA : hors repo (ex : `ansible-sa-key.json` ignoré) et exportée via `GOOGLE_APPLICATION_CREDENTIALS`. Prérequis Python contrôleur : `requests`, `google-auth` disponibles (ex: `pipx inject ansible-core requests google-auth` ou paquets système).

### Déploiement de la stack (docker stack)
- Compose templatisé : `ansible/templates/docker-compose.yaml.j2` (domaine Traefik via `{{ penpot_domain }}`).
- Commandes :
  ```sh
  cd ansible
  # staging
  ansible-playbook -i inventory.ini playbooks/deploy_stack.yml -e env=staging
  # prod
  ansible-playbook -i inventory.ini playbooks/deploy_stack.yml -e env=prod
  ```
  Les `group_vars/<env>.yml` sont chargés automatiquement via l’inventaire (`[staging]`, `[prod]`).

## SSH via OS Login
- `enable-oslogin=TRUE` sur les VMs. Rôles requis : `roles/compute.osAdminLogin` ou `roles/compute.osLogin`.
- Bastion seul exposé en SSH (`ssh_allowed_cidrs`). Les autres VMs sont joignables en SSH depuis le bastion.
- Connexion typique :
  ```sh
  gcloud auth login
  gcloud config set project <PROJECT_ID>
  ssh-keygen -f ~/.ssh/google_compute_engine
  gcloud compute os-login ssh-keys add --key-file ~/.ssh/google_compute_engine.pub --project <PROJECT_ID>
  eval $(ssh-agent -s) && ssh-add ~/.ssh/google_compute_engine
  gcloud compute ssh <BASTION_INSTANCE_NAME> --zone <ZONE> --project <PROJECT_ID> -- -A
  ssh <INTERNAL_VM_IP>
  ```
## Docker Swarm commande
```sh
# Lister les nœuds du cluster
docker node ls
# Inspecter un nœud
docker node inspect <NODE_ID>
# Déployer un stack depuis un fichier compose
docker stack deploy -c docker-compose.yml penpot
# Lister les stacks
docker stack ls
# Lister les services d'un stack
docker stack services penpot
# Lister les tâches d'un stack
docker stack ps penpot
# Retirer un stack
docker stack rm penpot
# Lister tous les services
docker service ls
# Inspecter un service
docker service inspect penpot-front
# Suivre les logs en temps réel
docker service logs -f penpot-front
```
