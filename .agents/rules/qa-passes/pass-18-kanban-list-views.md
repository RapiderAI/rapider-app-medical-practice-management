# QA Pass 18: Kanban & List View Toggles

## Objective
Ensure that any page containing a Kanban board (`<rapider-kanban>`) also provides a toggle to a "List View" (table format) so users can perform detailed actions (edit, delete, view full details) that might be difficult on a Kanban card.

## Verification Steps
1. Identify if the page uses a `<rapider-kanban>` component.
2. If it does, verify there is a UI toggle (e.g., buttons for "Board" and "List").
3. Verify that the "List" view renders a proper HTML table (`<table>` inside an `overflow-x-auto` wrapper, with `border-collapse`, NOT `display: block`).
4. Ensure the list view displays all relevant fields and includes an "Actions" column (with View/Edit/Delete buttons as appropriate).
5. Ensure the toggle logic correctly hides/shows the kanban container and the list container.

## Remediation
- If a kanban page lacks a list view, implement a toggle UI above the kanban board.
- Wrap the kanban board in a container (e.g. `viewKanbanContainer`).
- Create a sibling container (e.g. `viewListContainer`) containing a standard HTML table for the data.
- Add Javascript logic to switch the visibility of these containers when the toggles are clicked.
- Populate the list view dynamically from the same data source used by the Kanban board.
