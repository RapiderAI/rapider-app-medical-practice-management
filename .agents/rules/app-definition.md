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

