# Pass 7: Themes & Styling
**Goal:** Verify and fix hardcoded colors to use Rapider theme variables.

- Never hardcode `#hex` or `rgb()` colors for text or backgrounds.
- Always use CSS variables (e.g., `var(--color-primary)`, `var(--text-color)`) so Dark Mode works perfectly.
- **CRITICAL TEXT CONTRAST & BUTTON INVARIANT:**
  1. Primary buttons (`bg-primary`, `btn-primary`) and danger buttons (`bg-danger`, `bg-red-600`) MUST ALWAYS enforce pure white text:
     - Apply `!text-white text-white` classes.
     - Add inline style: `style="color: #ffffff !important;"` (or `text-[color:var(--color-primary-button-text-color)]`).
  2. **STRICT BAN ON WHITE TEXT ON LIGHT BACKGROUNDS:**
     - NEVER use `text-white` or `style="color: #fff;"` on neutral or light backgrounds like `bg-button-bg`, `bg-alt-background`, `bg-card`, `bg-slate-100`, or `bg-gray-100`. In light mode, `bg-button-bg` is light grey (`#f3f4f6`), making white text completely invisible!
     - Secondary/neutral buttons MUST use `text-secondary-button-text` or `text-slate-700 dark:text-slate-200`.
  3. **Strict Background & Text Pairing:**
     - Dark/saturated background (`bg-primary`, `bg-danger`, `bg-slate-900`) -> pure white text (`text-white` / `#ffffff !important`).
     - Light/neutral background (`bg-button-bg`, `bg-card`, `bg-body-background`) -> dark text in light mode, light text in dark mode (`text-primary-text` / `text-secondary-text`).
- **CSS BALANCED BRACES INVARIANT:**
  - All `<style>` tags must be structurally balanced. Every opening brace `{` must have a corresponding closing brace `}`. Truncated CSS blocks silently break all subsequent stylesheet rules on the page.

**✅ BEST PRACTICE:**
```css
/* Good: Uses theme variables */
.card {
    background-color: var(--background-secondary);
    color: var(--text-primary);
    border: 1px solid var(--border-color);
}
```

**❌ BAD PRACTICE:**
```css
/* Bad: Hardcoded colors break in dark mode */
.card {
    background-color: #ffffff;
    color: #333333;
    border: 1px solid #cccccc;
}
```
