Based on the Phase 1: Environmental Assessment from your claude-code migration plan, here are individual prompts for a cursor AI background agent to execute each assessment task:

## 📋 Phase 1 Assessment Prompts for Background Agent

### **Prompt 1: System Node.js Assessment**

```
Check the system Node.js installation status on crtr. Execute these commands via SSH:
1. Check if system Node exists at /usr/bin/node and get version
2. Verify if the path /usr/bin/node is a real binary or symlink
3. Check system npm at /usr/bin/npm and version
4. Determine if system Node version is ≥18.x for compatibility
Report findings in a structured format including:
- System Node present: Yes/No
- Version if present
- Path type (binary/symlink)
- Adequacy for claude-code (requires ≥18.x)
```

### **Prompt 2: NVM Installation Assessment**

```
Assess the NVM (Node Version Manager) installation on crtr:
1. Check if ~/.nvm directory exists
2. Source NVM and get version (source ~/.nvm/nvm.sh && nvm --version)
3. List all installed Node versions via NVM (nvm list)
4. Identify current default NVM Node version
5. Check if NVM is properly configured in shell RC files
Document:
- NVM installation path
- NVM version
- Installed Node versions
- Current active version
- Shell integration status
```

### **Prompt 3: Claude-Code Installation Discovery**

```
Locate and assess claude-code installation on crtr:
1. Check if claude-code is in PATH without NVM (which claude-code)
2. Check claude-code with NVM sourced (source ~/.nvm/nvm.sh && which claude-code)
3. Get claude-code version if accessible
4. Identify installation method (npm global, local, other)
5. Check the shebang line of claude-code binary to see which Node it uses
Report:
- Installation location(s)
- Version information
- Node interpreter path from shebang
- Accessibility without NVM environment
```

### **Prompt 4: Authentication & Configuration Assessment**

```
Examine claude-code authentication and configuration files on crtr:
1. List all .claude* files/directories in home directory
2. Check for ~/.config/claude* configuration
3. Identify credential storage locations if present
4. Check for agent configurations in ~/.claude/agents/
5. Note any API keys or tokens (report presence only, not values)
Document findings:
- Configuration file locations
- Credential file presence (DO NOT expose actual credentials)
- Agent configurations found
- Authentication method in use (if determinable)
```

### **Prompt 5: Functionality Testing**

```
Test current claude-code functionality on crtr:
1. Test basic execution without NVM (claude-code --version)
2. Test with NVM environment (source ~/.nvm/nvm.sh && claude-code --version)
3. Test search functionality (claude-code search "test query")
4. Test agent detection (claude-code agent list)
5. Test authentication status (claude-code auth status)
Create functionality matrix:
- Basic execution: Working/Broken (with/without NVM)
- Search feature: Working/Broken
- Agent detection: Working/Broken
- Authentication: Working/Broken/Needs re-auth
- Note specific error messages for broken features
```

### **Prompt 6: Comprehensive Status Summary**

```
Create a comprehensive assessment summary for crtr's claude-code setup:
Compile all findings from previous assessments into a status report including:
1. Current Node.js environment (System vs NVM)
2. Claude-code installation method and location
3. Working vs broken features matrix
4. Dependencies and PATH issues identified
5. Recommended migration approach based on findings
Format as markdown table with clear Yes/No/Partial status indicators and specific version numbers where applicable. Include a risk assessment for the migration based on current state.
```

### **Master Orchestration Prompt**

```
Execute a complete Phase 1 Environmental Assessment for claude-code on crtr node. Run all assessment tasks in sequence:
1. System Node.js check
2. NVM installation verification  
3. Claude-code discovery
4. Authentication/configuration audit
5. Functionality testing
6. Summary report generation
Store all outputs in timestamped files for reference. Flag any critical issues that would block migration. Maintain rollback information throughout. Do not modify any configurations during assessment - this is read-only discovery.
```

These prompts are designed to be:

- **Specific and actionable** for a background agent
- **Non-destructive** (assessment only, no changes)
- **Structured for clear reporting**
- **Sequential but independent** (can run individually or as a batch)
Would you like me to create similar prompts for the other migration phases, or would you prefer to refine these Phase 1 prompts first?
