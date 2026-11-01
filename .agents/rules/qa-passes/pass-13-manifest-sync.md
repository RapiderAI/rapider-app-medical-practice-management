---
trigger: always_on
---

# Pass 13: Manifest Sync
**Goal:** Ensure `app.manifest.json` matches HTML file structure while preventing menu bloat and unsafe concurrent modifications.

- **Safe Manifest Concurrency & Page-Level Fix Isolation (STRICT):**
  - When fixing a bug, adjusting styling, or updating scripts on an existing page (e.g., `overview.html`), **NEVER touch or modify `app.manifest.json`** unless the user explicitly requested schema/dataModel changes or route additions.
  - Page-level fixes MUST be isolated strictly to that page's files (`pages/<route>/<route>.html` and related assets).
  - Unnecessary touches to `app.manifest.json` cause Git merge collisions and accidentally overwrite routes or data models.
- **Route Sync:** Check that every HTML file in `pages/` has a corresponding route in the `webPages` array of `app.manifest.json`.
- **Menu Visibility (No Bloat):** Do NOT bloat the menu by displaying every single page. Only main index/list pages (e.g., `dashboard`, `accounts`, `leads`) should have `"displayOnMenu": true`. All sub-pages, edit pages, detail pages, and hidden features (e.g., `new-lead`, `account-detail`) MUST have `"displayOnMenu": false`.
- **Formatting `name` and `icon`:** The `name` property is used directly as the display label in the sidebar, so it MUST be properly capitalized (e.g., `"name": "Dashboard"`, not `"name": "dashboard"`). The `icon` property MUST include the full FontAwesome classes (e.g., `"icon": "fas fa-chart-pie"`, not `"icon": "chart-pie"`).
- **Sidebar Grouping (Minimum 3 Items Rule - STRICT):**
  - When grouping pages under a section header in the sidebar, **each section title MUST contain at least 3 menu items** (`count >= 3`).
  - **Strict Ban on Micro-Headers:** NEVER create a section title for only 1 or 2 menu items (e.g. separate section titles for `DASHBOARD -> Dashboard`, `PROJECTS -> Projects`, `ISSUES -> Issues`). Separating each individual item under its own title creates excessive visual noise, looks fragmented, and is strictly forbidden because it looks untidy.
  - **Consolidation Options:**
    - If you have related items, group them under a single broad main title (e.g., `"Overview"`, `"Workspace"`, or `"Management"`).
    - If you do not have at least 3 menu items to form a group, leave them **without a section title** (omit `"title"` or set `"title": ""`). They will render cleanly as flat root-level sidebar items.
- **Ordering:** Use the `"order"` property to sort items within their groups.
- **Suite Definition Sync (`appSuite`):** Verify that `appSuite` is configured with `key`, `title`, `shortTitle` (e.g. `"HR Suite"`), and `icon` (e.g. `"fas fa-users"`). The icon must match the canonical FontAwesome icon for the application's suite.
- **Manifest Status Invariant (STRICT):** The root field `status` in `app.manifest.json` MUST be at least `"app-metadata-completed"` (e.g. `"app-metadata-completed"`, `"pages_implemented"`, `"qa_passed"`, or `"completed"`). It is strictly FORBIDDEN to leave `status` as `"ui-implementation-plan-in-progress"` or `"data-models-in-progress"` when starting to build app pages. If left in an in-progress wizard status, the Rapider UI treats the application as an unfinished wizard and displays `"<- Back to Builder"` instead of the completed app layout.

**❌ FORBIDDEN (Untidy 1-Item Micro-Headers):**
```json
[
  { "title": "Dashboard", "name": "Dashboard", "displayOnMenu": true },
  { "title": "Projects", "name": "Projects", "displayOnMenu": true },
  { "title": "Issues", "name": "Issues", "displayOnMenu": true }
]
```
*(Every item above has its own 1-item section title, making the sidebar cluttered and untidy).*

**✅ BEST PRACTICE (Consolidated Under Main Title with 3+ Items):**
```json
[
  { "title": "Overview", "name": "Dashboard", "displayOnMenu": true, "order": 1 },
  { "title": "Overview", "name": "Projects", "displayOnMenu": true, "order": 2 },
  { "title": "Overview", "name": "Issues", "displayOnMenu": true, "order": 3 },
  { "title": "Overview", "name": "Sprints", "displayOnMenu": true, "order": 4 },
  { "title": "Overview", "name": "Sprint Board", "displayOnMenu": true, "order": 5 }
]
```

**✅ BEST PRACTICE (Ungrouped / Flat When Fewer Than 3 Items):**
```json
[
  { "title": "", "name": "Dashboard", "displayOnMenu": true, "order": 1 },
  { "title": "", "name": "Settings", "displayOnMenu": true, "order": 2 }
]
```

**✅ BEST PRACTICE (Hidden Sub-Page):**
```json
{
  "title": "",
  "name": "lead-detail",
  "pageTitle": "Lead Detail",
  "displayOnMenu": false,
  "icon": "fas fa-info-circle"
}
```