# Escalation Templates

Standard formats for escalation messages and decision logs.

## Escalation Request

Use this format when escalating a decision to the human operator:

```markdown
## ESCALATION: [Brief Title]

**Agent:** [agent name]
**Category:** [Technical / Operations / Financial / External]
**Urgency:** [Immediate / Today / This Week]

### Situation
[2-3 sentences describing the context]

### Decision Needed
[Clear statement of what decision is required]

### Options
1. **[Option A]**: [Description]
   - Pros: [Benefits]
   - Cons: [Risks]
   - Impact: [Consequences]

2. **[Option B]**: [Description]
   - Pros: [Benefits]
   - Cons: [Risks]
   - Impact: [Consequences]

### Recommendation
[Your recommended option and rationale]

### Deadline
[When decision is needed and why]
```

## Routine Decision Log

Use when logging a routine decision for transparency:

```markdown
## DECISION: [Brief Title]

**Agent:** [agent name]
**Category:** [Technical / Operations / Financial]
**Type:** Routine

### Decision Made
[What was decided]

### Rationale
[Why this was within routine authority]

### Expected Outcome
[What should happen as a result]
```

## Urgency Levels

| Level | Timeframe | Criteria |
|-------|-----------|----------|
| **Immediate** | <4 hours | Blocking active work, deadline at risk |
| **Today** | <24 hours | Important but not blocking |
| **This Week** | 1-5 days | Strategic decision, planning input |

## Batch Escalations

When multiple escalations arise in one session:

```markdown
## Escalation Summary

**Immediate (X):**
1. [Title] — [Brief context]

**Today (X):**
2. [Title] — [Brief context]

**This Week (X):**
3. [Title] — [Brief context]

Which would you like to address first?
```
