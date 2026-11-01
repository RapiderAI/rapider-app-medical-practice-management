# Pass 5: Drawers Usage
**Goal:** Verify and fix if the drawers are used correctly.

- Drawers (side panels) should be used for detailed views or secondary navigation.
- Ensure clicking the backdrop or pressing `Escape` closes the drawer.
- The UI should not jank when the drawer slides in (use CSS transforms).
- **Edit Data Preservation**: When opening a drawer to EDIT a record, DO NOT reset the form (`form.reset()`) after populating the inputs with the record's data. Resetting the form will wipe the populated data and any hidden ID fields, resulting in empty submits and routing failures.

**✅ BEST PRACTICE:**
```javascript
// Good: Close drawer on Escape key
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        closeDrawer();
    }
});
```
