# Pass 3: Data Model & Schema Compatibility
**Goal:** Verify that the UI requirements perfectly match the `app.manifest.json` schemas, including fields and relationships.

- Check `app.manifest.json` for the exact model schemas (e.g., `CrmAccount`, `CrmLead`).
- **Canonical Model Name Discovery (STRICT):** Always inspect `app.manifest.json` `dataModels` keys first before writing any SDK query or mutation. Use the exact case-sensitive canonical entity name. **NEVER** guess or invent generic model names (e.g. calling `window.rapiderApi.findSWR('Issue')` or `'Task'` when the manifest declares `ApmIssue` or `ApmTask`). SDK methods fail with 404 or create isolated unindexed collections when given invented model names.
- **Missing Fields:** If the HTML page assumes a field exists (e.g., `lead.estimatedValue`), verify it exists in the manifest schema. If it doesn't, either add it to the manifest or remove it from the UI.
- **Relationships:** If the UI attempts to show a related object (e.g., `opportunity.account.name`), verify that a proper relation schema exists in the manifest mapping `Opportunity -> Account`.
- Handle undefined or null fields gracefully in JS and HTML (use optional chaining `?.` or default values `|| 'N/A'`).
- **Implicit System Fields:** The backend automatically injects auditing/system fields into every record. These include: `id`, `createdDate`, `createdBy`, `createdById`, `updatedDate`, `updatedBy`, `updatedById`, `deletedDate`, `deletedBy`, `deletedById`, and `isDeleted`. You **MUST NOT** add these fields to the manifest schema definitions. If the UI relies on them, assume they exist implicitly.
- **Strict Create/Update Schema Field Enforcement (`INVALID_SCHEMA_PAYLOAD_FIELD`):** Every property passed inside `window.rapiderApi.create(entityName, payload)` or `window.rapiderApi.updateById(entityName, id, payload)` MUST exist in `app.manifest.json` under `dataModels[entityName].fields` (or be a valid implicit field like `isDeleted`). Passing invented/alias field names (e.g., `title` instead of `displayName` on `HrDocumentRef`, `fullName` instead of `name` on `HrEmergencyContact`, `leaderEmployeeId` instead of `headId` on `HrDepartment`, `workEmail`/`fullName` on `HrEmployee`, `currency` instead of `baseCurrency` on `FinLegalEntity`) causes LoopBack 4 `HTTP 422 Unprocessable Entity` failures and is strictly audited by `deterministic-page-auditor.js`.
- **Active Project Scope & Multi-Project Isolation:** In multi-project or workspace-scoped applications (e.g. Agile Project Management, Issue Trackers), pages must dynamically bind to the current workspace/project ID. Listen to the `rapider:project-changed` custom window event:
  ```javascript
  window.addEventListener('rapider:project-changed', (e) => {
    state.currentProjectId = e.detail.projectId;
    loadPageData();
  });
  ```
  Never hardcode static project IDs.
- **Resilient Field Reading & Foreign Key Fallbacks:** When reading records or pre-selecting `<select>` dropdowns on edit pages (`edit-employee.html`), always resolve foreign keys (`departmentId`, `locationId`, `legalEntityId`, `managerId`) by ID first, with a fallback to matching by name or selecting the default valid option so dropdowns never appear blank on existing records.
**✅ BEST PRACTICE (UI Side):**
```javascript
// Good: Safe access with fallbacks for nested relationships
element.innerText = lead?.contactInfo?.email || 'No email provided';
```

**✅ BEST PRACTICE (Manifest Side):**
```json
// Good: Proper relation mapped in the manifest
"relations": [
    {
        "type": "belongsTo",
        "targetEntity": "CrmAccount",
        "foreignKey": "accountId"
    }
]
```

**❌ BAD PRACTICE:**
```javascript
// Bad: Assumes nested data exists without checking if the relation is loaded or defined
element.innerText = opportunity.account.name;
```

---

## Sample Data Convention (`sample-data.json`)
Every app must supply rich, realistic `sample-data.json` covering all defined `dataModels`.
- **Mandatory Zeroed-Out Initial 8-Character Block (`00000000-xxxx-xxxx-xxxx-xxxxxxxxxxxx`):**
  All sample record IDs (`id` and `_id`) MUST zero out their initial 8 characters:
  e.g., `00000000-74c6-417b-b141-468b9dbf3d5e` or `00000000-1111-4111-8111-111111111111`.
- **Foreign Keys:** Any foreign keys referencing sample records (e.g. `accountId`, `ledgerId`) must link to the corresponding `00000000-...` ID.
- **Regex Purge Safety:** This guarantees backend cleanups and migration scripts can delete sample records via regex (`/^00000000-/`) without touching user-created data.
