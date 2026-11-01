# Guide: Generating UI HTML Pages

When you are generating the actual frontend code for a page, you **MUST** save the generated HTML file in a nested directory based on the route key at the root of the repository: `pages/[route]/[route].html` (e.g., `pages/dashboard/dashboard.html`). This exact folder structure is required for the backend synchronization to work. You are acting as a Full-Stack UI/UX Engineer. Your objective is to generate a **single, fully functional HTML file** containing structure, styling, and working Vanilla JavaScript.

You must deliver a complete, interactive application that users can run inside their browser sandbox. The UI must be built using standard Tailwind CSS alongside the custom semantic theme, and the JavaScript MUST execute REAL CRUD operations against the backend using the injected `window.rapiderApi` SDK.

## 1. HTML Structure & Asset Loading

Your output must be a standard, standalone HTML5 document. You must load Tailwind CSS via CDN and inject the custom theme file.

Generate a complete, valid HTML5 document containing `<html>`, `<head>`, and `<body>` tags. Include the following in the `<head>`:

1. **FontAwesome:** `<script src="https://kit.fontawesome.com/5b23df26dc.js" crossorigin="anonymous"></script>`
2. **Custom Components Bundle:** `<script src="/assets/js/rapider-components.js" defer></script>`
3. **Tailwind CDN:** `<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>`
4. **Custom Theme Import:** `<link rel="stylesheet" href="/assets/themes/rapider-tailwind-theme.css">` (Assume `/assets/` is available at the root).

## 2. Strict Semantic Tailwind Styling

Standard Tailwind colors are globally overridden by the custom theme. You **MUST STRICTLY** use the following semantic utility classes to ensure dark/light mode compatibility.

* **❌ BANNED:** Arbitrary bracket values (e.g., `w-[150px]`, `text-[13px]`) and hardcoded hex colors (e.g., `bg-[#ff0000]`). Use standard Tailwind sizing (e.g., `w-32`, `p-4`) and the semantic colors below.
* **✅ Backgrounds:** `bg-body-background`, `bg-component-header`, `bg-component-inner`, `bg-alt-background`, `bg-input-background`, `bg-section-background`, `bg-table-background`.
* **✅ Text & Typography:** `text-primary-text`, `text-secondary-text`, `text-heading` (for h1-h6), `text-placeholder`, `text-link`.
* **✅ Borders:** `border-primary-border`, `border-secondary-border`.
* **✅ Interactive & Buttons:** `bg-primary`, `bg-button-bg`, `text-primary-button-text`, `text-secondary-button-text`.
* **✅ States & Hovers:** `hover:bg-hover-default`, `hover:bg-hover-primary`, `hover:bg-hover-danger`, `text-danger`, `text-success`, `text-warning`, `text-info`.
* **✅ Focus & Shadows:** `focus:ring-focus-ring`, `shadow-default`, `shadow-thick`.

### Responsive Layouts & Canonical App Shell Hierarchy
Because your output is rendered inside a resizable preview iframe/pane, you MUST NOT use standard viewport media queries (e.g., `sm:`, `md:`, `lg:`). 
* Always wrap your main layout container with `@container`.
* Use container query modifiers (`@sm:`, `@md:`, `@lg:`) on child elements so the UI adapts accurately to the container's physical width. Container query classes (`@md:`) **MUST NOT** be used unless the container explicitly declares `@container`.
* **Canonical App Shell Structure (Fixed `h-16` Header & Single Scrollbar):**
  ```html
  <div class="layout">
    <!-- Sidebar (Collapsible) -->
    <aside class="sidebar w-64 border-r border-border-color flex flex-col shrink-0">
      <!-- Suite Brand Header with Collapse Button -->
      <div class="brand-row">
        <a class="brand" href="#/overview" title="HR Suite">
          <span class="suite-icon-container">
            <i class="suite-icon fas fa-users"></i>
            <i class="suite-expand-icon fas fa-chevron-right"></i>
          </span>
          <span class="suite-title">HR Suite</span>
        </a>
        <button type="button" class="sidebar-collapse-btn" title="Collapse sidebar" aria-label="Collapse sidebar">
          <i class="fas fa-chevron-left"></i>
        </button>
      </div>
      <!-- In CSS: .sidebar.sidebar-collapsed .sidebar-label { display: none !important; } -->
    </aside>

    <!-- Main Viewport -->
    <div class="flex-1 flex flex-col h-screen overflow-hidden">
      <!-- Fixed Header: EXACTLY h-16 (64px) -->
      <header class="h-16 shrink-0 border-b border-border-color bg-background/95 backdrop-blur flex items-center justify-between px-6 z-30">
        <!-- Title, project scope, and actions -->
      </header>

      <!-- Scrollable Main Viewport: NEVER min-h-screen! -->
      <main class="flex-1 overflow-y-auto p-6 md:p-8 @container">
        <div class="max-w-7xl mx-auto w-full space-y-6">
          <!-- Page content -->
        </div>
      </main>
    </div>
  </div>
  ```
* **STRICT BAN ON `min-h-screen` ON INNER VIEWPORTS:** Inner viewports inside the shell must never use `min-h-screen` or unmanaged nested scrolling, which causes double vertical scrollbars.
* **Non-wrapping Status Badges:** Status pills and badges must include `whitespace-nowrap shrink-0 inline-flex items-center`.

### High-Contrast Button Invariant
* Primary buttons (`bg-primary`) and danger buttons (`bg-danger`, `bg-red-600`) MUST ALWAYS enforce white text:
  - Add `!text-white text-white` classes.
  - Add explicit inline style: `style="color: #ffffff !important;"`.
* **BANNED:** Never use `text-white` on light or neutral backgrounds like `bg-button-bg` or `bg-alt-background`. Secondary buttons must use `text-secondary-button-text`.
* **BANNED:** "Install Sample Data" or "Seed Demo Records" buttons are **STRICTLY FORBIDDEN** in the header or toolbar. They may ONLY be rendered inside an empty-state container when `records.length === 0`.


## 3. Functional JavaScript & Real API Integration

Your generated HTML must include a `<script>` tag containing vanilla JavaScript to make the page 100% interactive.

### The `window.rapiderApi` SDK
Do NOT mock API calls. A proxy SDK is already injected into your environment. You MUST use it to communicate with the backend data models defined in `app.manifest.json`.

* `await window.rapiderApi.create(entityName, body)`: Create a new entity instance.
* `await window.rapiderApi.findSWR(entityName, filter)`: Find an array of entities with a LoopBack filter using Stale-While-Revalidate caching for immediate rendering. You **MUST** use this instead of `find`.
  * *Example:* `const data = await window.rapiderApi.findSWR('CrmAccount', { where: { isDeleted: false }, order: ['createdDate DESC'] });`
* `await window.rapiderApi.findById(entityName, id, filter)`: Get a specific entity object by its ID.
* `await window.rapiderApi.updateById(entityName, id, body)`: Patch specific fields of an entity by ID.
* `await window.rapiderApi.deleteById(entityName, id)`: Delete an entity by ID.
* `await window.rapiderApi.countSWR(entityName, where)`: Return the count of entities matching a where filter using SWR caching. You **MUST** use this instead of `count`.
* `await window.rapiderApi.startWorkflow(workflowName, payload)`: Triggers a backend workflow asynchronously.
  * **Strict Workflow Decision Rule (IF AND ONLY IF):** Define and trigger a workflow **IF AND ONLY IF** the action cannot be achieved by one or multiple standard CRUD calls (e.g. converting markdown to PDF, multi-step AI pipelines like analyzing data and generating a PDF report, batch OCR, multi-language document translation). For standard entity CRUD operations, always use CRUD methods instead.
  * **Draft Manifest Requirement (`type: "pageWorkflow"`):** When using `startWorkflow('{uniqueWorkflowName}', payload)`, the workflow MUST be defined in detail and saved into `app.manifest.json` under `workflows` with `type: "pageWorkflow"`, `status: "draft"`, and detailed `input` and `output` schemas.

### State and DOM Manipulation
Create local Javascript state to hold fetched data, write functions to render the UI dynamically based on the state, and bind event listeners to buttons and forms. Re-fetch or update the local state and DOM after successful API mutations.

### 🚫 STRICT BAN: No Static Mock Records in HTML Markup
- **Never hardcode static mock entity records, fake cards, or static `<tbody>` rows in HTML markup.**
- All entity tables, card lists, and metric figures must be rendered dynamically via JavaScript from `window.rapiderApi.findSWR(...)` and `window.rapiderApi.countSWR(...)`.
- When `findSWR` returns `[]` (empty database), the page MUST render a clean Empty State with an action to create the first record or "Seed Demo Records". Never leave fake mock data on screen when the backend is empty!

## 4. UI Actions, Overlays & Navigation

The SDK exposes methods to control the parent application's layout, navigation, and overlays. Use these to build rich, multi-page interactions directly from your Javascript event listeners.

* **`window.rapiderApi.showNotification({ type, message })`**
  * **type**: `'success' | 'error' | 'info' | 'warning'`
* **`window.rapiderApi.showConfirmModal({ title, message, okText, cancelText, isDanger, onConfirm, onCancel })` / `window.showConfirmModal(options)`**
  * Opens a confirmation modal dialog.
* **`window.rapiderApi.navigate(route)`**
  * Navigates the parent router to a new URL.
* **`window.rapiderApi.showPageModal({ route, payload, title, width })`**
  * Opens a modal rendering another dynamic page definition.
* **`window.rapiderApi.showPageDrawer({ route, payload, title, placement, size, width })`**
  * Opens a sliding drawer from the edge of the screen. `placement` can be `right`, `left`, `top`, `bottom`.
* **`window.rapiderApi.showPageSplitter({ route, payload, title, icon, defaultSize, min, max, resizable, layout })`**
  * Transforms the current view into a resizable split-pane, projecting the target route side-by-side with the current page.

### 🚫 STRICT BAN: No Pure JS `alert()`, `confirm()`, or `prompt()`
- **NEVER use pure JavaScript `alert()`, `confirm()`, or `prompt()` anywhere in page scripts.**
- Pure JS alerts halt UI execution, break iframe sandboxes, and create a poor user experience.
- **For confirmations (deleting records, status transitions, irreversible actions):**
  Always use a nice modal confirmation dialog (e.g. `showConfirmModal` or a styled Tailwind confirmation modal / popconfirm). The modal must display:
  - An informative title and clear description message (including the entity or item name being deleted).
  - Explicit action buttons: "Cancel" and "Delete" (or "Confirm").
  - Danger styling (red badge/button) for destructive operations.
  - Double-click / re-entrancy protection.
  ```javascript
  showConfirmModal({
    title: 'Delete Item',
    message: `Are you sure you want to delete "${itemName}"? This action cannot be undone.`,
    okText: 'Delete Item',
    isDanger: true,
    onConfirm: async () => {
      await window.rapiderApi.deleteById('EntityName', id);
      window.rapiderApi.showNotification({ type: 'success', message: 'Item deleted successfully' });
      await loadItems();
    }
  });
  ```
- **For notifications, errors, and status feedback:**
  Always use `window.rapiderApi.showNotification({ type: 'success' | 'error' | 'warning' | 'info', message: '...' })`. Never use `alert()`.

**CRITICAL**: If you need to pass data to a detail view (e.g., an ID), you MUST send it as a `payload` object (e.g., `payload: { id: recordId }`) when calling `showPageModal`, `showPageDrawer`, or `showPageSplitter`. The child page being opened MUST define its own input shape and strictly read this data dynamically. Because the child page may be loaded in a standard iframe (`app-harness`) OR a `blob:` iframe sandbox (`rapider-ui`), `window.location.search` might be empty. You MUST attempt to read from both: `const urlParams = new URLSearchParams(window.location.search); const id = urlParams.get('id') || (window.rapiderApi ? window.rapiderApi.getRouteParam('id') : null);`. DO NOT attempt to read `window.parent.location.hash` or use any other hacky cross-origin DOM lookups, as components are rendered in isolated app-agnostic sandboxes.

## 5. Cross-Iframe Communication (Event Bus)

Because components might be rendered in separate, isolated `iframe` sandboxes, they cannot access each other's `window` objects directly. Use the built-in Event Bus to communicate.

* **`window.rapiderApi.broadcast(eventName, payload)`**: Sends data out to all other iframes.
  * *Example:* `window.rapiderApi.broadcast('UPDATE_CHART_DATA', { value: 5000 })`
* **`window.rapiderApi.on(eventName, callbackFunction)`**: Listens for incoming data.
  * *Example:* `window.rapiderApi.on('UPDATE_CHART_DATA', (payload) => { /* Mutate DOM */ })`

## 6. Custom Component Dictionary (Dynamic Fetching)

Our system exposes powerful proprietary Web Components (like `<rapider-chart>`, `<rapider-select>`, `<rapider-tooltip>`, `<rapider-phone-input>`, `<rapider-kanban>`, `<rapider-list-grid>`) that are already bundled in `rapider-components.js`. Instead of building raw HTML equivalents or hacking custom masks, you **must** use these components when appropriate.

### 📞 Phone Number Fields: `<rapider-phone-input>`
Whenever building a page with phone inputs (leads, contacts, accounts, users, settings):
- **NEVER** use plain text inputs with hardcoded single-country masks (like US-only `+{1} (000) 000-0000`).
- **ALWAYS** use `<rapider-phone-input>` (or `RapiderPhoneInput.attach(inputEl)`):
  ```html
  <rapider-phone-input id="leadPhone" default-country="US"></rapider-phone-input>
  ```
- Reading `.value` (e.g. `document.getElementById('leadPhone').value`) transparently returns the full international number with country dial code (`+1 (534) 454-5454`) or custom text.
- Includes 45+ international countries with flags and dial codes, dynamic mask formatting per country, and a "Custom" option (`🌐 Custom`) for freeform unmasked numbers.

1. **Discover Available Components:**
   Fetch `https://dev.app.rapider.ai/assets/components/components.json?t=[TIMESTAMP]` (replace `[TIMESTAMP]` with the current unix timestamp to bypass caching).
   This JSON array will list all available components (`tag`), a brief `description`, and a `docUrl`.

2. **Read Component Documentation:**
   If you find a component that fits your needs (e.g., you need to render a chart or phone input), you **MUST** fetch its detailed markdown documentation from the URL provided in `docUrl`.
   This markdown file contains the exact Inputs, Outputs, and Usage Examples for the component. You must read it *before* you write the HTML to ensure you are passing the correct data structures.

## 7. Manifest Synchronization (Mandatory)

The `app.manifest.json` file is the ultimate source of truth. Every time you generate or update a UI page, you **MUST** update the `app.manifest.json` file to explicitly link the implementation to the plan.

1. Ensure the `webPages` array exists at the root of `app.manifest.json`.
2. Add a new object to the `webPages` array with the following mapping:
```json
{
  "name": "Dashboard",
  "route": "dashboard",
  "htmlFilePath": "pages/dashboard/dashboard.html",
  "implementationPlanRoute": "dashboard"
}
```
**CRITICAL**: You MUST include the `htmlFilePath` containing the exact relative path from the repository root (e.g., `pages/dashboard/dashboard.html`). Do not rely on convention alone; the backend requires this path explicitly in the manifest.

## 8. Search, Active Filter Tags & Reset Standards

When generating list/table pages with search and filters:
1. **Search Mode**:
   - **Bulk Data (findSWR without pagination)**: Perform client-side JavaScript filtering across primary text fields synchronously without an API call.
   - **Paginated Data (with limit/skip)**: Query the backend API using debounced input with `skip: 0`.
2. **Active Filter Tags Bar (`#activeFilterTagsBar`)**:
   - Always display dismissible tag chips for active search queries (`Search: "..." ✕`) and active filters (`Status: "..." ✕`).
   - Include a one-click "Clear all" button (`#btnClearAllFilters` / `window.clearAllFilters()`) that clears all search inputs, resets filters to default ("ALL"), and restores the full original dataset.
   - Safely escape all search terms and filter labels with `escapeHtml()` to prevent XSS.
3. **Synchronous Multi-View Updates**:
   - Re-render both data tables/lists and Kanban boards immediately upon applying or clearing filters.

## 9. Pre-Designed HTML Wireframe Conversion, Record ID Routing & Detail Page Integrity (Mandatory)

When converting pre-designed `_design/*.html` wireframes into working pages (`pages/[route]/[route].html`):
1. **Strict Record ID Routing (`?id=<uuid>`, NEVER `?person=<name>` or `?name=<title>`)**:
   - Every link from any list, table, card, org chart, or activity item to a record detail/edit/action page (`#/profile`, `#/edit-employee`, `#/change-employee`, etc.) **MUST** pass the record's unique database `id`: `#/profile?id=${record.id}`.
   - Never route by display name (`?person=Marcus+1+Vance`).
2. **100% Dynamic Field Hydration on Detail Pages (Zero Leftover Wireframe Persona Data)**:
   - On detail/profile pages, updating only the hero title while leaving hardcoded wireframe fields (e.g., `amelia.brooks@example.com`, `EMP-0108`, `Maya Chen`, `Product & Design`, `People around Amelia`, `Help me prepare Amelia's upcoming review...`, or hardcoded `Recent history` items) is a critical bug.
   - Every single field, badge, relational card, timeline, and form input value must be dynamically hydrated from the resolved record (`record.id`) and its related entities (`departmentId`, `managerId`, `locationId`, `legalEntityId`).
3. **Detail Page Tabs Must Switch In-Page Panels (Never Navigate Away to Root App Pages)**:
   - Tabs inside a record detail page (e.g. `Overview`, `Job & employment`, `Documents`, `History & changes` inside `<nav class="tabs">`) **MUST** switch in-page tab panels (`data-tab="..."` / `[data-tab-panel="..."]`) scoped strictly to `employeeId === currentRecord.id`.
   - Never wire detail-page tabs as `<a href="#/documents">` or `<a href="#/lifecycle">` that navigate the user out of the record profile to global app pages.
4. **Real Rapider AI Assistant & Thread SDK Wiring (Zero Dead Preview Mocks)**:
   - Strip all static design-preview AI mocks (`"Design preview · AI not connected"`, `"No AI request or business action was sent"`, `"Sample data for design review"`, `data-action="reset-preview"`, and `window.PEOPLE_PAGE` wireframe blocks).
   - Wire all `Ask Rapider` buttons (`[data-action="ai"]`), inline thread forms (`[data-ai-inline]`), and AI drawer forms (`[data-ai-form]`) to `window.rapiderApi.triggerWorkflow(...)` / `window.rapiderApi.broadcast('RAPIDER_AI_ASSISTANT_QUERY', ...)` passing live page and record context (`appSlug`, `route`, `recordId`, `recordSummary`, `prompt`).
5. **Mandatory SDK Form Mutation Persistence (`<form data-save-form>`)**:
   - Every creation, edit, or change-request form (including `<form data-save-form>`) **MUST** bind its `submit` handler to `window.rapiderApi` mutation methods (`create`, `updateById`, `deleteById`, `startWorkflow`, or `triggerWorkflow`) and invalidate SWR cache upon completion — never save only to `localStorage` preview state.
6. **Multi-Script Helper Scope Integrity (`window.esc` / `window.toast`)**:
   - When a page has multiple `<script>` blocks, helper functions like `esc()` and `toast()` called in subsequent script tags **MUST** be exposed on `window` (`window.esc = esc; window.toast = toast;`) or defined locally inside each script scope to prevent runtime `ReferenceError` crashes during SWR data rendering.
