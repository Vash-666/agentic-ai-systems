# WORKFLOW.md — Example: End-to-End Task Execution

**Version:** 3.0
**Purpose:** Demonstrate complete agent workflow
**Scenario:** User requests "Build a login page"

---

## Workflow Overview

```
User → @switch → @product → @switch → @ux → @switch → @scaffolder → @switch → @quality → @switch → User
```

## Step-by-Step

### Step 1: User Request
```
User: "Build a login page for my app"
```

### Step 2: @switch Receives Request
**Action:** Classify intent, plan execution

```yaml
session:
  id: "sess-001"
  task: "Build login page"
  type: "web_development"
  
analysis:
  intent: "create_login_page"
  complexity: "medium"
  agents_needed: ["@product", "@ux", "@scaffolder", "@quality"]
  estimated_time: "30 minutes"
```

**Decision:** Sequential execution (dependencies between steps)

### Step 3: @switch Spawns @product

```yaml
handoff:
  from: "@switch"
  to: "@product"
  context:
    task: "Define login page requirements"
    goal: "Create feature specification"
    priority: "high"
  artifacts:
    data: {user_request: "Build a login page", app_type: "unknown"}
  acceptance_criteria:
    - "Requirements are clear"
    - "Acceptance criteria defined"
    - "Success metrics specified"
  return_path:
    to: "@switch"
    format: "Feature specification document"
```

### Step 4: @product Analyzes Requirements

**Output:**
```markdown
# Feature Spec: Login Page

## Requirements
- Username/email input
- Password input
- Submit button
- Error handling
- Remember me option

## Acceptance Criteria
- [ ] Form validates input
- [ ] Error messages are clear
- [ ] Responsive design
- [ ] Accessible (WCAG 2.1)

## Success Metrics
- Load time < 2s
- Error rate < 1%
```

**Return to @switch:**
```yaml
handoff:
  from: "@product"
  to: "@switch"
  artifacts:
    files: ["specs/login-page.md"]
    data: {requirements: 5, acceptance_criteria: 4}
```

### Step 5: @switch Spawns @ux

```yaml
handoff:
  from: "@switch"
  to: "@ux"
  context:
    task: "Design login page UX"
    goal: "Create wireframes and design spec"
  artifacts:
    files: ["specs/login-page.md"]
  acceptance_criteria:
    - "Wireframes created"
    - "Design spec complete"
    - "Accessibility considered"
```

### Step 6: @ux Creates Design

**Output:**
```markdown
# Design: Login Page

## Layout
+----------------------------------+
|  Logo                            |
+----------------------------------+
|                                  |
|  Email: [________________]       |
|                                  |
|  Password: [____________]        |
|                                  |
|  [ ] Remember me                 |
|                                  |
|  [    Login    ]                 |
|                                  |
|  Forgot password?                |
+----------------------------------+

## Colors
- Primary: #0066CC
- Background: #FFFFFF
- Error: #DC3545

## Interactions
- Focus: Blue border
- Error: Red border + message
- Loading: Spinner on button
```

**Return to @switch**

### Step 7: @switch Spawns @scaffolder

```yaml
handoff:
  from: "@switch"
  to: "@scaffolder"
  context:
    task: "Implement login page"
    goal: "Working login page code"
  artifacts:
    files: ["specs/login-page.md", "designs/login-page.md"]
  acceptance_criteria:
    - "HTML/CSS/JS created"
    - "Form validation works"
    - "Responsive design"
```

### Step 8: @scaffolder Builds Code

**Output:**
```html
<!-- login.html -->
<!DOCTYPE html>
<html>
<head>
  <title>Login</title>
  <link rel="stylesheet" href="login.css">
</head>
<body>
  <div class="login-container">
    <h1>Login</h1>
    <form id="loginForm">
      <input type="email" id="email" placeholder="Email" required>
      <input type="password" id="password" placeholder="Password" required>
      <label>
        <input type="checkbox" id="remember"> Remember me
      </label>
      <button type="submit">Login</button>
    </form>
    <p id="error" class="hidden"></p>
  </div>
  <script src="login.js"></script>
</body>
</html>
```

**Return to @switch**

### Step 9: @switch Spawns @quality

```yaml
handoff:
  from: "@switch"
  to: "@quality"
  context:
    task: "Audit login page implementation"
    goal: "Verify quality before delivery"
  artifacts:
    files: ["login.html", "login.css", "login.js", "specs/login-page.md"]
  acceptance_criteria:
    - "All requirements met"
    - "Code quality ≥8.0"
    - "No security issues"
```

### Step 10: @quality Audits

**Output:**
```markdown
## Quality Audit — Login Page

### Scores
| Component | Score | Weight | Weighted |
|-----------|-------|--------|----------|
| Prompt Files | 9/10 | 0.65 | 5.85 |
| Memory | 8/10 | 0.20 | 1.60 |
| Model | 8/10 | 0.10 | 0.80 |
| Tools | 9/10 | 0.05 | 0.45 |
| **Overall** | | | **8.7/10** |

### Issues
- [Minor] Missing autocomplete attributes
- [Minor] Could add password visibility toggle

### Recommendation: APPROVE
```

**Return to @switch**

### Step 11: @switch Delivers to User

```
User: "Here's your login page!"

Files created:
- login.html
- login.css  
- login.js

Quality score: 8.7/10

The page includes:
✓ Email and password inputs
✓ Form validation
✓ Remember me option
✓ Error handling
✓ Responsive design

Minor improvements possible:
• Add autocomplete attributes
• Add password visibility toggle
```

## Workflow Metrics

| Metric | Value |
|--------|-------|
| Agents used | 4 |
| Handoffs | 4 |
| Time elapsed | ~25 minutes |
| Quality score | 8.7/10 |
| User satisfaction | High |

## Key Patterns Demonstrated

1. **Sequential execution** — Each step depends on previous
2. **Structured handoffs** — Full context transfer every time
3. **Quality gate** — Audit before delivery
4. **Clear acceptance criteria** — Every agent knows success

---

*This is how agents work together.*
