# Documentation Map

## Current Documentation Structure

### 📍 Root Level (Essential)

```
README.md                    # Primary project documentation
trail.yaml                   # Machine-readable structure  
AGENTS.md                    # Minimal AI runtime info (29 lines)
START-HERE.md               # Quick navigation guide
CLAUDE.md                   # Repository guidelines for Claude
```

### 📚 docs/ (Supplementary)

```
docs/
├── README.md               # Documentation hub index
├── DOCUMENTATION-MAP.md    # This file - complete map
│
├── governance/            # Rules and decisions
│   ├── README.md
│   ├── STRICT-RULES.md    # (to be moved from colab-config-strict-rules.md)
│   └── DESIGN-DECISIONS.md # (to be created from existing content)
│
├── guides/                # Implementation guides
│   ├── README.md
│   ├── RESTRUCTURE-GUIDE.md # (from colab-restructure-semantic-guide.md)
│   └── COMPLETION-PATH.md   # (from colab-config-completion-guide.md)
│
└── archive/               # Historical documentation
    ├── README.md
    ├── migrations/        # Completed migrations
    │   ├── README.md
    │   ├── CLAUDE-CODE-NVM-MIGRATION.md
    │   ├── CRTR-CLAUDE-CODE-ASSESSMENT-REPORT.md
    │   └── migrate-installer.md
    └── stages/           # Stage reports
        ├── README.md
        ├── STAGE2-VALIDATION-CHECKLIST.md
        ├── STAGE2-VALIDATION-COMPLETE.md
        └── STAGE3-PROGRESS-REPORT.md
```

### 📁 Other Documentation Locations

#### omni-config/

- `README.md` - Omni-config specific documentation
- `PLATONIC-NODE-GUIDE.md` - Reference implementation
- `documentation/architecture/DESIGN_PRINCIPLES.md` - Omni-config design

#### system-ansible/ (to be renamed from ansible/)

- `playbooks/README.md` - Ansible playbook documentation

#### services/

- `README.md` - Service configuration documentation

#### scripts/

- `active/README.md` - Active scripts documentation
- `testing/README.md` - Testing scripts documentation

#### documentation/ (to be consolidated)

- `architecture/` → Move relevant docs to `docs/`
- `procedures/` → Archive or integrate into guides

## Documentation Principles

1. **Single Source of Truth** - Each piece of information exists in exactly one place
2. **Clear Hierarchy** - Root → Directory → Subdirectory documentation
3. **Machine Readable** - `trail.yaml` for programmatic access
4. **Token Efficient** - `AGENTS.md` minimal, no duplication with README
5. **Strategic Placement** - Documentation lives where it's needed

## Files to Move (Git Commands)

```bash
# Governance documents
git mv colab-config-strict-rules.md docs/governance/STRICT-RULES.md

# Guide documents  
git mv colab-restructure-semantic-guide.md docs/guides/RESTRUCTURE-GUIDE.md
git mv colab-config-completion-guide.md docs/guides/COMPLETION-PATH.md

# Archive duplicate
git mv "colab-restructure-semantic-guide (1).md" docs/archive/restructure-guide-duplicate.md

# Migration documents
git mv CLAUDE-CODE-NVM-MIGRATION.md docs/archive/migrations/
git mv CRTR-CLAUDE-CODE-ASSESSMENT-REPORT.md docs/archive/migrations/
git mv migrate-installer.md docs/archive/migrations/

# Stage documents
git mv STAGE2-VALIDATION-CHECKLIST.md docs/archive/stages/
git mv STAGE2-VALIDATION-COMPLETE.md docs/archive/stages/
git mv STAGE3-PROGRESS-REPORT.md docs/archive/stages/

# Remove empty file
git rm doc-.md  # (if empty)
```

## After Moving

1. Update any internal links in moved documents
2. Update references in README.md and START-HERE.md
3. Commit with clear message: `refactor: Organize documentation hierarchy`
4. Update trail.yaml if structure changes
