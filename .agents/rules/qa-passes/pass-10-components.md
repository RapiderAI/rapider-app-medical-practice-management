# Pass 10: Rapider Components
**Goal:** Verify standard UI elements use established Rapider Web Components.

- Use standard Web Components from `rapider-components.js`:
  - `<rapider-chart>`: Charts and metrics visualizations.
  - `<rapider-select>`: Advanced multi-select and searchable dropdowns.
  - `<rapider-tooltip>`: Interactive tooltips.
  - `<rapider-list-grid>`: Complex data tables and grids.
  - `<rapider-kanban>`: Kanban boards with drag-and-drop.
  - `<rapider-phone-input>`: International phone input with country selector dropdown, flags, dynamic masking, and custom freeform option.
- Ensure icons use the established library (FontAwesome) consistently.

**✅ BEST PRACTICE:**
```html
<!-- International Phone Input -->
<rapider-phone-input id="customerPhone" default-country="US"></rapider-phone-input>
```
