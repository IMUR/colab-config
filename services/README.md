---
meta:
  directory_type: "service_management"
  management_tool: "docker_compose"
  automation_safe: true
agent_context:
  purpose: "Containerized service orchestration"
  scope: "docker_services_only"
---

# Services - Container Management

## Purpose
Docker Compose-based service deployments for the Co-lab cluster.

## Available Services
- **Semaphore**: Ansible UI for visual automation
- **Monitoring**: Prometheus + Grafana stack
- **Development**: Code-server, Jupyter environments

## Directory Structure
```
services/
├── docker-compose.yml       # Main compose file
├── .env.template           # Environment template
├── semaphore/
│   ├── config.json         # Service config
│   └── docker-compose.yml  # Service-specific
├── monitoring/
│   ├── prometheus.yml      # Prometheus config
│   └── grafana/            # Grafana dashboards
└── DEPLOYMENT.md           # Deployment guide
```

## Deployment Workflow

### 1. Configure Environment
```bash
cp .env.template .env
vim .env  # Add actual values
```

### 2. Validate Configuration
```bash
docker compose config
docker compose config --quiet  # Syntax check only
```

### 3. Deploy Service
```bash
# Single service
docker compose up -d semaphore

# All services
docker compose up -d

# With rebuild
docker compose up -d --build
```

### 4. Monitor
```bash
docker compose ps
docker compose logs -f SERVICE_NAME
```

## Service Management

### View Status
```bash
docker compose ps
```

### Stop Services
```bash
# Single service
docker compose stop semaphore

# All services
docker compose down
```

### Update Service
```bash
docker compose pull SERVICE_NAME
docker compose up -d SERVICE_NAME
```

### View Logs
```bash
docker compose logs -f SERVICE_NAME
docker compose logs --tail=100 SERVICE_NAME
```

## Environment Variables
Never commit actual values! Use `.env.template` as reference:

```env
# Semaphore
SEMAPHORE_DB_PASS=changeme
SEMAPHORE_ADMIN_PASSWORD=changeme
SEMAPHORE_ACCESS_KEY_ENCRYPTION=changeme

# Monitoring
GRAFANA_ADMIN_PASSWORD=changeme
PROMETHEUS_RETENTION_TIME=15d
```

## Health Checks
```bash
# Check all services
scripts/validation/check-services.sh

# Manual checks
curl -f http://localhost:3000/health  # Semaphore
curl -f http://localhost:9090/-/healthy  # Prometheus
curl -f http://localhost:3001/api/health  # Grafana
```

## Backup & Restore

### Backup
```bash
# Backup volumes
docker run --rm -v SERVICE_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/SERVICE_data_$(date +%Y%m%d).tar.gz -C /data .
```

### Restore
```bash
# Restore volumes
docker run --rm -v SERVICE_data:/data -v $(pwd):/backup \
  alpine tar xzf /backup/SERVICE_data_YYYYMMDD.tar.gz -C /data
```

## Safety Notes
- ✅ Safe to restart containers
- ✅ Safe to view logs and status
- ⚠️  Volume deletion is permanent
- ❌ Never commit .env files
- ❌ Never expose ports without firewall