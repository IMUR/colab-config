#!/bin/bash
# Claude wrapper script to fix permissions after running
# Ensures shared Claude config remains accessible to all cluster users

# Run the real claude command with all arguments
/usr/local/bin/claude "$@"
CLAUDE_EXIT=$?

# Fix permissions on shared Claude config
chmod -R 777 /cluster-nas/claude-code/.claude-merged 2>/dev/null

# Return the original exit code
exit $CLAUDE_EXIT
