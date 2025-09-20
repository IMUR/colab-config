# Testing Scripts

Utilities for validating configurations and testing cluster functionality.

## Contents

### Shell Configuration Testing
- **`zsh-alignment-test.sh`** - ZSH configuration alignment validation
- **`zsh-simple-test.sh`** - Basic ZSH functionality testing

### Claude-Code Testing
- **`claude-code-functionality-test.sh`** - Comprehensive claude-code functionality assessment
  - Tests basic execution with/without NVM environment
  - Validates search functionality, agent detection, and authentication
  - Generates functionality matrix and migration recommendations
  - Creates timestamped results for project logs

## Usage

### Claude-Code Functionality Test

Execute the comprehensive claude-code assessment on crtr:

```bash
# Remote execution
ssh crtr "bash -s" < /cluster-nas/colab/colab-config/scripts/testing/claude-code-functionality-test.sh

# Local execution on crtr
scp scripts/testing/claude-code-functionality-test.sh crtr:/tmp/
ssh crtr "chmod +x /tmp/claude-code-functionality-test.sh && /tmp/claude-code-functionality-test.sh"
```

Results are saved to timestamped files in `/tmp/` and should be copied to project logs:

```bash
scp crtr:/tmp/claude-code-functionality-test-*.md logs/
```
