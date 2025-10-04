# Stems: The Knowledge Guidance System  
*A White Paper on Dynamic Multi-Perspective Documentation*  

## Executive Summary  
**Stems** is a documentation and knowledge guidance system designed for environments where complexity, interdependence, and continuous change overwhelm traditional hierarchies. Unlike static documentation, Stems enables the same information to be explored through multiple “lenses” — hardware, service, network, or workflow — while preserving context.  

This system originated as an evolution beyond linear documentation strategies, incorporating semantic metadata, safety rules, and AI-first navigation. It is particularly suited for hybrid infrastructure clusters like **Co-lab**, where hardware diversity (ARM vs x86), service orchestration, and network topology intersect.  

---

## Problem Space  
Conventional documentation forces a **single hierarchy** (hardware manuals, service docs, network diagrams), which fragments knowledge and multiplies maintenance costs. For example:  

- Hardware-centric docs emphasize **nodes** (e.g., Projector’s GPUs) but obscure **services** running on them.  
- Service-centric docs capture **applications** (e.g., Cockpit, NFS) but fail to show physical dependencies.  
- Network-centric docs highlight **topology** (192.168.254.0/24) but miss functional roles.  

Result: duplicated effort, brittle knowledge graphs, and disorientation when context shifts.  

---

## The Stems Solution  
Stems introduces **dynamic, metadata-driven documentation**:  

1. **Parallel Hierarchies (“Lenses”)**  
   - Hardware view: `/by-hardware/nodes/projector`  
   - Service view: `/by-service/infrastructure/nfs`  
   - Network view: `/by-network/192.168.254.20`  
   - Workflow view: `/by-workflow/deployment/gateway-setup`  

   *Same source document, different perspectives.*  

2. **Context Preservation**  
   Switching lenses preserves focus. If viewing Projector’s GPU in hardware view, a switch to service view highlights ML inference workloads bound to that GPU.  

3. **Machine-Readable Metadata**  
   Every doc includes schema fields (ID, type, tags, relations, safety, version). Validation ensures consistency and prevents “orphaned” knowledge.  

   ```yaml
   id: "node:projector"
   type: "node"
   title: "Projector – GPU Compute Node"
   tags: ["hardware","gpu","compute","x86_64"]
   relations:
     services: ["svc:ollama","svc:openwebui"]
     networks: ["net:192.168.254.20"]
   views:
     hardware: "/by-hardware/nodes/projector"
     service: "/by-service/compute/ollama"
     network: "/by-network/192.168.254.20"
   safety: "review-required"
   updated: "2025-10-03"
   version: "1.0.0"
   ```  

4. **Safety and Validation Layers**  
   Pre-commit hooks and validation scripts enforce metadata, relations, and safety rules (read-only vs review-required vs safe).  

---

## Legacy Strategies and Evolution  
Earlier approaches (e.g., the **Directory Meta-Documentation Guide**) emphasized layered docs: README.md for surface context, `.agent-context.json` for machine boundaries, and `.directory-schema.yml` for structure validation.  

Stems builds on this but replaces **rigid tiers** with **dynamic reorganization**: docs exist once, but can be “reshaped” into any hierarchy.  

---

## Example: Applying Stems to Co-lab Cluster  

### Hardware Lens  
```
/by-hardware/nodes/projector
  • CPU: Intel i9-9900X (20 cores)
  • GPUs: 2x GTX 1080, 2x GTX 970
  • RAM: 126 GB
  • Role: Compute powerhouse
```

### Service Lens  
```
/by-service/inference/ollama
  • Runs on: node:projector
  • GPU Binding: hw:projector:gpu:0-3
  • Dependencies: net:192.168.254.20
  • Related: svc:openwebui (served via Caddy)
```

### Network Lens  
```
/by-network/192.168.254.20
  • Host: projector.local
  • Role: Compute node
  • Services: Ollama, OpenWebUI, Caddy
```

### Workflow Lens  
```
/by-workflow/deployment/gateway-setup
  • Step 1: Configure Cooperator (gateway)
  • Step 2: Sync Chezmoi + Ansible across nodes
  • Step 3: Validate with cluster-health playbook
```

---

## Benefits  

- **For Humans**: intuitive navigation, reduced onboarding time, zero duplication.  
- **For AI Agents**: structured metadata, clear operational boundaries, safe automation hooks.  
- **For Operations**: dynamic adaptability — infrastructure can evolve without breaking documentation.  

---

## Future Roadmap  

- **Phase 1**: Core metadata + lens switching (today).  
- **Phase 2**: Semantic search integration with Qdrant/Weaviate.  
- **Phase 3**: Local AI auto-tagging, relation discovery, conflict detection.  
- **Phase 4**: Advanced UI with visual navigation across hardware, services, and workflows.  

---

## Conclusion  
Stems transforms documentation from a **static archive** into a **living knowledge guidance system**. For complex clusters like Co-lab, it ensures every piece of knowledge is accessible, context-aware, and safe to evolve.  

**Stems: The Knowledge Guidance System** is not just a new structure — it is a new philosophy of documentation as infrastructure.

