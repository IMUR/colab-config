# Dynamic Multi-Perspective Documentation System
## Implementation-Ready Framework v0.1

### Quick Start: What This Is

A documentation system where information exists once but can be viewed through multiple organizational lenses. Think of it as "views" in a database - same data, different perspectives, zero duplication.

---

## Canonical Metadata Schema v0.1

Every document MUST have these frontmatter fields:

```yaml
---
id: "node:cooperator"              # Globally unique identifier
type: "node"                       # One of: node|service|hardware|network|doc
title: "Cooperator - Pi 5 Gateway" # Human-readable name
tags: ["hardware", "gateway", "arm64", "primary"]
relations:
  nodes: ["director", "projector"]
  services: ["cockpit", "nfs", "ollama"]  
  networks: ["192.168.254.0/24"]
views:
  hardware: "/by-hardware/nodes/cooperator"
  service: "/by-service/infrastructure/nfs"
  network: "/by-network/192.168.254.10"
safety: "read-only"                # One of: read-only|review-required|safe
updated: "2025-10-03"
version: "0.1.0"
---
```

## Stable ID Scheme

IDs are the backbone of lens-switching. They MUST follow these patterns:

- **Nodes**: `node:<hostname>` → `node:cooperator`
- **Services**: `svc:<name>` → `svc:cockpit`
- **Networks**: `net:<cidr-or-ip>` → `net:192.168.254.0/24` or `net:192.168.254.10`
- **Hardware**: `hw:<node>:<component>:<slot>` → `hw:cooperator:gpu:0`
- **Documents**: `doc:<slug>` → `doc:ssh-config-guide`

## Directory Structure

```
docs/
├── core/                         # CANONICAL SOURCE (only real files)
│   ├── nodes/
│   │   ├── cooperator.md
│   │   ├── director.md
│   │   └── projector.md
│   ├── services/
│   │   ├── cockpit.md
│   │   ├── ollama.md
│   │   └── nfs.md
│   ├── networks/
│   │   └── 192.168.254.0-24.md
│   └── hardware/
│       └── components.md
├── views/                        # GENERATED (symlinks or shallow files)
│   ├── by-hardware/
│   ├── by-service/
│   ├── by-network/
│   └── by-workflow/
├── index.json                    # GENERATED catalog
├── context.json                  # GENERATED context map
└── tools/
    ├── build_index.py
    ├── generate_views.py
    ├── validate.py
    └── hooks/
        └── pre-commit
```

**CRITICAL**: The `views/` directory is GENERATED. Never edit files there directly.

## Context Map Specification

The context map enables lens switching while preserving location:

```json
{
  "current": {
    "lens": "hardware",
    "id": "node:cooperator",
    "path": "/by-hardware/nodes/cooperator"
  },
  "equivalents": {
    "service": ["svc:cockpit", "svc:nfs", "svc:ollama"],
    "network": "net:192.168.254.10",
    "workflow": "doc:gateway-setup"
  },
  "nearby": [
    "node:director",
    "hw:cooperator:gpu:0",
    "svc:cockpit"
  ],
  "breadcrumb": ["hardware", "nodes", "cooperator"]
}
```

## Stage-One Lens Menu

This standardized menu appears in:
- Root README
- CLI help text  
- UI landing page
- AI agent instructions

```
╔══════════════════════════════════╗
║  Choose Your Navigation Lens:    ║
╠══════════════════════════════════╣
║  1) Hardware Topology            ║
║     → Start from physical layer  ║
║                                  ║
║  2) Service Architecture         ║
║     → Start from applications    ║
║                                  ║
║  3) Network Graph                ║
║     → Start from connectivity    ║
║                                  ║
║  4) Workflow Paths               ║
║     → Start from tasks           ║
╚══════════════════════════════════╝
```

## Validation Rules

### Pre-commit Hook (`tools/hooks/pre-commit`)

```bash
#!/bin/bash
# Runs on every git commit

python tools/validate.py || exit 1
```

### Validation Checks (`tools/validate.py`)

1. **Required fields present** (all 10 schema fields)
2. **ID format correct** (matches patterns above)
3. **Type is valid** (one of allowed values)
4. **Relations exist** (referenced IDs are real)
5. **Views paths match** (path corresponds to ID)
6. **Safety level valid** (one of 3 options)
7. **No orphaned docs** (all docs have at least one relation)

**IMPORTANT**: Validation only FLAGS issues. Never auto-fixes.

## Build Pipeline

### 1. Index Builder (`tools/build_index.py`)

```python
# Pseudocode for clarity
for doc in glob("docs/core/**/*.md"):
    frontmatter = parse_yaml(doc)
    validate_required_fields(frontmatter)
    index[frontmatter['id']] = {
        'type': frontmatter['type'],
        'title': frontmatter['title'],
        'tags': frontmatter['tags'],
        'relations': frontmatter['relations'],
        'views': frontmatter['views'],
        'safety': frontmatter['safety'],
        'path': doc
    }
write_json(index, "docs/index.json")
```

### 2. View Generator (`tools/generate_views.py`)

```python
# Clear old views
rmtree("docs/views")

# Generate new views
for id, metadata in index.items():
    for lens, view_path in metadata['views'].items():
        target = f"docs/views/{view_path}"
        source = metadata['path']
        
        # Create symlink (or shallow file with reference)
        os.makedirs(dirname(target), exist_ok=True)
        os.symlink(source, target)
```

### 3. Make Commands

```makefile
index:
	python tools/build_index.py
	python tools/generate_views.py

validate:
	python tools/validate.py

watch:
	while true; do \
		inotifywait -r docs/core -e modify,create,delete; \
		make index; \
	done

clean:
	rm -rf docs/views
	rm -f docs/index.json docs/context.json
```

## Security Model

Three safety levels with clear UI implications:

| Safety Level | Description | UI Behavior |
|-------------|-------------|-------------|
| `safe` | Can be modified freely | Normal editing |
| `review-required` | Changes need human review | Warning before edit |
| `read-only` | No modifications allowed | Grayed out, no edit |

## Discovery Loop

When new documents are added:

1. **File watcher triggers** (or manual `make index`)
2. **Scanner finds new .md files** without frontmatter
3. **Enricher adds template metadata**:
   ```yaml
   ---
   id: "doc:PLACEHOLDER-$(date +%s)"
   type: "doc"
   title: "NEEDS REVIEW: $(basename)"
   tags: ["unreviewed"]
   relations: {}
   views: {}
   safety: "review-required"
   updated: "$(date -I)"
   version: "0.0.0"
   ---
   ```
4. **Validator flags for human review**:
   ```
   ⚠ New document needs metadata:
   - docs/core/services/new-service.md
   - Missing: proper ID, relations, views
   - Action: Edit frontmatter and run 'make index'
   ```

## Integration with Existing Colab-Config

### Phase 1: Minimal PoC (Today)

1. Create `docs/` in your `colab-config` root
2. Migrate `NODE-PROFILES.md` → `docs/core/nodes/*.md` (one file per node)
3. Add frontmatter to each file
4. Run `make index` to generate views
5. Test lens switching with a simple script

### Phase 2: Vector DB (Next Week)

1. Deploy Weaviate/Qdrant container
2. Index `docs/index.json` on each build
3. Add semantic search endpoint
4. Build basic UI for navigation

### Phase 3: Intelligence (Next Month)

1. Deploy local LLaMA for auto-tagging
2. Implement relation discovery
3. Add conflict detection
4. Create review workflow UI

## Example Document

`docs/core/nodes/cooperator.md`:

```markdown
---
id: "node:cooperator"
type: "node"
title: "Cooperator - Primary Pi 5 Gateway"
tags: ["hardware", "gateway", "arm64", "primary", "critical"]
relations:
  nodes: ["director", "projector", "advisor"]
  services: ["cockpit", "nfs", "ollama", "semaphore"]
  networks: ["192.168.254.0/24", "10.0.0.0/24"]
  hardware: ["hw:cooperator:cpu:0", "hw:cooperator:gpu:0"]
views:
  hardware: "/by-hardware/nodes/cooperator"
  service: "/by-service/infrastructure/gateway"
  network: "/by-network/192.168.254.10"
  workflow: "/by-workflow/deployment/gateway-setup"
safety: "review-required"
updated: "2025-10-03"
version: "1.2.0"
---

# Cooperator Node

## Surface Layer - Quick Reference
- **IP**: 192.168.254.10
- **Role**: Primary gateway, NFS server
- **Status**: Active
- **CPU**: ARM Cortex-A76 (4 cores)
- **RAM**: 8GB
- **Storage**: 512GB NVMe

## Contextual Layer - Relationships
This node serves as the primary gateway for the cluster...

## Deep Layer - Technical Details
### SSH Configuration
...
### Service Configurations
...
```

## Success Metrics

- **Build time**: < 1 second for 100 docs
- **Validation time**: < 0.5 seconds
- **View generation**: Idempotent (no changes if run twice)
- **Lens switch time**: < 100ms
- **Context preservation**: 100% accuracy

---

## Start Now: Minimal Working Example

```bash
# 1. Create structure
mkdir -p docs/{core,views,tools}

# 2. Add one document with full metadata
cat > docs/core/nodes/cooperator.md << 'EOF'
---
id: "node:cooperator"
type: "node"
title: "Cooperator"
tags: ["gateway"]
relations:
  services: ["cockpit"]
views:
  hardware: "/by-hardware/nodes/cooperator"
safety: "safe"
updated: "2025-10-03"
version: "0.1.0"
---
# Cooperator Node
Primary gateway for cluster.
EOF

# 3. Build index (manual for now)
python tools/build_index.py

# 4. Generate views
python tools/generate_views.py

# 5. Verify
ls -la docs/views/by-hardware/nodes/
```

This gets you running TODAY with a foundation that scales to the full vision.