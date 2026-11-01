# Multi-Pass QA Workflow

To ensure the highest quality of generated Rapider apps and eliminate back-and-forth QA sessions, agents MUST process the application's HTML pages using a strict **Multi-Pass Loop**.

## The Loop Mechanism
When instructed to finalize or QA an app, you must execute the following 20 passes in exact sequential order. 

**CRITICAL RULE:** During a pass, you must ONLY focus on the specific goal of that pass. Do not get distracted by or fix unrelated issues. You must process **ALL HTML pages** for the current pass before moving on to the next pass. If a page requires no changes for the current pass, skip it and move to the next page.

**PREREQUISITE:** Before starting the QA workflow, you MUST first review the general App Builder rules (`app.manifest.json` structure, page HTML rules, and core `AGENTS.md` rules). This prevents breaking existing working behaviors (e.g. properly casing names or formatting icons).

Before executing a pass, you MUST read the detailed rule file for that pass.

---

### Pass 1: Routing & Events
[View Detailed Rules](qa-passes/pass-01-routing.md)
**Goal:** Verify and fix if every button has the correct route or event.

### Pass 2: SWR Caching Implementation
[View Detailed Rules](qa-passes/pass-02-swr.md)
**Goal:** Verify and fix if every page has Stale-While-Revalidate (SWR) on each Rapider SDK/API call.

### Pass 3: Data Model & UI Compatibility
[View Detailed Rules](qa-passes/pass-03-data-models.md)
**Goal:** Verify and fix if the data models and page elements are compatible.

### Pass 4: Modal Usage
[View Detailed Rules](qa-passes/pass-04-modals.md)
**Goal:** Verify and fix if modals are used correctly.

### Pass 5: Drawer Usage
[View Detailed Rules](qa-passes/pass-05-drawers.md)
**Goal:** Verify and fix if drawers (slide-outs) are used correctly.

### Pass 6: Responsive Design
[View Detailed Rules](qa-passes/pass-06-responsive.md)
**Goal:** Verify and fix responsive design across all screen sizes.

### Pass 7: Theme Support (Dark/Light)
[View Detailed Rules](qa-passes/pass-07-themes.md)
**Goal:** Verify and fix dark and light theme consistency.

### Pass 8: Rapider Notifications
[View Detailed Rules](qa-passes/pass-08-notifications.md)
**Goal:** Verify and fix Rapider notifications.

### Pass 9: SDK Payloads
[View Detailed Rules](qa-passes/pass-09-payloads.md)
**Goal:** Verify and fix the payloads that are sent to the Rapider SDK.

### Pass 10: Rapider Components
[View Detailed Rules](qa-passes/pass-10-components.md)
**Goal:** Verify and fix Rapider (or NG Zorro) components usage.

### Pass 11: E2E Tests & Expectations
[View Detailed Rules](qa-passes/pass-11-e2e-expectations.md)
**Goal:** Verify and fix E2E tests and expectations.

### Pass 12: Asset Externalization & Performance
[View Detailed Rules](qa-passes/pass-12-asset-externalization.md)
**Goal:** Verify and fix inline assets to prevent iframe re-parsing performance issues.

### Pass 13: Manifest Synchronization
[View Detailed Rules](qa-passes/pass-13-manifest-sync.md)
**Goal:** Verify and fix alignment between HTML pages and `app.manifest.json`.

### Pass 14: UI States (Empty, Loading, Error)
[View Detailed Rules](qa-passes/pass-14-ui-states.md)
**Goal:** Verify and fix the handling of non-ideal UI states.

### Pass 15: Security & Secrets
[View Detailed Rules](qa-passes/pass-15-security.md)
**Goal:** Verify and fix hardcoded secrets or environment-specific data.

### Pass 16: Accessibility (A11y)
[View Detailed Rules](qa-passes/pass-16-accessibility.md)
**Goal:** Verify and fix accessibility issues across all elements.

### Pass 17: Input Formatting & Masking
[View Detailed Rules](qa-passes/pass-17-input-formatting.md)
**Goal:** Verify and fix formatting and masking of specific inputs (like phone numbers) using IMask.

### Pass 18: Kanban & List Views
[View Detailed Rules](qa-passes/pass-18-kanban-list-views.md)
**Goal:** Verify and fix that all Kanban boards have a standard HTML List View toggle for detailed editing.

### Pass 19: UI, Refresh, and ID Standards
[View Detailed Rules](qa-passes/pass-19-ui-best-practices.md)
**Goal:** Ensure tables are responsive, caches are properly invalidated, form editing states are clean, submissions are protected, and backend ID fields are handled correctly.

### Pass 20: Search, Active Filter Tags & Reset Standards
[View Detailed Rules](qa-passes/pass-20-search-filters.md)
**Goal:** Verify that search handles bulk vs. paginated data properly, displays active search and filter tags with individual tag removals, and includes a clear button restoring full original data.

### Pass 21: Suite Brand & Collapsible Sidebar Navigation Standards
[View Detailed Rules](qa-passes/pass-21-collapsible-suite-sidebar.md)
**Goal:** Ensure every Rapider application displays an authentic Suite Icon and Suite Name in its sidebar header (completely replacing legacy fake "Rapider" logos and "rapider ai" branding), implements full collapsible sidebar navigation, hides all text labels in collapsed mode, provides right-caret expand hover mechanics on the top suite icon, and persists collapsed state in localStorage.

---

## The `app.build.json` Evidence Ledger & Change Tracking Protocol

Every Rapider microapplication repository contains an **`app.build.json`** file in its root directory. This file serves as the deterministic audit trail and evidence ledger for all QA passes, test runs, and page checksums.

### Core Invariants for AI Agents:
1. **Evidence of Success:** Whenever you execute QA passes or E2E tests, the results, pass/fail status, and page checksums are deterministically written to `app.build.json`.
2. **Checksum-Based Stale Page Detection:** Each page has a recorded `fileHash` (SHA-256). If you edit or modify ANY `.html` file under `pages/`, the file hash becomes stale.
3. **Mandatory Re-Audit on Modification:** Whenever you change a page:
   - You **MUST** re-run the QA pass audit for that page and update `app.build.json`.
   - You can verify compliance by running:
     ```bash
     node ../rapider-apps-development/scripts/run-qa-passes.js --app={folderName} --check-stale
     ```
   - If `--check-stale` reports stale pages, you **MUST** execute the QA passes:
     ```bash
     node ../rapider-apps-development/scripts/run-qa-passes.js --app={folderName}
     ```
4. **Git Commit Requirement:** `app.build.json` MUST be staged and committed alongside page changes:
   ```bash
   git add pages/ app.build.json
   ```


