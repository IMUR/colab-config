# Claude-Code Functionality Matrix Template

**📍 File Location**: `logs/claude-code-functionality-matrix-template.md`

---

## Execution Instructions

To test current claude-code functionality on crtr, execute the comprehensive test script:

```bash
# Method 1: Remote execution (recommended)
ssh crtr "bash -s" < /cluster-nas/colab/colab-config/scripts/testing/claude-code-functionality-test.sh

# Method 2: Copy and execute locally
scp /cluster-nas/colab/colab-config/scripts/testing/claude-code-functionality-test.sh crtr:/tmp/
ssh crtr "chmod +x /tmp/claude-code-functionality-test.sh && /tmp/claude-code-functionality-test.sh"
```

## Expected Functionality Matrix

The test script will generate a matrix similar to this:

| Feature | Status | Details |
|---------|--------|---------|
| Basic Execution (No NVM) | BROKEN/WORKING | Command accessible without NVM environment |
| Basic Execution (With NVM) | WORKING/BROKEN | Command accessible with NVM sourced |
| Search Feature | BROKEN/WORKING | Search functionality test |
| Agent Detection | BROKEN/WORKING | Agent list command test |
| Authentication | WORKING/BROKEN/NEEDS_REAUTH | Authentication status check |

## Status Definitions

- **WORKING** ✅ - Feature functions correctly
- **BROKEN** ❌ - Feature fails with errors
- **PARTIAL** ⚠️ - Feature works but with limitations
- **NEEDS_REAUTH** 🔑 - Authentication required to function

## Test Details

### Test 1: Basic Execution (No NVM)
```bash
claude-code --version
```
**Expected Issues**: Command not found if claude-code only installed via NVM

### Test 2: Basic Execution (With NVM)
```bash
source ~/.nvm/nvm.sh && claude-code --version
```
**Expected Result**: Should work if installed via `npm install -g claude-code` through NVM

### Test 3: Search Functionality
```bash
claude-code search "test query"
```
**Expected Issues**: Path resolution problems, native module conflicts

### Test 4: Agent Detection
```bash
claude-code agent list
```
**Expected Issues**: Configuration file discovery problems

### Test 5: Authentication Status
```bash
claude-code auth status
```
**Expected Results**: 
- "Authenticated" if credentials are valid
- "Not authenticated" if login required
- Error if credential storage has issues

## Migration Decision Tree

Based on the functionality matrix results:

### Scenario 1: No Migration Needed ✅
- Basic Execution (No NVM): **WORKING**
- Search Feature: **WORKING**
- Agent Detection: **WORKING**
- Authentication: **WORKING** or **NEEDS_REAUTH**

**Action**: No changes required, claude-code is properly installed

### Scenario 2: Migration Recommended ⚠️
- Basic Execution (No NVM): **BROKEN**
- Basic Execution (With NVM): **WORKING**
- Other features: **BROKEN** or **PARTIAL**

**Action**: Follow `CLAUDE-CODE-NVM-MIGRATION.md` to install via system Node.js

### Scenario 3: Investigation Required 🚨
- Multiple features: **BROKEN**
- Inconsistent behavior across tests

**Action**: Deep investigation needed, possible complete reinstallation

## Results Storage

After testing, the results will be in a timestamped file:
```bash
/tmp/claude-code-functionality-test-YYYYMMDD-HHMMSS.md
```

Copy to project logs:
```bash
scp crtr:/tmp/claude-code-functionality-test-*.md /cluster-nas/colab/colab-config/logs/
```

## Next Steps After Testing

1. **Review the generated functionality matrix**
2. **Determine migration path** based on results
3. **Document findings** in project logs
4. **Proceed with migration** if recommended
5. **Validate post-migration** using the same test script

---

**Related Files**:
- `CLAUDE-CODE-NVM-MIGRATION.md` - Complete migration plan
- `scripts/testing/claude-code-functionality-test.sh` - Test script
- `CLAUDE-CODE-FUNCTIONALITY-TEST-GUIDE.md` - Execution guide