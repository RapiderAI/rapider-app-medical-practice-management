# Guide: Defining UI Page Definitions

This guide outlines the rules for defining the user interface pages in the `pages` array of the `app.manifest.json`.

As an AI agent, you will analyze the application metadata (App description, cover page, database models, fields, relations, and AI agent configurations) to automatically design the necessary user interface pages.

For each required page, you must generate a comprehensive, Markdown-formatted development specification (`developmentDetails`) that human developers or downstream AI agents will use to perfectly build the UI, implement data fetching, and construct actions. Additionally, you will generate a Markdown summary of these pages (`additionalCoverPage`) that will be appended to the app's existing Scope of Work.

## Analysis Guidelines

1. **App Metadata & SOW:** Read the `coverPage` and `description` to understand the overarching purpose of the application. Design a "Dashboard" or "Home" page that reflects this core purpose.
2. **Models & Relations:** 
   * For every model (e.g., Epic, Sprint, Issue), determine if it requires a List/Data-Grid view, a Kanban/Board view, and a Detail/Form view.
   * Analyze `relations`. If a model `hasMany` of another (e.g., Sprint hasMany Issues), ensure the parent's Detail page includes a sub-view (table or list) of the child records.
3. **Fields & Scopes:** Use the `fields` array to determine which columns to show in tables and which inputs are required in forms. Respect `isHidden` (do not display), `isRequired` (enforce validation), and `scope` (default sorting/filtering).
4. **AI Agent Config:** Look at `availableOperations` (`create`, `read`, `update`, `delete`). If a model cannot be deleted, do not design a delete button. Respect `restrictedStates` and `immutableFields` when defining the form logic and UI state rules.

## Generation Rules

* **Page Types:** Always set `type` to `"AppPage"`.
* **Routing:** Generate RESTful, URL-friendly routes in the `route` field (e.g., `dashboard`, `sprints`, `epics/:id`).
* **Sidebar Menu Section Grouping (Minimum 3 Items Rule - STRICT):** When assigning section headers (`title` or `group`) to menu items, each title MUST group **at least 3 menu items** (`count >= 3`). Never create 1-item or 2-item isolated section titles (e.g. creating separate titles for `DASHBOARD -> Dashboard`, `PROJECTS -> Projects`, `ISSUES -> Issues`). If there are fewer than 3 items in a category, consolidate them under a broad main title (e.g. `"Overview"` or `"Workspace"`) or leave them without a section title (`""`) to keep the sidebar tidy.
* **Additional Cover Page (Markdown):** Generate an `additionalCoverPage` string at the root level of your manifest update. This must be a Markdown-formatted summary of all the UI pages you just designed, explaining their purpose, key features, and user flow. Since this will be concatenated to the end of the user's existing `coverPage` SOW, start with a logical heading like `## Application Structure & Pages` and do not repeat the general app introduction.
* **Development Details (Markdown):** The `developmentDetails` field MUST be a detailed Markdown string containing:
  * **Page Layout & Layout Components:** (e.g., Sidebar, Header, Two-column grid). *Note: These UI pages will be displayed inside a SaaS wrapper application. Do not add main application headers or footers, but you can add page-specific headers and toolbars if necessary.*
  * **Data Dependencies:** What data needs to be fetched (e.g., "Fetch Sprint where id = URL parameter, include Issues relation").
  * **UI Components Needed:** (e.g., DataTable for lists, Formik/React Hook Form for inputs, Kanban board).
  * **Actions & Modals:** Define buttons (Create, Edit, Delete) and their behaviors (e.g., "Clicking 'New Issue' opens a sliding drawer with a form containing...").
  * **Business Logic & Validation:** Explicitly mention constraints like "Warn user if changing dates of Active sprint" or "endDate MUST be after startDate".

## Example Page Definition Structure

Below is an example of what your updates to the manifest should look like:

```json
{
  "additionalCoverPage": "## Application Structure & Pages\n\nHere is an overview of the user interface designed for this application:\n\n### Dashboard\nMain analytics and overview for tracking project health...\n\n### Sprints\n...",
  "pages": [
    {
      "name": "Dashboard",
      "description": "Main analytics and overview page...",
      "type": "AppPage",
      "route": "dashboard",
      "developmentDetails": "# Dashboard\n\n## Layout\nSingle-column full-width layout with a top toolbar.\n\n## Data Dependencies\n- Fetch active Projects.\n\n## UI Components Needed\n- KPI Cards for Total Projects, Active Tasks.\n- Chart for Task completion progress.\n\n## Actions & Modals\n- Clicking a project navigates to `projects/:id`."
    },
    {
      "name": "Project List",
      "description": "Grid view of all projects.",
      "type": "AppPage",
      "route": "projects",
      "developmentDetails": "# Project List\n\n## Layout\n..."
    }
  ]
}
```
