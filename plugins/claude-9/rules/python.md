<!-- SOUL:BEGIN v1.0.0 -->
# Python Standards

Standards for all Python projects in this workspace. Codifies `ruff.toml` and common conventions.

## Runtime & Tooling

- **Python**: 3.12+
- **Package manager**: uv (not pip)
- **Linter/Formatter**: ruff (line-length 120, double quotes, space indent)
- **Type checker**: mypy (strict mode preferred)
- **Test framework**: pytest
- **Pre-commit**: ruff check + ruff format

## Ruff Configuration

All projects inherit from the workspace `ruff.toml`:
- Line length: 120
- Target: Python 3.12
- Selected rules: E, W, F, I, N, UP, B, C4, SIM
- Formatter: double quotes, space indent
- E501 ignored (formatter handles line length)

## Project Structure

```
project/
├── src/<package>/       # Source code (src layout)
│   ├── __init__.py
│   └── ...
├── tests/
│   ├── conftest.py
│   └── test_*.py
├── pyproject.toml       # Project metadata + dependencies
└── CLAUDE.md            # Project-specific instructions
```

## Code Conventions

- Use type hints on all function signatures
- Prefer `from __future__ import annotations` for forward references
- Use `dataclass` or `pydantic.BaseModel` for data structures
- Prefer pathlib over os.path
- Use f-strings over .format() or % formatting
- Import ordering: stdlib → third-party → local (enforced by ruff isort)

## Testing

- Name test files `test_<module>.py`
- Use fixtures over setup/teardown
- Prefer `pytest.raises` for exception testing
- Use `tmp_path` fixture for filesystem tests
- Run: `uv run pytest` (from project root)

## Common Commands

```bash
uv run pytest                    # Run tests
uv run ruff check src/           # Lint
uv run ruff format src/          # Format
uv run mypy src/<package>/       # Type check
```
<!-- SOUL:END -->
