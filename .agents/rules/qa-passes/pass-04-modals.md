# Pass 4: Modals Usage
**Goal:** Verify and fix if modals and confirmation dialogs are used correctly.

## 1. Zero Native JS Dialogs (`confirm`, `alert`, `prompt`)
- **STRICT PROHIBITION:** Never use pure JavaScript `confirm()`, `alert()`, or `prompt()` in any page.
- **Audit Requirement:** Check every Delete button, Status transition button, and destructive action across all pages.
- If any page uses native `confirm(...)`, immediately convert it to a suitable confirmation modal (`showConfirmModal` or a styled Tailwind popconfirm/modal).
- If any page uses native `alert(...)`, immediately convert it to `window.rapiderApi.showNotification({ type, message })`.

## 2. Confirmation Modals
- Confirmation modals must clearly specify the item or entity name being deleted.
- Destructive actions must provide a clear "Cancel" button and a red/danger-styled "Delete" or "Confirm" button.
- The confirm callback must be asynchronous, await the delete/update operation, invalidate the SWR cache, show a notification toast, and re-fetch the list.

**✅ BEST PRACTICE (Confirmation Modal):**
```javascript
// Good: Confirmation modal for delete
showConfirmModal({
  title: 'Delete Lead',
  message: `Are you sure you want to delete "${leadName}"? This action cannot be undone.`,
  okText: 'Delete Lead',
  isDanger: true,
  onConfirm: async () => {
    try {
      await window.rapiderApi.deleteById('CrmLead', leadId);
      if (window.rapiderApi.clearCache) window.rapiderApi.clearCache('CrmLead');
      window.rapiderApi.showNotification({
        type: 'success',
        message: 'Lead deleted successfully'
      });
      await loadLeads();
    } catch (err) {
      window.rapiderApi.showNotification({
        type: 'error',
        message: 'Failed to delete lead: ' + (err.message || err)
      });
    }
  }
});
```

## 3. Form Modal Best Practices
- Ensure modals are triggered cleanly, and all close buttons inside the modal work.
- Reset form fields when a modal is closed so stale data doesn't appear on next open.
- Focus should be trapped inside the modal for accessibility.

## 4. Universal Backdrop Click & ESC Key Dismissals (STRICT)
- Modals and drawers must NEVER trap the user without standard dismissal mechanisms:
  1. **Backdrop Click Dismissal:** Clicking on the backdrop overlay outside the modal card MUST close the modal.
     ```javascript
     modalEl.addEventListener('click', (e) => {
       if (e.target === modalEl) closeModal();
     });
     ```
  2. **Escape Key Dismissal:** Pressing the `Escape` key MUST close any open modal or drawer:
     ```javascript
     document.addEventListener('keydown', (e) => {
       if (e.key === 'Escape') closeAllOpenModals();
     });
     ```
  3. **Form Reset on Dismiss:** Always clear validation errors and call `form.reset()` (or reset data state) when closing an add/create modal.

## 5. Table Row Click Delegation Safety (STRICT)
- When binding row click listeners on `<tr>` elements to navigate to a detail view, **NEVER** allow the row navigation handler to hijack child interactive elements (buttons, links, form inputs, checkboxes, status dropdowns).
- **Mandatory Guard:**
  ```javascript
  tableBody.addEventListener('click', (e) => {
    // IGNORE clicks on buttons, links, inputs, or explicit no-row-click elements
    if (e.target.closest('button, a, input, select, textarea, [data-action], .no-row-click')) {
      return;
    }
    const tr = e.target.closest('tr[data-id]');
    if (tr) {
      const recordId = tr.dataset.id;
      window.rapiderApi.navigate(`/detail?id=${recordId}`);
    }
  });
  ```

**✅ BEST PRACTICE (Form Modals):**
```javascript
// Good: Open modal and reset fields
document.getElementById('btn-add').addEventListener('click', () => {
    document.getElementById('new-lead-form').reset();
    document.getElementById('lead-modal').classList.add('is-active');
});

// Good: Close modal
document.querySelectorAll('.close-modal').forEach(btn => {
    btn.addEventListener('click', () => {
        document.getElementById('lead-modal').classList.remove('is-active');
    });
});
```

## 6. Native `<dialog>` Viewport Centering Under Tailwind v4 Preflight (`DIALOG_NOT_CENTERED`)
- Tailwind v4's preflight reset (`* { margin: 0; padding: 0; }`) overrides the browser user-agent stylesheet (`dialog { margin: auto; }`), which causes `<dialog>` modals to be pinned to the top-left corner (`left: 0; top: 0`) instead of centered in the viewport.
- **STRICT REQUIREMENT:** Every page that styles `<dialog>` MUST explicitly include `margin: auto;` inside its `dialog { ... }` CSS rule:
  ```css
  dialog {
    margin: auto;
    border: 1px solid var(--line);
    border-radius: 16px;
    padding: 0;
    width: min(540px, calc(100vw - 28px));
  }
  ```


