# Pass 16: Accessibility (A11y)
**Goal:** Add ARIA tags, roles, and check color contrast.

- Images must have `alt` attributes.
- Custom dropdowns and modals must have `aria-expanded`, `aria-hidden`, and `role`.
- Form inputs must have associated `<label>` tags.

**✅ BEST PRACTICE:**
```html
<label for="lead-name">Lead Name</label>
<input type="text" id="lead-name" name="leadName" aria-required="true" />
```
