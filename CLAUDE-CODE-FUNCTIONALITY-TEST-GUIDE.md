# 🔍 Claude-Code Functionality Test Guide

**📍 File Location**: `CLAUDE-CODE-FUNCTIONALITY-TEST-GUIDE.md`

---

## Quick Execution

To test claude-code functionality on crtr, execute the comprehensive test script:

```bash
# SSH to crtr and run the test
ssh crtr "bash -s" < /cluster-nas/colab/colab-config/scripts/testing/claude-code-functionality-test.sh

# Or copy and execute locally on crtr
scp /cluster-nas/colab/colab-config/scripts/testing/claude-code-functionality-test.sh crtr:/tmp/
ssh crtr "chmod +x /tmp/claude-code-functionality-test.sh && /tmp/claude-code-functionality-test.sh"
```

## What the Test Does

The script performs all 5 required functionality tests:

1. **Basic Execution (No NVM)** - Tests `claude-code --version` without NVM environment
2. **Basic Execution (With NVM)** - Tests with NVM sourced
3. **Search Functionality** - Tests `claude-code search "test query"`
4. **Agent Detection** - Tests `claude-code agent list`
5. **Authentication Status** - Tests `claude-code auth status`

## Expected Output

The script will generate:

- **Console output** with color-coded results
- **Timestamped results file** in `/tmp/claude-code-functionality-test-YYYYMMDD-HHMMSS.md`
- **Functionality matrix** showing WORKING/BROKEN/NEEDS_REAUTH status
- **Migration recommendation** based on test results

## Sample Functionality Matrix

```
Feature                   Status          Details
------------------------  --------------- --------
Basic Execution (No NVM)  BROKEN         Command accessible without NVM
Basic Execution (With NVM) WORKING       Command accessible with NVM sourced
Search Feature            BROKEN         Search functionality test
Agent Detection           BROKEN         Agent list command test
Authentication            NEEDS_REAUTH   Authentication status check
```

## Migration Decision Tree

Based on test results:

- **All WORKING without NVM** → No migration needed ✅
- **WORKING only with NVM** → Migration recommended ⚠️
- **Multiple BROKEN features** → Investigation required 🚨

## Results Storage

After testing, copy the results to the project logs:

```bash
# Copy from crtr to project logs
scp crtr:/tmp/claude-code-functionality-test-*.md /cluster-nas/colab/colab-config/logs/
```

## Next Steps

1. **Review results** in the generated markdown file
2. **Follow migration plan** if recommended (see `CLAUDE-CODE-NVM-MIGRATION.md`)
3. **Document findings** in project logs
4. **Proceed with Phase 2** of migration if needed

---

**Script Location**: `/cluster-nas/colab/colab-config/scripts/testing/claude-code-functionality-test.sh`
**Results Directory**: `/cluster-nas/colab/colab-config/logs/`