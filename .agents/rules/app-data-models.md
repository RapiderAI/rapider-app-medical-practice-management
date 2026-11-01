# Guide: Defining Data Model Templates

This guide outlines the structure and rules for defining complete Data Model Templates (including data models, fields, relationships, model scopes, and granular AI configurations) within the `app.manifest.json`.

As an AI agent, you must strictly follow these constraints when writing or modifying the `dataModels` array to ensure compatibility with our backend, UI generation systems, and template library marketplace.

## 1. System Rules & Guidelines

### Models

- **`name`**: Formatted strictly as `{domainKey.titleCase} + {Title.titleCase}` (e.g., `CrmAccount`, `CrmTask`, `CrmQuote`, `PmAProject`, `PmATask`).
- **`title`**: A human-readable display name for the UI (e.g., "Account", "Task", "Project").
- **`description`**: A detailed explanation of the model's purpose. Required.
- **`domainName`**: The UI group this model belongs to. e.g. "CRM" or "Project Management". This is used for organizing data models in the UI and must be consistent across all data models in the same domain.
- **`domainKey`**: **Must be strictly identical to the root app `key`**.
- **`datatableName`**: The physical database table name. Must be strictly identical to `name`, formatted as `{domainKey.titleCase} + {Title.titleCase}` (e.g., `CrmAccount`, `CrmTask`, `PmAProject`, `PmATask`).
- **`titleFieldTemplate`**: A Jinja-style template string for dynamic display titles (e.g., `{{ title }} - {{ status }}`).
- **`scope`**: Defines the default database-level scope for the model, mirroring LoopBack/MongoDB syntax. It contains:
  - `where`: An object representing the default filter (e.g., `{"isDeleted": {"neq": true}}`).
  - `order`: An array of strings defining default sorting (e.g., `["priority ASC", "title ASC"]`).
- **`aiAgentConfig`**: An object containing AI agent configuration. It is required but can be an empty object `{}`. If populated, it defines how AI agents perform CRUD operations on this model.

### AI Agent Configuration (`aiAgentConfig`)

This object allows you to customize the behavior of AI agents for specific operations. It can contain the following optional configurations:

- **`vectorSearchFields`**: Array of field names to run through an embedding model for semantic similarity searches (RAG).
- **`planning`**: Defines what operations the AI is allowed to perform (`availableOperations`: array of `create`, `update`, `read`, `delete`).
- **`entityItemCreate`**: Instructs the AI on how to create a record.
  - `requiredFields`: Array of field names the AI *must* successfully populate before considering the creation "COMPLETE".
  - `immutableFields`: Don't allow AI to create data for these fields (e.g., `createdAt`, `isDeleted`).
  - `requiredRelations`: Array of relation names where the create agent must also create the related entity.
  - `autoGenerateFields`: Fields the AI should confidently invent or summarize data for without asking the user.
  - `additionalPrompt`: A custom Markdown prompt enforcing specific AI behaviors.
  - `requireUserConfirmation`: Boolean. Forces the AI to explicitly ask the user for a definitive 'yes' before saving.
  - `customValidationPrompt`: String. Instructs the AI on cross-field validation rules it must enforce before saving.
- **`entityItemUpdate`**: Instructs the AI on updates.
  - `immutableFields`: Prevent the AI from accidentally updating sensitive fields post-creation.
  - `autoGenerateFields`: Fields the AI should confidently invent/update data for without asking the user.
  - `additionalPrompt`: Custom rules for how the AI should modify existing data.
  - `requireUserConfirmation`: Boolean. Forces a user confirmation before updating.
  - `customValidationPrompt`: String. Cross-field validation rules for updates.
  - `restrictedStates`: An array of objects defining rules that prevent updates. Each object requires a `description` (explaining the rule to the AI) and a `where` object (LoopBack-style filter, e.g., `{"status": "Completed"}`).
- **`entityRead`**: A unified agent config that instructs the AI on reading single records or listing multiple records.
  - `defaultPageSize`: Number indicating how many records to fetch per page.
  - `defaultContextLimit`: Limits how many records the AI will ingest into its own context window to prevent token overflow.
  - `hiddenFields`: Security feature. Fields the AI is forbidden from reading aloud or summarizing in chat.
  - `maskedFields`: The AI is instructed to partially mask these fields in the chat interface (e.g., `j***@company.com`).
  - `additionalPrompt`: Custom rules for how the AI should interpret, summarize, or present the read data.
- **`entityItemDelete`**: Instructs the AI on deletions.
  - `requireCaptchaConfirmation`: Boolean (defaults to `true`). Forces a secure confirmation step before executing the deletion.
  - `cascadingRelations`: Give the Delete Agent explicit permission to follow relation arrays and clean up orphaned data.
  - `restrictedStates`: An array of objects defining rules that prevent deletion. Each object requires a `description` and a `where` filter object.

## 2. The JSON Schema Blueprint

Your JSON output within the `app.manifest.json` `dataModels` array must validate against the following schema:

```json
{
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "name": { "type": "string", "description": "Model name formatted strictly as {domainKey.titleCase} + {Title.titleCase} (e.g., CrmAccount, CrmTask, PmAProject)." },
      "title": { "type": "string", "description": "Human-readable display name (e.g., Account, Task, Project)." },
      "description": { "type": "string", "description": "Detailed explanation of the model." },
      "domainName": { "type": "string", "description": "The UI group this model belongs to (e.g., CRM, Project Management)." },
      "domainKey": { "type": "string", "description": "MUST perfectly match the root key." },
      "datatableName": { "type": "string", "description": "The physical database table name. Must be strictly identical to name: {domainKey.titleCase} + {Title.titleCase} (e.g., CrmAccount, CrmTask, PmAProject)." },
      "titleFieldTemplate": { "type": "string", "description": "Jinja-style template string for display." },
      "scope": {
        "type": "object",
        "properties": {
          "where": { "type": "object", "description": "Filter conditions for the model scope." },
          "order": { "type": "array", "items": { "type": "string" }, "description": "Array of fields to order by default." }
        }
      },
      "aiAgentConfig": {
        "type": "object",
        "properties": {
          "vectorSearchFields": { "type": "array", "items": { "type": "string" } },
          "planning": {
            "type": "object",
            "properties": {
              "availableOperations": { "type": "array", "items": { "type": "string", "enum": ["create", "update", "read", "delete"] } }
            }
          },
          "entityItemCreate": {
            "type": "object",
            "properties": {
              "requiredFields": { "type": "array", "items": { "type": "string" } },
              "immutableFields": { "type": "array", "items": { "type": "string" } },
              "requiredRelations": { "type": "array", "items": { "type": "string" } },
              "autoGenerateFields": { "type": "array", "items": { "type": "string" } },
              "additionalPrompt": { "type": "string" },
              "requireUserConfirmation": { "type": "boolean" },
              "customValidationPrompt": { "type": "string" }
            }
          },
          "entityItemUpdate": {
            "type": "object",
            "properties": {
              "immutableFields": { "type": "array", "items": { "type": "string" } },
              "autoGenerateFields": { "type": "array", "items": { "type": "string" } },
              "additionalPrompt": { "type": "string" },
              "requireUserConfirmation": { "type": "boolean" },
              "customValidationPrompt": { "type": "string" },
              "restrictedStates": {
                "type": "array",
                "items": {
                  "type": "object",
                  "properties": {
                    "description": { "type": "string" },
                    "where": { "type": "object" }
                  },
                  "required": ["description", "where"]
                }
              }
            }
          },
          "entityRead": {
            "type": "object",
            "properties": {
              "defaultPageSize": { "type": "number" },
              "defaultContextLimit": { "type": "number" },
              "hiddenFields": { "type": "array", "items": { "type": "string" } },
              "maskedFields": { "type": "array", "items": { "type": "string" } },
              "additionalPrompt": { "type": "string" }
            }
          },
          "entityItemDelete": {
            "type": "object",
            "properties": {
              "requireCaptchaConfirmation": { "type": "boolean" },
              "cascadingRelations": { "type": "array", "items": { "type": "string" } },
              "restrictedStates": {
                "type": "array",
                "items": {
                  "type": "object",
                  "properties": {
                    "description": { "type": "string" },
                    "where": { "type": "object" }
                  },
                  "required": ["description", "where"]
                }
              }
            }
          }
        }
      },
      "fields": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "name": { "type": "string", "description": "The field name in camelCase." },
            "type": { "type": "string", "description": "The data type of the field." },
            "description": { "type": "string", "description": "A brief description of the field." },
            "isPrimaryKey": { "type": "boolean", "description": "Indicates if the field is a primary key." },
            "isRequired": { "type": "boolean", "description": "Indicates if the field is required." },
            "default": { "description": "The default value for the field." },
            "defaultFn": { "type": "string", "description": "The function to generate the default value for the field." },
            "isHidden": { "type": "boolean", "description": "Indicates if the field is hidden. Do not set Id fields as hidden." },
            "isArray": { "type": "boolean", "description": "Indicates if the field is an array." },
            "isSensitive": { "type": "boolean", "description": "Indicates if the field contains sensitive information." }
          },
          "required": ["name", "type", "description"]
        }
      },
      "relations": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "name": { "type": "string", "description": "The name of the relation. CamelCase format." },
            "type": { "type": "string", "enum": ["belongsTo", "hasMany", "hasOne", "referencesMany", "hasManyThrough"] },
            "sourceModel": { "type": "string", "description": "The source model of the relation." },
            "sourceField": { "type": "string", "description": "The source field of the relation." },
            "targetModel": { "type": "string", "description": "The target model of the relation." },
            "targetField": { "type": "string", "description": "The target field of the relation." },
            "throughModel": { "type": ["string", "null"], "description": "The through model of the relation, if applicable." },
            "description": { "type": "string", "description": "A brief description of the relation." }
          },
          "required": ["name", "type", "sourceModel", "sourceField", "targetModel", "targetField", "description"]
        }
      }
    },
    "required": ["name", "title", "description", "domainName", "domainKey", "datatableName", "fields", "aiAgentConfig"]
  }
}
```

## 3. Example Model

Below is a compliant sample model demonstrating the `scope` field for global query rules, and the `restrictedStates` array utilizing LoopBack syntax to block AI actions on specific records.

```json
{
  "name": "PmATask",
  "datatableName": "PmATask",
  "title": "Task",
  "description": "An actionable item belonging to a project.",
  "domainName": "Project Management",
  "domainKey": "pm_a",
  "titleFieldTemplate": "{{ title }} - {{ status }}",
  "scope": {
    "where": { "isDeleted": { "neq": true } },
    "order": ["status ASC", "title ASC"]
  },
  "aiAgentConfig": {
    "vectorSearchFields": ["title", "description"],
    "planning": {
      "availableOperations": ["create", "update", "read", "delete"]
    },
    "entityItemCreate": {
      "requiredFields": ["title", "projectId"],
      "immutableFields": ["isDeleted"],
      "autoGenerateFields": ["description", "status"],
      "requiredRelations": ["tags"],
      "requireUserConfirmation": true,
      "customValidationPrompt": "If the priority is 'High', a detailed description is strictly required.",
      "additionalPrompt": "## Task Creation Rules\n- Start titles with an action verb."
    },
    "entityItemUpdate": {
      "immutableFields": ["projectId"],
      "autoGenerateFields": ["description"],
      "requireUserConfirmation": true,
      "restrictedStates": [
        {
          "description": "Cannot modify tasks that are marked as Completed or Archived.",
          "where": { "status": { "inq": ["Completed", "Archived"] } }
        }
      ],
      "additionalPrompt": "Only update the status if the user explicitly confirms the work is fully reviewed."
    },
    "entityRead": {
      "defaultPageSize": 15,
      "defaultContextLimit": 20,
      "hiddenFields": ["internalNotes"],
      "maskedFields": ["reporterEmail"],
      "additionalPrompt": "When summarizing tasks, group them by 'status' and always highlight 'Blocked' tasks first."
    },
    "entityItemDelete": {
      "requireCaptchaConfirmation": true,
      "restrictedStates": [
        {
          "description": "Cannot delete tasks that have already been marked as Completed.",
          "where": { "status": "Completed" }
        }
      ]
    }
  },
  "fields": [
    {
      "name": "id",
      "type": "string",
      "description": "The unique identifier for the task.",
      "isPrimaryKey": true,
      "isRequired": true,
      "defaultFn": "uuidv4",
      "isHidden": false,
      "isArray": false
    },
    {
      "name": "title",
      "type": "string",
      "description": "The title of the task.",
      "isRequired": true,
      "isHidden": false,
      "isArray": false
    }
  ],
  "relations": [
    {
      "name": "project",
      "type": "belongsTo",
      "sourceModel": "PmATask",
      "sourceField": "projectId",
      "targetModel": "PmAProject",
      "targetField": "id",
      "throughModel": null,
      "description": "This task belongs to a specific parent project."
    }
  ]
}
```

---

## 3. Sample Data Generation Rules (`sample-data.json`)
Every application must be accompanied by a `sample-data.json` at the root of the application repository.
- **Data Model Coverage:** Must contain arrays for each entity model defined in `dataModels`.
- **Zeroed-Out Initial 8-Character Block Standard (`00000000-xxxx-xxxx-xxxx-xxxxxxxxxxxx`):**
  - **STRICT REQUIREMENT:** Every sample record's `id` and `_id` MUST zero out the initial 8-character block of the UUID:
    e.g. `00000000-74c6-417b-b141-468b9dbf3d5e` or `00000000-1111-4111-8111-111111111111`.
  - **Foreign Key Alignment:** All relations (e.g. `projectId`, `accountId`, `categoryId`) referencing sample data MUST link to the corresponding target's `00000000-...` UUID.
  - **Regex Purge Safety:** This convention enables administrative scripts to delete sample records via regex (`/^00000000-/`) without touching user-generated production data.
