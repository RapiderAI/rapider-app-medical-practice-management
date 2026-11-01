# Pass 6: Responsive Layouts
**Goal:** Verify and fix responsive classes and constraints (mobile vs desktop).

- Ensure pages look good on mobile and desktop.
- Avoid fixed widths (`width: 500px`), prefer percentages or flex/grid.
- **CRITICAL:** Ensure consistent layout alignment across the entire page. All main content wrappers (e.g., `.crm-shell`) MUST have a consistent maximum width constraint (e.g. `max-w-7xl mx-auto w-full`) so that upper sections and bottom sections don't have mismatched widths (e.g. one part restricted to 1200px while another spans 100% of an ultrawide monitor).
- Tables should scroll horizontally on small screens to prevent layout breakage by wrapping them in an `overflow-x-auto` `div`.
- **CRITICAL TABLE LAYOUT:** NEVER apply `block` or `overflow-x-auto` directly to the `<table>` tag itself, as this breaks native table layout algorithms and causes tables to squash horizontally. Only apply `overflow-x-auto` to a wrapper `<div>`, and ensure the table has `w-full` (and optionally `min-w-full`) so it expands correctly to 100% of the container.

## Canonical App Shell & Single-Scrollbar Hierarchy (STRICT)
1. **Fixed Header Height (`h-16` / 64px) & Mobile Menu Button:**
   - The top header of the application shell MUST have a fixed height of `h-16` (64px) with `sticky top-0 z-30 flex items-center justify-between px-6 border-b border-border-color bg-background/95 backdrop-blur`.
   - Never use mismatched heights (`h-14`, `h-20`, or uncoordinated vertical padding) that cause layout shift between pages.
   - The top header MUST include a standard top-left mobile menu hamburger button (`<button class="mobile-menu" data-action="menu" aria-label="Open navigation"><i class="fas fa-bars"></i></button>`). On mobile viewports (`max-width: 768px`), this button is visible (`inline-flex`) and toggles the off-canvas sidebar via `body.navopen` and a `<div class="shade"></div>` backdrop.
2. **Eliminate Double Vertical Scrollbars (STRICT BAN ON `min-h-screen` ON INNER VIEWPORTS):**
   - The outer application shell establishes the viewport boundary: `<div class="flex-1 flex flex-col h-screen overflow-hidden">`.
   - The scrollable content container is `<main class="flex-1 overflow-y-auto p-6 md:p-8 @container">`.
   - **NEVER** apply `min-h-screen` or nested `overflow-y-auto` to `<main>` or inner viewports! Doing so causes the infamous double-scrollbar defect where both the iframe/window and the inner container scroll simultaneously.
3. **Container Query Scoping Standard:**
   - Container query utility classes (`@sm:`, `@md:`, `@lg:`, `@xl:`) **MUST ONLY** be used inside a container element with an explicit `@container` class declared.
   - Using `@md:` without an ancestor `@container` breaks responsive behavior or fails silently.
4. **Non-Wrapping Status Badges & Pills:**
   - Status pills, priority tags, badges, and chips MUST include `whitespace-nowrap shrink-0 inline-flex items-center` to prevent text from awkwardly wrapping into multiple lines inside cards or table cells.

**✅ BEST PRACTICE (Canonical Layout Shell):**
```html
<div class="flex h-screen overflow-hidden bg-body-background">
  <!-- Sidebar -->
  <aside class="w-64 border-r border-border-color flex flex-col shrink-0">
    ...
  </aside>

  <!-- Main Area -->
  <div class="flex-1 flex flex-col h-screen overflow-hidden">
    <!-- Top Header: EXACTLY h-16 -->
    <header class="h-16 shrink-0 border-b border-border-color bg-background/95 backdrop-blur flex items-center justify-between px-6 z-30">
      ...
    </header>

    <!-- Scrollable Content: SINGLE SCROLLBAR, NEVER min-h-screen -->
    <main class="flex-1 overflow-y-auto p-6 md:p-8 @container">
      <div class="max-w-7xl mx-auto w-full space-y-6">
        ...
      </div>
    </main>
  </div>
</div>
```

**✅ BEST PRACTICE:**
```html
<!-- Good: Responsive table wrapper -->
<div class="overflow-x-auto w-full">
    <table class="min-w-full">...</table>
</div>
```
