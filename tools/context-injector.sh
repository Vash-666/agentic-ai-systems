#!/bin/bash
# Context Injector - Helper for 3-Layer Context System
# Usage: source context-injector.sh && inject_context <agent_id> <task>

WORKSPACE="/Users/rohitvashist/.openclaw/workspace"

# Extract context from SESSION-CONTEXT.md and memory files
extract_context() {
    local context=""
    
    # Add current date
    context="[CONTEXT - $(date '+%Y-%m-%d %H:%M %Z')]\n"
    
    # Extract from SESSION-CONTEXT.md if exists
    if [ -f "$WORKSPACE/SESSION-CONTEXT.md" ]; then
        local current_task=$(grep -A 2 "Current State" "$WORKSPACE/SESSION-CONTEXT.md" | head -3)
        context+="Current State: $current_task\n"
    fi
    
    # Extract from today's memory if exists
    local today=$(date '+%Y-%m-%d')
    if [ -f "$WORKSPACE/memory/$today.md" ]; then
        local recent=$(head -20 "$WORKSPACE/memory/$today.md")
        context+="Recent Activity: $recent\n"
    fi
    
    echo -e "$context"
}

# Format task with injected context
format_task_with_context() {
    local task="$1"
    local context=$(extract_context)
    
    echo -e "$context\n---\n[TASK]\n$task"
}

# Example usage in spawn calls:
# sessions_spawn(
#     agentId="grok",
#     task=format_task_with_context "Your actual task here"
# )
