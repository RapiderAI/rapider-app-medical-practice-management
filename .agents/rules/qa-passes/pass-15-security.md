# Pass 15: Security & Secrets
**Goal:** Ensure no hardcoded tokens/IDs exist.

- Never hardcode UUIDs, API keys, or user IDs.
- Derive project IDs dynamically (e.g. `localStorage.getItem('activeProjectId')`).

**❌ BAD PRACTICE:**
```javascript
// DANGEROUS: Hardcoded UUID
const projectId = '77aa8ea8-d441-4090-8f31-3351cf697a24';
```
