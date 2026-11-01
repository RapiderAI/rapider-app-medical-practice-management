# Pass 20: Search, Active Filter Tags & Reset Standards

**Goal:** Ensure search works properly based on data fetch architecture (client-side in-memory filtering for bulk datasets vs. debounced API querying for paginated datasets), displays dismissible active search & filter tags with individual removal, provides a one-click "Clear all" button to restore full datasets, and synchronizes all views (tables, lists, kanban boards) seamlessly.

---

## 1. Search Execution Strategy (Client-Side vs. API Query)

Applications must determine how to execute search based on how records are fetched:

### A. All-at-Once / Bulk Data Fetch (Default for Most Entity Pages)
When a page loads records in bulk via `findSWR` (without pagination parameters `limit`/`skip`):
- **Search MUST execute client-side synchronously in JavaScript.**
- Do NOT perform an unnecessary backend API round-trip on every keystroke when the complete dataset is already in memory.
- Filter the in-memory array across all relevant text attributes using case-insensitive substring matching (`.toLowerCase().includes(term)`):
  ```javascript
  function getFilteredItems() {
    const term = (document.getElementById('searchInput')?.value || '').trim().toLowerCase();
    return allItems.filter(item => {
      // 1. Text Search Filter across primary fields
      const matchesSearch = !term || (
        (item.name || '').toLowerCase().includes(term) ||
        (item.code || '').toLowerCase().includes(term) ||
        (item.company || '').toLowerCase().includes(term) ||
        (item.email || '').toLowerCase().includes(term) ||
        (item.status || '').toLowerCase().includes(term)
      );

      // 2. Status / Category / Pill Filter
      const matchesStatus = currentStatusFilter === 'ALL' || item.status === currentStatusFilter;

      return matchesSearch && matchesStatus && item.isDeleted !== true;
    });
  }
  ```

### B. Paginated Data Fetch (When Server Pagination `limit`/`skip` is Active)
When a page relies on server-side pagination:
- Search **MUST query the backend API** with debounced execution (e.g. 300ms debounce).
- Construct a backend `where` filter with `or` conditions across searchable fields (or regex).
- Reset pagination offset to `skip: 0` so the user views the first page of matching results.
- Update the paginated dataset and total matching count via `countSWR`.

---

## 2. Active Filter Tags Bar (`#activeFilterTagsBar`)

Whenever any search query is non-empty OR any filter (status pill, dropdown, category) is set to a non-default value (e.g., anything other than "ALL"), the UI **MUST** display an active tags bar directly above the data view.

### Standard HTML Structure
Place this container directly below the search and filter controls:
```html
<div id="activeFilterTagsBar" class="hidden flex flex-wrap items-center gap-2 pt-2 border-t border-primary-border/40 text-xs">
  <span class="text-secondary-text font-medium text-[11px] uppercase tracking-wider">Active:</span>
  <div id="activeFilterTags" class="flex flex-wrap items-center gap-1.5"></div>
  <button type="button" id="btnClearAllFilters" onclick="window.clearAllFilters()" class="ml-auto text-xs text-primary hover:underline font-semibold cursor-pointer inline-flex items-center gap-1">
    <i class="fas fa-times-circle text-[11px]"></i><span>Clear all</span>
  </button>
</div>
```

### Security & HTML Escaping
All dynamic values rendered into tags **MUST** be HTML-escaped to prevent XSS:
```javascript
function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}
```

### Dynamic Tag Generation
Render styled badges with clear button triggers:
```javascript
function updateActiveFilterTags() {
  const bar = document.getElementById('activeFilterTagsBar');
  const tagsContainer = document.getElementById('activeFilterTags');
  if (!bar || !tagsContainer) return;

  const tags = [];
  const searchVal = (document.getElementById('searchInput')?.value || '').trim();

  if (searchVal) {
    tags.push(`
      <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs bg-primary/10 text-primary border border-primary/20">
        <span>Search: "<strong>${escapeHtml(searchVal)}</strong>"</span>
        <button type="button" onclick="window.clearSearchFilter()" class="hover:opacity-75 focus:outline-none cursor-pointer" title="Remove search">
          <i class="fas fa-times text-[10px]"></i>
        </button>
      </span>
    `);
  }

  if (currentStatusFilter && currentStatusFilter !== 'ALL') {
    tags.push(`
      <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs bg-primary/10 text-primary border border-primary/20">
        <span>Status: <strong>${escapeHtml(currentStatusFilter)}</strong></span>
        <button type="button" onclick="window.clearStatusFilter()" class="hover:opacity-75 focus:outline-none cursor-pointer" title="Remove filter">
          <i class="fas fa-times text-[10px]"></i>
        </button>
      </span>
    `);
  }

  tagsContainer.innerHTML = tags.join('');
  if (tags.length > 0) {
    bar.classList.remove('hidden');
  } else {
    bar.classList.add('hidden');
  }
}
```

---

## 3. Tag Dismissal & "Clear all" Functionality

### Individual Tag Dismissal
- Clicking the `✕` on a search tag clears the search input and immediately re-filters.
- Clicking the `✕` on a filter tag resets that specific filter (e.g. resets status pill to "ALL") and immediately re-filters.
```javascript
window.clearSearchFilter = function() {
  const searchInput = document.getElementById('searchInput');
  if (searchInput) searchInput.value = '';
  applyFilters();
};

window.clearStatusFilter = function() {
  currentStatusFilter = 'ALL';
  updateStatusPillUI();
  applyFilters();
};
```

### One-Click "Clear all"
Clicking "Clear all" (`window.clearAllFilters()`):
1. Clears all search inputs (`value = ''`).
2. Resets all filter dropdowns/pills to their default ("ALL") state.
3. Hides the `#activeFilterTagsBar`.
4. Immediately re-filters and displays the original complete dataset without a page reload.
```javascript
window.clearAllFilters = function() {
  const searchInput = document.getElementById('searchInput');
  if (searchInput) searchInput.value = '';
  currentStatusFilter = 'ALL';
  updateStatusPillUI();
  applyFilters();
};
```

---

## 4. Multi-View & Counter Synchronization

When filters or search are applied or cleared, `applyFilters()` **MUST synchronously update**:
1. **The Active Filter Tags Bar** via `updateActiveFilterTags()`.
2. **All Active Views**:
   - The table/list view (`renderTable(filteredItems)`).
   - Any active Kanban board (`renderKanban(filteredItems)`).
3. **Item Count Badges**:
   - Update header/footer counters (e.g., `Showing X of Y items` or `X Total`).
4. **Empty State Feedback**:
   - If filtered results are empty, display a clean empty state:
     `"No items matching your search or filters. Click [Clear all] to view all records."`

---

## 5. Mandatory Interactive Table Column Sorting (`th[data-sort]`) (`TABLE_NOT_SORTABLE`)

Every data table (`<table>` with a `<thead>`) **MUST** support interactive column sorting:
1. **Sortable Column Headers:** Declare `data-sort="<field-key>"` and `style="cursor:pointer;user-select:none"` on all data `<th>` elements inside `<thead>` (excluding checkbox and action columns), along with a `<span class="sort-indicator" aria-hidden="true">↕</span>` indicator.
2. **Delegated Click-to-Sort Handler:** Clicking a `th[data-sort]` header must toggle `data-dir="asc"` / `"desc"`, update the sort indicator (`↑` / `↓`), and sort the `<tbody>` rows (or re-render the sorted dataset) using numeric-aware comparison (`localeCompare(..., { numeric: true, sensitivity: 'base' })` and numeric currency/percentage parsing).
