# Rule: App Definition

The `app.manifest.json` file in the root of the repository is the **single source of truth** for the application's definition.

### Modifying the Application
- You do NOT need to interface directly with the backend database.
- Any changes to the application's global configuration must be made directly to `app.manifest.json`.
- The Rappider backend will automatically sync these changes via webhooks when you push to GitHub.

### Adding New Pages to the Definition
When creating a new view or page for the application, you must first register it in the `app.manifest.json`'s `pages` array:

```json
{
  "name": "Target Page Name",
  "description": "Short description of the page's purpose.",
  "type": "AppPage",
  "route": "unique-url-slug"
}
```

Do not attempt to create legacy `AppPage` JSON definition files. The backend will parse the `pages` array from the manifest directly.

### Registering Page Workflows in the Definition
When a UI action requires a workflow (i.e. cannot be fulfilled by one or multiple CRUD API calls), it must be registered as a draft under `workflows` in `app.manifest.json`:

```json
{
  "name": "uniqueWorkflowNameAsCamelCase",
  "title": "Human Readable Title",
  "type": "pageWorkflow",
  "status": "draft",
  "description": "Comprehensive description of what the workflow does.",
  "pageRoute": "target-page-route",
  "triggerAction": "btnTargetActionId",
  "input": {
    "type": "object",
    "properties": {
      "recordId": { "type": "string" }
    },
    "required": ["recordId"]
  },
  "output": {
    "type": "object",
    "properties": {
      "success": { "type": "boolean" },
      "fileUrl": { "type": "string" }
    },
    "required": ["success"]
  }
}
```

The `"type": "pageWorkflow"` identifier explicitly signals that this workflow is tied to and invoked by an in-app page action, separating it from standalone, freely-triggered user workflows.

### Strict Brand Neutrality in Manifests & Database Definitions
- **NEVER save non-Rapider third-party competitor/vendor brand or product names** (e.g., `Salesforce`, `HubSpot`, `LabWare Cloud`, `ServiceNow`, `Workday`, `Representative Benchmark (P1): ...`, `Top 6 Global Benchmarks Synthesized (P1–P6)`) into `app.manifest.json`, `AppIdea` definitions, or `App` definitions (`description`, `coverPage`, `scopeOfWork`, `appIdea.body`, `pages[].developmentDetails`, `dataModels[].description`).
- Research and competitive benchmark vendor names belong **exclusively** in local design/research markdown files (`rapider-apps-development/apps/sows/*.md`, `rapider-apps-development/apps/combined-features/*.md`, `rapider-apps-development/_design/**`).
- In `app.manifest.json` and database records, only `Rapider` may appear as a product/brand name; refer to industry benchmarks generically (e.g., *"Architected and benchmarked against leading global enterprise platforms in this category"*).


