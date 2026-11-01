# App Sample Data Rules & Zeroed-Out ID Standard

When generating a Rappider application or acting as the App Builder Harness, you must ensure that sample data is generated for the application if it is missing or incomplete.

## Requirements

1. **Check for existing sample data**: Before concluding an app generation task or QA pass, verify if a `sample-data.json` exists in the application root.
2. **Generate if missing**: If `sample-data.json` is missing or empty, you MUST generate it.
3. **Compatibility**: The sample data must exactly match the data models (`dataModels`) defined in the `app.manifest.json`.
4. **Structure**: 
   - The JSON must be an object where keys are the `name` (or `datatableName`) of the canonical data models.
   - The values must be arrays containing rich, realistic, domain-specific sample records.
   - Each record must include a valid `id` and `_id`.
   - The data must be realistic and reflect the purpose of the application.

5. **MANDATORY CONVENTION: Zeroed-Out Initial 8-Character Block for Sample IDs (`00000000-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)**:
   - **CRITICAL REQUIREMENT:** All sample data record IDs (`id` and `_id`) **MUST zero out the initial 8-character block** of the UUID.
   - **Format Example:** `00000000-74c6-417b-b141-468b9dbf3d5e` or `00000000-1111-4111-8111-111111111111` (strictly eight zeros, hyphen, followed by 4-4-4-12 hex characters).
   - **Foreign Key Consistency:** Any foreign key or reference field linking to another sample entity (e.g. `accountId`, `categoryId`, `ownerId`, `customerId`, `parentId`) **MUST** use the target sample record's matching `00000000-...` ID.
   - **Operational Purpose:** This convention allows backend jobs, migration scripts, and maintenance tasks to cleanly identify and delete all sample data using a regex filter (`/^00000000-/`) without risk of deleting real user-created or tenant data.

6. **MANDATORY LIVE SEEDER INTEGRATION (NO STATIC MOCK HTML)**:
   - Sample data in `sample-data.json` is meant to be **seeded into the database**, NOT pasted as static HTML mock rows in page templates.
   - Pages must support a 1-click "Seed Demo Records" action in their empty state to populate the Rapider project database via `window.rapiderApi.create(entityName, sampleRecord)`.
   - The CLI runner `scripts/seed-sample-data.js` must be available to programmatically seed all canonical entities into the active project database.

By enforcing this rule, the Rapider Workflow/App Builder harness guarantees that every app can be immediately previewed with real database data, while maintaining data hygiene and safe sample data purging.

