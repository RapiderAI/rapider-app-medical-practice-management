# Pass 9: API Payloads
**Goal:** Verify and fix the structure of API payload submissions.

- Ensure payloads match the exact field names defined in `app.manifest.json` (`dataModels.<EntityName>.fields`). LoopBack 4 strictly rejects undeclared properties with `HTTP 422 Unprocessable Entity`.
- Before writing any `window.rapiderApi.create(EntityName, payload)` or `window.rapiderApi.updateById(EntityName, id, payload)` call, inspect `app.manifest.json` `dataModels[EntityName].fields` and verify every key in `payload` is declared in that entity's schema.
- **Strict Payload Whitelisting:** Strip undeclared fields, computed/virtual properties, foreign relation objects (e.g. `lead.account`), and server-managed audit fields (`createdDate`, `updatedDate`) before submitting mutations.
- **Batch CSV Import Deduplication & SWR Invalidation:**
  - When importing records from CSV or bulk data feeds, deduplicate rows on canonical natural keys (e.g. `email` or `employeeId`).
  - Perform upserts or iterative creations cleanly.
  - Immediately following import, invalidate the SWR cache (`window.rapiderApi.clearCache(entityName)`) and reload live data to reflect imported entries.
- Convert string numbers to actual numbers if the schema requires `integer` or `float`, and convert boolean checkboxes to true booleans (`true`/`false`) when the schema requires `boolean` (e.g., `isVacant: true`).
- Trim strings before sending to the backend.
- **Active Project Scope Listener:** For workspace/project-scoped models, always associate the record with the active project ID received from the `rapider:project-changed` window event.

**✅ BEST PRACTICE:**
```javascript
const payload = {
    firstName: document.getElementById('first-name').value.trim(),
    estimatedValue: parseFloat(document.getElementById('value').value) || 0
};
```

- **Double Submit Prevention**: Forms must prevent double submissions by disabling the submit button immediately and explicitly ignoring subsequent submits:
```javascript
document.getElementById('createForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = document.getElementById('btnSubmit');
    if (btn.disabled) return; // REQUIRED: Prevent duplicate rapid clicks
    btn.disabled = true;
    // ...
});
```
- **JavaScript Syntax & Parse Integrity (`JS_SYNTAX_ERROR`)**:
  - Every inline `<script>` tag must parse cleanly (`new vm.Script(code)`).
  - Never declare duplicate top-level `const` or `let` identifiers (such as `const esc` or `const _swrRes_1`) in the same script scope. Expose shared helpers safely via `window.esc = esc` inside an IIFE.
  - When injecting helper scripts before `</body>`, always locate `html.lastIndexOf('</body>')` so scripts are never accidentally inserted inside a JavaScript template string (e.g., a Word/HTML export blob template).
- **Schema Field & Scalar Type Matching (`INVALID_SCHEMA_PAYLOAD_FIELD`, `SCHEMA_FIELD_TYPE_MISMATCH`)**:
  - `app.manifest.json` `dataModels` may be an Array of `{ name, fields: [{ name, type, isRequired }] }` or an Object. Every property in a `create` / `updateById` payload must match an existing field name and its exact scalar type (`string`, `number`, `boolean`).
  - Never send a `number` (such as `priority: 1` or `stepTarget: 8000`) to a field declared as `"type": "string"` in `app.manifest.json` (send `'1'` or `String(val)` instead).
  - Never send `null` (`|| null`) for optional string or foreign-key fields (`headId`, `departmentId`, `locationId`, `epicId`, `sprintId`, `endsAt`); use `|| undefined` or strip `null` keys before calling the SDK so LoopBack 4 does not reject the payload with `HTTP 400 Bad Request`.
- **Guard Document-Level Submit Fallbacks (`UNGUARDED_QA_BRIDGE_SUBMIT`)**:
  - Any document-level `submit` listener (such as `#rapider-qa-bridge`) MUST start with `if (e.defaultPrevented) return;` so it never triggers a duplicate unmapped `window.rapiderApi.create` call after the page's own form submit handler has already handled the event.

