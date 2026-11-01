# Guide: Defining Application Metadata

This guide outlines the structure and rules for defining the root-level metadata of the application in the `app.manifest.json`.

As an AI agent, when you are initializing or updating the core properties of the application, you must strictly adhere to the following schema constraints.

## System Rules & Guidelines

1. **`name`**: Provide a clear display name for the application.
2. **`key`**: A unique prefix key formatted strictly as an acronym + `_` + unique characters (e.g., `pm_a`). This prevents duplicate table names across the system. This key should be generated once during initialization and rarely changed.
3. **`type`**: Must be exactly `"App"`.
4. **`description`**: Write a 2 to 10 sentence summary explaining the purpose and scope of the application.
5. **`isPublic`**: Must be exactly `true`.
6. **`tags`**: Provide an array of highly relevant search tags formatted strictly in kebab-case (e.g., `project-management`, `agile`).
7. **`coverPage`**: A comprehensive, highly detailed Markdown-formatted cover page that introduces the application, outlines its value, and explains its core features to end users.
8. **`scopeOfWork`**: A detailed Scope of Work (SoW) document outlining the deliverables, core features, out-of-scope items, and technical requirements. This must be in Markdown format, where every epic and feature has its own title and section.
9. **`iconUrl`**: Provide an appropriate FontAwesome class string (e.g., `fas fa-rocket`) for the app's icon.
10. **`route`**: The base URL route for the application once installed. Use the app's key (e.g., `pm_a`).
11. **`rating`**: A floating-point number representing the app's rating out of 5 (e.g., `4.8`). For new applications, this should be `0.0`.
12. **`reviewCount`**: An integer indicating the number of reviews. For new applications, this should be `0`.
13. **`appSuite`**: Mandatory Suite configuration object containing `key` (suite acronym e.g. `"HR"`, `"FIN"`), `title` (official title e.g. `"Rapider HR & Talent Suite"`), `shortTitle` (clean UI title e.g. `"HR Suite"`), and `icon` (FontAwesome class e.g. `"fas fa-users"`).
14. **`status`**: Must be at least `"app-metadata-completed"` (or `"pages_implemented"` / `"qa_passed"` / `"completed"`). **STRICT REQUIREMENT**: When you start building the app pages, ensure the status in `app.manifest.json` is at least `"app-metadata-completed"`. NEVER leave the status as `"ui-implementation-plan-in-progress"` or `"data-models-in-progress"`; otherwise, the Rapider UI treats the application as an active App Builder wizard step and displays the wizard UI with `"<- Back to Builder"` instead of the completed application.

## Example Metadata Object

Below is a fully compliant sample metadata structure.

```json
{
  "name": "Project Management System",
  "key": "pm_a",
  "type": "App",
  "status": "app-metadata-completed",
  "description": "A comprehensive application designed to track projects, manage tasks, and streamline team collaboration.",
  "isPublic": true,
  "tags": [
    "project-management",
    "productivity",
    "agile"
  ],
  "appSuite": {
    "key": "APM",
    "title": "Rapider Project & Portfolio Suite",
    "shortTitle": "Projects Suite",
    "icon": "fas fa-layer-group"
  },
  "coverPage": "# Project Management System\n\nWelcome to your new central hub for team productivity. This application allows you to seamlessly manage your organizational projects, track granular tasks, and collaborate effectively.",
  "scopeOfWork": "# Scope of Work\n\n## 1. Project Objectives\nDeliver a scalable project management tool...\n\n### Epics\n...",
  "iconUrl": "fas fa-project-diagram",
  "route": "pm_a",
  "rating": 0.0,
  "reviewCount": 0
}
```
