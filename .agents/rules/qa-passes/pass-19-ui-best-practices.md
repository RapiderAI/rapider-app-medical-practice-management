# Pass 19: UI, Refresh, and ID Standards
**Goal:** Ensure tables are responsive, caches are properly invalidated, form editing states are clean, submissions are protected, and backend ID fields are handled correctly.

## 1. Table Width and Responsiveness
Data tables must ALWAYS be wrapped in a specific `div` structure to prevent breaking the layout on smaller screens. 
**✅ CORRECT STRUCTURE:**
```html
<div class="overflow-x-auto w-full">
  <table class="min-w-full text-left text-sm border-collapse whitespace-nowrap">
    <!-- Table content -->
  </table>
</div>
```
- The wrapper `div` MUST have `overflow-x-auto w-full`.
- The `table` MUST have `min-w-full text-left text-sm border-collapse whitespace-nowrap`.

## 2. Auto-Refresh After CRUD Operations (Cache Invalidation)
To fix auto-refresh issues after creating, updating, or deleting data in tables:
- You must clear BOTH `swr_find_` AND `swr_count_` keys in `sessionStorage` BEFORE calling the load function.
- If you only clear `swr_find_EntityName`, related queries (like counts for pagination) will remain stale.

**✅ CORRECT REFRESH LOGIC:**
```javascript
// Clear SWR Cache before reloading
Object.keys(sessionStorage).forEach(k => {
  if (k.startsWith('swr_find_') || k.startsWith('swr_count_')) {
    sessionStorage.removeItem(k);
  }
});
await loadData();
```

## 3. Form Editing State
When a user clicks "Edit" to populate a form with existing data:
- **NEVER** use `form.reset()` on edit forms, as it will clear the data you just populated.
- Only use `form.reset()` when explicitly clearing a form (e.g. clicking "Cancel" or opening a "New Item" form).

## 4. Double-Submission Protection
All form submit buttons and destructive action buttons MUST have double-submission protection to prevent rapid successive clicks.
- Check if the button is disabled at the start of the handler.
- Disable the button immediately.
- Re-enable the button in a `finally` block.

**✅ CORRECT SUBMISSION LOGIC:**
```javascript
async function handleSubmit(btn) {
  if (btn.disabled) return;
  btn.disabled = true;
  const originalText = btn.innerHTML;
  btn.innerHTML = '<span class="loading loading-spinner loading-sm"></span>';
  try {
    // API call logic...
  } catch (error) {
    console.error(error);
  } finally {
    btn.disabled = false;
    btn.innerHTML = originalText;
  }
}
```

## 5. Backend ID Handling (`id` vs `_id`)
Ensure that any entity ID references in the UI properly expect and use `id` (not `_id`). The backend dynamically maps MongoDB `_id` fields to `id` via `sanitizeDataForRead`.
- When rendering lists or accessing objects, use `item.id`.
- Do not attempt to rely on `item._id`.

## 6. Zero Native JS Dialogs (`alert`, `confirm`, `prompt`)
Agents and QA reviewers MUST check every page for any use of pure JavaScript dialogs:
- **Scan Query:** Grep `alert(`, `confirm(`, and `prompt(` across all files in `pages/`.
- **Conversion Mandate:**
  - If a page uses `confirm(...)` (e.g. for delete or critical status change), convert it to a styled confirmation modal (`showConfirmModal` or custom Tailwind confirmation modal / popconfirm).
  - If a page uses `alert(...)`, convert it to `window.rapiderApi.showNotification({ type, message })`.
  - Never allow blocking browser dialogs in any production page.

## 7. International Phone Number Input Standard
Agents and QA reviewers MUST check all phone number input fields across the application:
- **Scan Query:** Search for `type="tel"`, `[id*="phone"]`, `[id*="Phone"]`, or phone masks in `pages/`.
- **Verification Criteria:**
  - No phone field should use a static, hardcoded single-country mask (e.g. `+{1} (000) 000-0000`).
  - Must use `<rapider-phone-input>` or `RapiderPhoneInput.attach(el)`.
  - Must provide country selection with flags and dial codes.
  - Must include a `Custom` option (`🌐 Custom`) allowing freeform input for unformatted numbers or extensions without a mask.

## 8. Collapsed Sidebar CSS Standard, Suite Brand & Ban on JS Inline Display
- In CSS, collapsed sidebar labels MUST be hidden with `display: none !important;`:
  ```css
  aside.collapsed .sidebar-label,
  aside[data-collapsed="true"] .sidebar-label,
  .sidebar-collapsed .sidebar-label,
  .sidebar-collapsed .suite-title,
  .sidebar-collapsed .sidebar-collapse-btn {
    display: none !important;
  }
  ```
- **STRICT BAN** on setting `el.style.display = 'block'` or `el.style.display = 'none'` directly on navigation items or labels in JavaScript. Always toggle container state classes (e.g. `aside.classList.toggle('sidebar-collapsed')`) instead.
- **Suite Brand & Collapsible Mechanics (See Pass 21):**
  - Brand header must display the authentic Suite Icon and Suite Name (never fake Rapider text or placeholder logo).
  - Collapse button (`.sidebar-collapse-btn`) collapses sidebar to ~68px width.
  - Hovering over collapsed sidebar/icons transforms the top Suite icon into a right caret expand icon (`<i class="suite-expand-icon fas fa-chevron-right"></i>`).
  - Collapsed state must persist via `localStorage.getItem('rapider_sidebar_collapsed')`.

## 9. Primary & Danger Button Text Contrast Invariant
- Any button with `bg-primary`, `btn-primary`, `bg-danger`, `btn-danger`, or saturated dark backgrounds MUST enforce white text:
  `style="color: #ffffff !important;"` alongside `!text-white text-white`.
- **STRICT BAN** on using `text-white` on light or neutral backgrounds like `bg-button-bg` or `bg-alt-background`.

## 10. Table Row Click Event Delegation Safety
- When binding click handlers to table rows (`<tr>`) for navigation, always guard against event bubbling from child buttons, anchors, inputs, selects, or elements with `data-action`:
  ```javascript
  tableBody.addEventListener('click', (e) => {
    if (e.target.closest('button, a, input, select, textarea, [data-action], .no-row-click')) {
      return;
    }
    const tr = e.target.closest('tr[data-id]');
    if (tr) {
      window.rapiderApi.navigate(`/detail?id=${tr.dataset.id}`);
    }
  });
  ```

## 11. CSS Structural Integrity (Balanced Braces)
- All `<style>` blocks must have perfectly balanced `{` and `}` braces. Unbalanced CSS syntax silently breaks subsequent stylesheet rules in the page.

## 12. Active Project Scope Listener
- For multi-project applications, pages must listen to the `rapider:project-changed` window event and dynamically reload active records scoped to `e.detail.projectId`.

## 13. Scoped `.field input` CSS for Checkboxes and Radios (`UNSCOPED_CHECKBOX_INPUT_CSS`)
- Never apply `display: block; width: 100%; min-height: 42px;` to an unscoped `.field input` selector, as it will stretch `<input type="checkbox">` and `<input type="radio">` inside `.field` labels into giant full-width blocks.
- Always scope text-input styles with `:not([type="checkbox"]):not([type="radio"])` and define explicit inline-block sizing for checkboxes and radios:
  ```css
  .field input:not([type="checkbox"]):not([type="radio"]),
  .field select,
  .field textarea {
    display: block;
    width: 100%;
    min-height: 42px;
  }
  .field input[type="checkbox"],
  .field input[type="radio"] {
    display: inline-block;
    width: 16px;
    height: 16px;
    min-height: 16px;
    margin: 0 8px 0 0;
    padding: 0;
    vertical-align: middle;
  }
  ```

## 14. Scoped Secondary Detail Queries & Immediate Post-Save Hydration
- When a detail page (e.g., `/profile?id=...`) queries secondary entities (`HrEmergencyContact`, `HrDocumentRef`, `HrLifecycleEvent`, `HrChangeRequest`), always scope the query by the parent foreign key (`{ where: { employeeId: String(state.employeeId) }, limit: 100 }`) rather than fetching an unscoped `{ limit: 200 }` batch that omits new rows once the shared table exceeds 200 records.
- Immediately prepend the record returned by `window.rapiderApi.create(...)` into local state before re-rendering so the UI reflects the saved record without delay.




