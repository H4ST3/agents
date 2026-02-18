# Notion MCP Safety

Rules for safe Notion MCP operations.

**Always ask first**:
- Any operation that removes or overwrites content

**Critical Issue**: Content replacement operations can destroy page hierarchy and break synced content.

- `<page url="...">` blocks represent **nested subpages** — replacing them with `<mention-page>` converts them to links and orphans the pages
- `<database>` blocks similarly represent embedded databases that will be orphaned if replaced
- `<synced_block>` and `<synced_block_reference>` blocks contain **canonical information** shared across multiple locations — replacing these breaks the sync relationship
- `replace_content` and `replace_content_range` will delete any `<page>`, `<database>`, or synced blocks in the replaced section

**Synced Blocks — Always Ask Permission**:
- Before removing or replacing any `<synced_block>` or `<synced_block_reference>`, explicitly ask the user

**Safe operations**: `insert_content_after`, create pages/databases/entries, read/query/search, `update_properties`

**Require explicit permission**: `replace_content`, `replace_content_range`, any delete operation

**Best practice**: Use `insert_content_after` to add new links rather than replacing sections that contain `<page>` blocks.
