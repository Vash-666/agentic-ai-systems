#!/bin/bash
#
# Trace Demo Script
# Demonstrates distributed tracing across agent ecosystem
#

set -e

WORKSPACE="/Users/rohitvashist/.openclaw/workspace"
source "$WORKSPACE/tools/trace-lib.sh"

echo "=== Distributed Tracing Demo ==="
echo ""

# Initialize trace - use eval to set environment variables
eval $(trace_init_export "distributed-request-demo")
echo "Created trace: $TRACE_ID"
echo "Root span: $TRACE_SPAN_ID"

# Simulate user request span - call function without command substitution
trace_start_span "user-request" "main-agent" '{"agent": "switch", "channel": "webchat"}' > /dev/null
SPAN1=$TRACE_SPAN_ID
echo "Started span: user-request ($SPAN1)"
trace_add_event "$SPAN1" "request_received" '{"user": "test", "intent": "content_creation"}'
sleep 0.1

# Simulate routing decision
trace_start_span "agent-routing" "switch" '{"target": "content"}' > /dev/null
SPAN2=$TRACE_SPAN_ID
echo "Started span: agent-routing ($SPAN2)"
trace_add_event "$SPAN2" "route_decision" '{"target": "content", "confidence": 0.95}'
sleep 0.05
trace_end_span "$SPAN2" "ok"
echo "Completed: agent-routing"

# Return to parent span for next child
export TRACE_SPAN_ID="$SPAN1"

# Simulate content generation
trace_start_span "content-generation" "content" '{"task": "write_blog_post"}' > /dev/null
SPAN3=$TRACE_SPAN_ID
echo "Started span: content-generation ($SPAN3)"
trace_add_event "$SPAN3" "generation_start" '{"model": "gemini-2.5-flash"}'
sleep 0.2
trace_add_event "$SPAN3" "generation_complete" '{"tokens": 150, "cost": 0.0002}'
trace_end_span "$SPAN3" "ok"
echo "Completed: content-generation"

# Return to parent span
export TRACE_SPAN_ID="$SPAN1"

# Simulate quality check
trace_start_span "quality-check" "quality" '{"check_type": "content_review"}' > /dev/null
SPAN4=$TRACE_SPAN_ID
echo "Started span: quality-check ($SPAN4)"
trace_add_event "$SPAN4" "check_start" '{"threshold": 0.92}'
sleep 0.1
trace_add_event "$SPAN4" "check_complete" '{"score": 0.94, "passed": true}'
trace_end_span "$SPAN4" "ok"
echo "Completed: quality-check"

# End user request span
trace_end_span "$SPAN1" "ok"
echo "Completed: user-request"

# Save trace ID before ending
FINAL_TRACE_ID="$TRACE_ID"

# End trace
trace_end "completed"
echo ""
echo "=== Demo Complete ==="
echo "Trace ID: $FINAL_TRACE_ID"
echo ""
echo "View trace: trace-viewer.sh $FINAL_TRACE_ID"
echo "View tree:  trace-viewer.sh $FINAL_TRACE_ID --format tree"
echo "View flame: trace-viewer.sh $FINAL_TRACE_ID --format flame"
