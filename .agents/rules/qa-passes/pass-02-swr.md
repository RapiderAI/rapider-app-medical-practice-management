# Pass 2: SWR Caching & Live Data-Binding (No Mock Data)
**Goal:** Verify and fix if every page has SWR on each find Rapider SDK/API call, dynamically binds all returned data to the DOM, and contains ZERO hardcoded static mock records.

## Strict Rules

1. **Mandatory SWR Methods**: When loading data for initial page renders, you **MUST** use `findSWR` and `countSWR` instead of `find` and `count`. Never use SWR for write operations (create, update, delete).
2. **NO STATIC MOCK DATA OR WIREFRAME PREVIEW STUBS IN HTML MARKUP**:
   - Initial HTML markup (tables, `<tbody>`, `.detailfields`, `.list`, `.timeline`, `.orgcanvas`, metric widgets) **MUST NOT contain hardcoded static mock records** (e.g. fake user names like `Amelia Brooks`, `amelia.brooks@example.com`, `EMP-0108`, `People around Amelia`, hardcoded `<tr>` rows, fake cards, or static metric counts like "148 employees").
   - When starting from a pre-designed HTML wireframe (`_design/`), you **MUST strip** all static preview scripts (`window.PEOPLE_PAGE`, `rapider.people.design.v1`, `"No AI request or business action was sent"`, `"Design preview · AI not connected"`, `"Sample data for design review · Reset preview"`) and wire every single section of the page (hero, detail fields, related people, history timeline, tabs, forms, and AI assistant) to live `window.rapiderApi` data!
   - Containers must start empty or display loading states, and then be rendered dynamically from live SWR data.
3. **MANDATORY LIVE DOM DATA-BINDING**:
   - The result of `findSWR` / `countSWR` **MUST be bound to the DOM**.
   - **STRICTLY FORBIDDEN:** Dummy, fire-and-forget calls like `await window.rapiderApi.findSWR('EntityName')` where the return value is discarded and not bound to the page DOM.
   - If an entity is queried with `findSWR`, the page must dynamically populate the table rows, cards, or metric indicators from that data.
4. **CRITICAL CACHE INVALIDATION**:
   - After ANY write operation (create, update, delete) where the data table or UI needs to refresh to show the new data, you MUST manually invalidate the specific `sessionStorage` cache keys for that entity before calling the load function. 
   - To invalidate a specific query: `sessionStorage.removeItem('swr_find_EntityName_' + JSON.stringify(filter));`
   - To invalidate all queries for an entity: loop through `Object.keys(sessionStorage)` and remove any key starting with `swr_find_EntityName` or `swr_count_EntityName`.
   - If you do not clear the cache before reloading, the UI will reload stale data and appear as though the mutation failed.
5. **MANDATORY SDK FORM MUTATION PERSISTENCE (`<form data-save-form>`)**:
   - Every creation, edit, or change-request form (including any `<form data-save-form>`) **MUST** bind its `submit` handler to real `window.rapiderApi` mutation methods (`create`, `updateById`, `deleteById`, `startWorkflow`, or `triggerWorkflow`), invalidate SWR cache immediately after saving, and never write exclusively to local `localStorage` preview state.
6. **MULTI-SCRIPT SCOPE INTEGRITY (`esc` / `toast` Helpers)**:
   - When a page has multiple `<script>` tags (or appends a live SDK script block after a base script), any helper functions called across scripts (`esc()`, `toast()`) **MUST** either be exposed globally (`window.esc = esc; window.toast = toast;`) or explicitly declared inside the script scope so live data rendering never throws `ReferenceError: esc is not defined`.
7. **CONCURRENT FETCH RACE GUARD (`state.loading`)**:
   - Every initial/reload data fetcher (`loadData()`, `loadProfileData()`, etc.) **MUST** guard against overlapping concurrent executions (`if (state.loading) return; state.loading = true; try { ... } finally { state.loading = false; }`) so `rapider:ready`, `DOMContentLoaded`, `hashchange`, and fallback timers never trigger duplicate parallel API bursts.
8. **TWO-PHASE PROGRESSIVE HYDRATION ON MULTI-ENTITY DETAIL PAGES**:
   - On detail/profile pages that query more than 4 collections (e.g., `profile.html` querying `HrEmployee`, `HrDepartment`, `HrLocation`, `FinLegalEntity`, `HrPosition`, `HrJobProfile`, `HrDocumentRef`, `HrLifecycleEvent`, `HrChangeRequest`, `HrEmergencyContact`), launch both the Core identity promise (`HrEmployee`, `HrDepartment`, `HrLocation`, `FinLegalEntity`) and Secondary collections promise concurrently at `t=0`, `await` the Core promise first to render the hero header and work details immediately, and then `await` the Secondary promise to hydrate tab badges and timelines. Never block initial hero rendering on 10 sequential or single-batch requests.
9. **BATCH CSV IMPORT DEDUPLICATION & IMMEDIATE SWR CACHE INVALIDATION**:
   - CSV or batch import routines must deduplicate records on natural keys (e.g. `email`, `code`, `employeeId`, `sku`) before persisting.
   - Immediately following batch mutations, the handler **MUST** clear all related SWR cache entries (`window.rapiderApi.clearCache(entityName)` and loop to remove matching `swr_find_${entityName}` and `swr_count_${entityName}` from `sessionStorage`) before calling the page load/refresh function. Failing to clear SWR cache causes the UI to display stale pre-import datasets.
10. **NO UNHANDLED SYNCHRONOUS SWR PROMISE REJECTIONS (`UNHANDLED_SWR_PROMISE_REJECTION`)**:
    - Every call to `window.rapiderApi.findSWR(...)` or `window.rapiderApi.countSWR(...)` **MUST** either be `await`ed inside an `async` `try { ... } catch (err) { ... }` block, or explicitly chained with `.catch(() => [])` / `Promise.resolve(res).catch(function(){})`.
    - Furthermore, when `findSWR` / `countSWR` returns cached data immediately (`Promise.resolve(cachedData)`), the background revalidation promise **MUST** swallow or handle network/auth errors internally rather than re-throwing an unattached promise rejection (`UNCAUGHT_PAGE_ERROR`).

## ✅ BEST PRACTICE:
```javascript
// Good: Queries SWR, binds to DOM dynamically, and handles empty state
const employees = await window.rapiderApi.findSWR('HrEmployee', { limit: 50 }).catch(() => []);
renderEmployeeTable(employees);

function renderEmployeeTable(list) {
  const tbody = document.getElementById('employee-tbody');
  const countEl = document.getElementById('employee-total-count');
  if (countEl) countEl.textContent = `${list.length} employees`;

  if (!list || list.length === 0) {
    tbody.innerHTML = `<tr><td colspan="6" class="text-center py-8">
      <div class="empty-state">
        <p class="text-muted">No employees found in database.</p>
        <button class="btn btn-sm btn-primary" onclick="seedSampleEmployees()">Seed Demo Records</button>
      </div>
    </td></tr>`;
    return;
  }

  tbody.innerHTML = list.map(emp => `
    <tr>
      <td>${escapeHtml(emp.firstName)} ${escapeHtml(emp.lastName)}</td>
      <td>${escapeHtml(emp.jobTitle || '—')}</td>
      <td>${escapeHtml(emp.status || 'Active')}</td>
    </tr>
  `).join('');
}
```

## ❌ BAD PRACTICE (FLAGGED AS QA FAILURE):
```javascript
// BAD: Fire-and-forget SWR call that never touches the DOM while HTML contains hardcoded mock rows
document.addEventListener('DOMContentLoaded', async () => {
  await window.rapiderApi.findSWR('HrEmployee'); // Result ignored!
});
// BAD: Hardcoded static mock rows in HTML:
// <tbody><tr><td>Amelia Brooks</td>...</tr></tbody>
```
