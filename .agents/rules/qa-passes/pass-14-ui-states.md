# Pass 14: Empty/Loading/Error States & Demo Data Seeding
**Goal:** Check UI edge cases (Empty, Loading, Error), eliminate fake static mock fallback, and provide 1-click Demo Data Seeding.

## Strict Rules

1. **Mandatory Empty State on `[]`**:
   - If `findSWR` returns `[]` or `null`, you **MUST** show an explicit "Empty State" UI rather than falling back to hardcoded mock records or rendering a blank table.
   - The empty state must clearly convey: "No records found in database."
2. **1-Click Demo Data Seeding Action (EMPTY STATE ONLY)**:
   - For all entity list views and overview dashboards, the Empty State **MUST provide a 1-click "Seed Demo Records" action** alongside the standard "Create / Add Record" button.
   - When clicked, this action must programmatically create initial records via `window.rapiderApi.create(entityName, sampleRecord)` using canonical records from `sample-data.json`, invalidate SWR cache, and refresh the UI so live records appear.
   - **STRICT BAN ON SEED BUTTONS IN PAGE HEADERS & TOOLBARS:**
     - 'Install Sample Data' or 'Seed Demo Records' buttons are **STRICTLY FORBIDDEN** in `<header>`, top navigation bars, breadcrumb rows, or primary page action headers.
     - They may **ONLY** be rendered inside the empty-state card when `records.length === 0`.
     - When records exist in the database, the seed action must be completely absent from the page so it never clutters regular operational views.
   - **STRICT BAN ON UNCONDITIONAL AUTO-SEEDING ON PAGE LOAD (`AUTO_SEED_ON_LOAD_VIOLATION`):**
     - **NEVER** automatically invoke `window.rapiderApi.create(...)` inside `DOMContentLoaded` when `findSWR` returns `[]`. Auto-seeding on page load spams `POST` requests on every navigation and triggers `HTTP 400` console errors if test tables are not yet provisioned. Demo seeding must ONLY execute when the user explicitly clicks the "Seed Demo Records" button inside the empty-state card.
3. **Loading Skeletons / Spinners**:
   - While data is fetching initially, display loading skeletons or a clean spinner. Do not render static fake records during loading.
4. **Search & Filter Inputs**:
   - Every search bar, filter input, or select dropdown MUST have a way to clear it (e.g. an "x" button or "Clear filters") to reset the data view.
5. **Active Filter State**:
   - If a page has multiple filters, conditionally render an "Active Filters" indicator summarizing what is filtered and provide a "Clear All" button.
6. **Alternative Views (Kanban vs List)**:
   - If a page displays data in a Kanban board layout, it MUST also provide a List View toggle with proper empty states in both views.

## ✅ BEST PRACTICE:
```javascript
if (!records || records.length === 0) {
  document.getElementById('table-body').innerHTML = `
    <tr>
      <td colspan="6" class="p-8 text-center">
        <div class="empty-state">
          <i class="fas fa-folder-open text-3xl text-gray-400 mb-2"></i>
          <h4 class="font-semibold text-gray-700">No records found</h4>
          <p class="text-sm text-gray-500 mb-4">Get started by creating your first entry or seed demo records.</p>
          <div class="flex justify-center gap-3">
            <a href="#/add" class="btn btn-primary">Add Record</a>
            <button class="btn btn-secondary" onclick="seedDemoData()">Seed Demo Records</button>
          </div>
        </div>
      </td>
    </tr>
  `;
}
```
