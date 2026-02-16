---
name: escalation-protocol
description: Decision escalation framework. Use when decisions exceed agent authority, involve external commitments, or require human approval. Reference this skill when uncertain about whether to proceed or escalate.
---

# Escalation Protocol

Defines when and how agents should escalate decisions to the human operator versus handling them routinely.

## When to Escalate

**Always escalate when:**
- Decision involves monetary impact above project thresholds
- Involves external commitments (clients, partners, vendors, users)
- Requires staffing or compensation changes
- Pricing or billing strategy changes needed
- Strategic direction change required
- Legal or compliance uncertainty
- Reputational risk involved
- You are uncertain about the correct action

**Handle routinely (no escalation needed):**
- Status updates and reporting
- Internal resource reallocation <20%
- Process adjustments within existing framework
- Pipeline/task stage changes based on clear criteria
- Scheduling and coordination
- Quality feedback routing
- Research and analysis tasks

## Decision Boundaries

See [CRITERIA.md](./CRITERIA.md) for detailed thresholds by category.

## Escalation Format

See [TEMPLATES.md](./TEMPLATES.md) for message formats.

## Escalation Process

1. **Identify** — pause when you encounter a decision point
2. **Check criteria** — reference CRITERIA.md for your domain
3. **Assess confidence** — if >80% confident and criteria says routine, proceed; otherwise escalate
4. **Format** — use the appropriate template from TEMPLATES.md
5. **Return** — present the escalation to the main conversation
6. **Wait** — do not proceed until human responds

## Uncertainty Rule

**When in doubt, escalate.** False escalations are preferable to unauthorized decisions. If the decision doesn't clearly fit the "routine" criteria, treat it as an escalation.
