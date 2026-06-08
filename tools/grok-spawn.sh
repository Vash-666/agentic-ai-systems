#!/bin/bash
#
# Grok Spawn Wrapper v1.0
# Combines grok-bridge.sh with 3-layer context system
# Usage: bash tools/grok-spawn.sh "[CONTEXT]...\n[TASK]..."
#

set -e

WORKSPACE="/Users/rohitvashist/.openclaw/workspace"
GROK_BRIDGE="$WORKSPACE/tools/grok-bridge.sh"

# Extract context and task from input
INPUT="$1"

# Parse CONTEXT and TASK sections
CONTEXT=$(echo "$INPUT" | sed -n '/^\[CONTEXT\]/,/^\[TASK\]/p' | sed '$d')
TASK=$(echo "$INPUT" | sed -n '/^\[TASK\]/,$p')

# Remove section headers
CONTEXT=$(echo "$CONTEXT" | sed 's/^\[CONTEXT\]//')
TASK=$(echo "$TASK" | sed 's/^\[TASK\]//')

# Build the prompt for Grok
PROMPT="You are @grok, an AI assistant in a multi-agent system.

=== SYSTEM CONTEXT ===
$CONTEXT

=== YOUR TASK ===
$TASK

=== INSTRUCTIONS ===
1. Acknowledge you received the context
2. Complete the task using the context provided
3. Report your agent ID as '@grok' and model as 'grok-4.20-reasoning'
4. Confirm context injection is working"

# Call grok-bridge with the constructed prompt
bash "$GROK_BRIDGE" --model grok-4.20-reasoning "$PROMPT"
