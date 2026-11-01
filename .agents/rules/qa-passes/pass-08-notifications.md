# Pass 8: Notifications
**Goal:** Verify toasts and notifications are shown on success/failure actions and that pure JS `alert()` is never used.

- **Zero Native `alert()`:** Check all pages to verify that `alert(...)` is NEVER used. If any page uses native `alert()`, convert it to `window.rapiderApi.showNotification`.
- Always show a success toast when a record is created, updated, or deleted.
- Always catch errors and show an error toast if an API call fails.

**✅ BEST PRACTICE:**
```javascript
try {
    await window.rapiderApi.create('CrmLead', data);
    window.rapiderApi.showNotification({
        type: 'success',
        message: 'Lead created successfully'
    });
} catch (error) {
    window.rapiderApi.showNotification({
        type: 'error',
        message: 'Failed to create lead: ' + (error.message || error)
    });
}
```

