# Escalation Criteria

Decision boundaries for agents. Projects may override these thresholds with project-specific values.

## Technical Decisions

### Routine (Agent Decides)
| Decision | Threshold | Example |
|----------|-----------|---------|
| Code changes | Within approved scope | Implement approved plan |
| Refactoring | Non-breaking, internal only | Rename internal variable |
| Bug fixes | Clear root cause, no side effects | Fix off-by-one error |
| Test additions | Any | Add missing test coverage |
| Documentation | Internal docs | Update README |

### Escalate (Human Decides)
| Decision | Trigger | Example |
|----------|---------|---------|
| Architecture change | Structural patterns, new dependencies | Add caching layer |
| API changes | External-facing contracts | Change endpoint response shape |
| Dependency changes | New packages, major version bumps | Upgrade framework version |
| Data model changes | Schema migrations | Add/remove database columns |
| Scope expansion | Work exceeds original estimate by >50% | Feature more complex than planned |

## Operations

### Routine
| Decision | Threshold | Example |
|----------|-----------|---------|
| Resource reallocation | <20% of capacity | Shift 1 day between tasks |
| Timeline adjustment | <48 hours, internal only | Move internal deadline |
| Process refinement | Within existing framework | Clarify process step |
| Status reporting | All | Generate dashboard |

### Escalate
| Decision | Trigger | Example |
|----------|---------|---------|
| External commitment | Any | Promise delivery date to anyone |
| Deadline extension | >48 hours or external-facing | Miss submission deadline |
| Resource request | >20% reallocation | Need additional support |
| Process change | New SOP or policy | Change review workflow |

## Financial

### Routine
| Decision | Threshold | Example |
|----------|-----------|---------|
| Budget tracking | Reporting only | Flag variance |
| Cost estimation | Analysis only | Estimate hosting costs |

### Escalate
| Decision | Trigger | Example |
|----------|---------|---------|
| Expenditure | Any purchase decision | Buy service or tool |
| Pricing | Any | Set or change pricing |
| Budget reallocation | Any | Move funds between categories |

## External Communication

### Always Escalate
- Client/user-facing commitments
- Contract modifications
- Partnership decisions
- Public communications
- Email sends (non-internal)
- API key or credential sharing

## Confidence-Based Fallback

If criteria is ambiguous:
- **High confidence (>80%)** and clearly routine → proceed
- **Medium confidence (50-80%)** → escalate with recommendation
- **Low confidence (<50%)** → escalate without recommendation
