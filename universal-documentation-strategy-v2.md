# Universal Documentation Strategy for Modern Software Projects (v2.0)

## Core Philosophy

Documentation should capture the **"why" exhaustively and the "how" minimally**. The "why" provides eternal context for future decisions, while the "how" emerges from local context and current constraints.

Documentation serves as the bridge between human understanding and machine processing, optimizing for both audiences without duplicating content. Every piece of information should exist in exactly one authoritative location, with clear pathways to discover it.

## The Three-Pillar Structure

### Pillar 1: Human Documentation (README.md)

The README serves as the single source of truth for all project information that benefits both humans and AI agents. This includes:

- **Goals and objectives** - What the project aims to achieve
- **Architecture and design decisions** - Why the project exists and how it works
- **Decision criteria** - How choices should be made, not prescriptive solutions
- **Setup and installation procedures** - How to get started
- **Usage patterns and examples** - How to use the project effectively
- **Development workflows** - How to contribute and maintain
- **Dependencies and requirements** - What the project needs to function

**Key Principle**: If information helps anyone understand the project's purpose or context, it belongs in the README hierarchy, not in runtime-specific files.

### Pillar 2: Machine Navigation (structure.yaml/trail.yaml)

A machine-readable structure file provides programmatic access to project organization and context:

```yaml
version: "2.0"
metadata:
  type: "infrastructure-configuration"
  approach: "goal-oriented"
  
structure:
  source:
    type: "primary-code"
    mutable: true
    purpose: "Core application logic"
  config:
    type: "configuration"
    mutable: false
    purpose: "Application settings"
  docs:
    type: "documentation"
    primary: "README.md"
    purpose: "Human and AI documentation"
    
infrastructure:  # Optional: For infrastructure-dependent projects
  constraints:
    - "Network topology limitations"
    - "Hardware specifications"
    - "Resource boundaries"
  opportunities:
    - "Unused capabilities"
    - "Optimization potential"
    
decisions:  # Track choices made from goals
  decision_name:
    goal: "What we're trying to achieve"
    chosen: "Current implementation"
    why: "Rationale for this choice"
    alternatives: ["Other options considered"]
    revisit_when: "Conditions for reconsideration"
```

This enables tooling to understand both project layout and the context behind structural decisions.

### Pillar 3: Runtime Specifics (AGENTS.md)

A minimal file (20-30 lines maximum) containing only AI agent runtime information:

- **Available tools and their paths** - What executables can be invoked
- **Runtime restrictions** - What operations are forbidden
- **Environment specifics** - Special flags or modes for automation
- **Hardware constraints** - Architecture-specific limitations (ARM vs x86)
- **Network topology hints** - Unusual connectivity (if relevant)
- **Non-standard execution patterns** - Deviations from normal usage

**Critical Rule**: Never duplicate README content. This file should only contain information that is:
1. Specific to automated/AI execution
2. Not useful for human developers
3. Required for runtime operation
4. About constraints, not documentation

## Context-Aware Documentation Principles

### Document Decisions, Not Prescriptions

```yaml
Poor Documentation:
  "Install Docker using apt-get install docker.io"
  
Good Documentation:
  Goal: "Container runtime needed for service isolation"
  Decision Criteria:
    - Ecosystem compatibility
    - Team knowledge level
    - GPU support requirements
    - Security model preferences
  Current Choice: "Docker (as of 2024-09)"
  Revisit When: "Team gains Podman experience or security requirements change"
```

### Goals Before Implementation

Always structure documentation to present:
1. **The objective** - What we're trying to achieve
2. **Success criteria** - How we'll know we've succeeded
3. **Constraints** - What limits our options
4. **Current approach** - How we're solving it now
5. **Evolution triggers** - When to reconsider

## Directory Organization Pattern

```
project/
├── README.md                 # Primary documentation
├── structure.yaml           # Machine-readable organization
├── AGENTS.md               # Minimal runtime specifics (if needed)
│
├── src/                    # Source code
│   └── README.md          # Code-specific documentation
│
├── docs/                  # Supplementary documentation
│   ├── README.md         # Documentation index
│   ├── governance/       # Rules and decisions
│   │   ├── README.md
│   │   ├── RULES.md     # Non-negotiable constraints
│   │   └── DECISIONS.md # Architectural choices with context
│   ├── guides/          # Implementation guides
│   │   └── README.md
│   └── archive/         # Historical documentation
│       ├── README.md
│       └── migrations/  # Completed changes
│
├── infrastructure/       # For infrastructure projects
│   ├── hardware.yaml    # Machine-readable specs
│   ├── network.yaml     # Topology documentation
│   └── README.md       # Human-readable context
│
└── [domain]/            # Domain-specific directories
    └── README.md       # Domain documentation
```

## Documentation Hierarchy Principle

Each directory level contains documentation appropriate to its scope:

1. **Root README.md** - Project-wide goals and context
2. **Directory README.md** - Directory-specific objectives
3. **Subdirectory README.md** - Implementation details

This creates a natural discovery path: **goals → objectives → implementation**

## Infrastructure Documentation Pattern

For projects with significant infrastructure dependencies:

### hardware.yaml - Machine-Readable Infrastructure
```yaml
nodes:
  - name: gateway
    role: "Entry point and services"
    arch: arm64
    ram: 16GB
    storage: 100GB
    special: ["NAS attached", "Always on"]
    
  - name: compute
    role: "Heavy processing"
    arch: x86_64
    ram: 128GB
    storage: 1TB
    special: ["4x GPU", "High memory"]
```

### network.yaml - Topology Documentation
```yaml
topology:
  backbone:
    type: "ethernet"
    speed: "1Gb/s"
    connects: ["all_nodes"]
    
  high_speed:
    type: "thunderbolt3"
    speed: "40Gb/s"
    connects: ["compute1", "compute2"]
    utilization: "not_implemented"  # Track opportunities
    
decisions:
  storage_architecture:
    goal: "Fast ML dataset access"
    current: "NFS over gigabit"
    bottleneck: "1Gb/s network limit"
    opportunity: "Thunderbolt link unused (32x faster)"
    action: "Enable when ML workload demands"
```

## The Seven Rules of Effective Documentation

### Rule 1: Single Source of Truth
Each piece of information exists in exactly one place. Use references rather than duplication.

### Rule 2: Progressive Disclosure
Start with goals at the root level, provide implementation details deeper in the hierarchy.

### Rule 3: Machine-Readable Structure
Provide programmatic access to organization and decisions through structured data files.

### Rule 4: Token Efficiency
For AI consumption, minimize redundancy. Separate runtime configuration from general documentation.

### Rule 5: Living Documentation
Documentation that isn't maintained is worse than no documentation. Keep docs adjacent to the code they describe.

### Rule 6: Context Over Commands
Document why decisions were made and what goals they serve, not just how to execute them.

### Rule 7: Evolution Awareness
Include triggers for reconsidering decisions and patterns for natural growth.

## Documentation Evolution Patterns

### Natural Growth Pattern
```yaml
Documentation Lifecycle:
  Initial:
    - Goals and constraints documented
    - Basic implementation noted
    - Success criteria defined
    
  Growing:
    - Decisions captured as made
    - Alternatives documented
    - Patterns identified
    
  Mature:
    - Patterns extracted to guides
    - Common issues documented
    - Evolution triggers clear
    
  Refactoring:
    - Outdated content archived
    - Patterns promoted to rules
    - New goals incorporated
```

### Continuous Improvement Cycle
```yaml
Review Triggers:
  On Change:
    - Document decision made
    - Update affected sections
    - Archive outdated content
    
  Weekly:
    - What questions arose?
    - What was hard to find?
    - What can be clarified?
    
  Monthly:
    - What patterns emerged?
    - What should be promoted?
    - What can be archived?
    
  Quarterly:
    - Is structure still appropriate?
    - Are goals still accurate?
    - What evolution is needed?
```

## Anti-Patterns to Avoid

### ❌ Documentation Sprawl
**Problem**: Documentation files scattered without organization.  
**Solution**: Consolidate into organized hierarchy with clear categories.

### ❌ Prescriptive Over-Specification
**Problem**: Detailed "how-to" that becomes outdated quickly.  
**Solution**: Document goals and let implementation emerge from context.

### ❌ AI Configuration Bloat
**Problem**: AI configuration files duplicating README content.  
**Solution**: Keep AI files minimal, reference README for project information.

### ❌ Zombie Documentation
**Problem**: Outdated documentation that no longer reflects reality.  
**Solution**: Regular reviews, archive historical docs, maintain only current.

### ❌ Hidden Knowledge
**Problem**: Critical information buried in deeply nested directories.  
**Solution**: Progressive disclosure with important info surfaced appropriately.

### ❌ Format Proliferation
**Problem**: Mixed formats creating confusion.  
**Solution**: Standardize on Markdown with YAML/JSON for structured data.

### ✅ Natural Evolution Pattern
**Principle**: Documentation guides evolution without prescribing it.  
**Implementation**: Document goals and constraints, let implementation emerge, capture decisions as made, review regularly.

## Implementation Checklist

### Initial Setup
- [ ] Create comprehensive README.md focusing on goals
- [ ] Add structure.yaml with metadata and decisions sections
- [ ] Create docs/ hierarchy with governance/guides/archive
- [ ] Add infrastructure/ if hardware-dependent
- [ ] Add AGENTS.md only if runtime specifics exist

### Migration from Existing Documentation
- [ ] Inventory all documentation files
- [ ] Identify goals vs implementation details
- [ ] Restructure to emphasize objectives
- [ ] Move files using version control (git mv)
- [ ] Update all internal references
- [ ] Remove duplicated content
- [ ] Archive historical documentation

### Validation
- [ ] Goals are clear at root level
- [ ] No information appears in multiple places
- [ ] README provides complete context understanding
- [ ] AGENTS.md is under 30 lines (if present)
- [ ] All directories have appropriate README files
- [ ] Machine-readable structure file is accurate
- [ ] Decision rationale is captured

## Governance Documentation

### Rules Document (RULES.md)
Non-negotiable constraints that must be followed:
- Technical constraints (e.g., "Config files must remain at root")
- Process requirements (e.g., "Use git mv for all file moves")
- Forbidden actions (e.g., "Never force push to main")
- Immutable decisions (e.g., "This path cannot change")

### Decisions Document (DECISIONS.md)
Architectural choices with full context:
```yaml
Decision: [Name]
  Goal: [What we're trying to achieve]
  Constraints: [What limits our options]
  Options Considered:
    - Option A: [pros/cons]
    - Option B: [pros/cons]
  Choice: [What we selected]
  Rationale: [Why this option won]
  Trade-offs: [What we gave up]
  Revisit When: [Conditions for reconsideration]
  Date: [When decided]
```

## Success Metrics

Documentation is successful when:

1. **New contributors understand goals** before needing implementation details
2. **Local agents can make appropriate decisions** based on documented context
3. **AI agents can navigate effectively** using README + structure.yaml
4. **Information is discoverable** within three clicks/directories
5. **Updates are simple** because each fact has one location
6. **Evolution is natural** because patterns and triggers are clear
7. **Context is preserved** for future decision-making

## Quick Decision Framework

When documenting anything, ask:

1. **Is this a goal or implementation?**
   - Goal → Document thoroughly
   - Implementation → Document minimally

2. **Will this help someone decide?**
   - Yes → Include context and criteria
   - No → Consider omitting

3. **Is this specific to runtime?**
   - Yes → AGENTS.md (if critical)
   - No → README hierarchy

4. **Could this change based on context?**
   - Yes → Document as current choice with alternatives
   - No → Document as rule/constraint

5. **Who needs this information?**
   - Everyone → Root README
   - Domain-specific → Domain README
   - Machines only → structure.yaml
   - AI runtime only → AGENTS.md

## Universal Applicability

This strategy scales from personal projects to enterprise systems because it:

- **Captures intent** rather than just implementation
- **Preserves context** for future decision-making
- **Respects cognitive limits** through progressive disclosure
- **Enables automation** through machine-readable structure
- **Reduces maintenance** through single source of truth
- **Supports evolution** through documented triggers
- **Facilitates collaboration** by clarifying goals over methods

## The Meta-Documentation Principle

This documentation strategy itself follows its own principles:

- **Documents goals** (effective project documentation) over implementation
- **Provides context** for why each element matters
- **Offers alternatives** rather than prescriptive rules
- **Includes evolution triggers** (review cycles)
- **Maintains single source of truth** for each concept

The key insight is that documentation should empower appropriate decision-making at every level - from project goals to runtime execution - while maintaining clarity about what's fixed and what's flexible.

---

*"Document the why exhaustively, implement the how contextually"*

**Version**: 2.0  
**Last Updated**: September 2025  
**Status**: Living Document  
**Approach**: Goal-Oriented, Context-Aware