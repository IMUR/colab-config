# Governance Documentation

This directory contains the rules, standards, and decisions that govern the colab-config project.

## Documents

### 📏 STRICT-RULES.md

Non-negotiable constraints, forbidden actions, and hard requirements for the project.

**Key Sections:**

- Chezmoi configuration constraints
- Directory structure requirements
- Git operation rules
- Tool installation strategy
- Validation requirements

### 🏗️ DESIGN-DECISIONS.md

Architectural choices and their rationale, documenting why certain approaches were chosen.

**Key Topics:**

- Hybrid configuration strategy (Ansible + Chezmoi)
- Node.js environment decisions (System vs NVM)
- Repository structure evolution
- Documentation strategy

## Quick Reference

### Non-Negotiables

- `.chezmoiroot = omni-config` (immutable)
- Chezmoi templates stay at `omni-config/` root
- Always use `git mv` for file moves
- AGENTS.md stays under 30 lines

### Decision Tree

For "where does this file go?" questions, see the Quick Decision Tree in STRICT-RULES.md

## Related Documentation

- [Project README](../../README.md) - Complete project documentation
- [Implementation Guides](../guides/) - How to implement changes
- [trail.yaml](../../trail.yaml) - Machine-readable structure
