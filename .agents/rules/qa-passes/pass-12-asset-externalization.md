# Pass 12: Asset Externalization
**Goal:** Move inline styles/scripts to appropriate files.

- HTML files should primarily contain structure.
- Large CSS blocks should be moved to `index.css` or scoped CSS.
- Keep inline `style="..."` to an absolute minimum.

**✅ BEST PRACTICE:**
Move `<style>.my-class { ... }</style>` out of HTML and into external CSS.
