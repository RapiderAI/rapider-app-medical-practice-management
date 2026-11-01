# Pass 1: Routing, Menu Links & Wrapper-Safe Navigation
**Goal:** Verify and fix that every menu link, anchor (`<a>`), and navigation button uses clean route paths (e.g. `/roster`) and `window.rapiderApi.navigate('/roster')` — NEVER `.html` file links (`roster.html`) or full CDN/HTTP URLs (`https://rapider.nyc3.cdn.digitaloceanspaces.com/.../roster.html`).

## Why `.html` and Full URLs Break the Rapider Host Wrapper (CRITICAL)
In production, Rapider microapplication pages are served from DigitalOcean Spaces CDN with an injected `<base href="https://rapider.nyc3.cdn.digitaloceanspaces.com/app/<appId>/develop/assets/">` tag inside the host wrapper iframe.
- If a menu link or anchor uses `href="roster.html"`, `href="./roster.html"`, or a full URL like `https://rapider.nyc3.cdn.digitaloceanspaces.com/app/814ab2ef-ad6b-4c66-9640-f8806a0c40f7/develop/assets/roster.html`, clicking it navigates the iframe directly to the raw CDN HTML file and **breaks the Rapider host wrapper**!
- Similarly, setting `window.location.href = 'roster.html'` in JavaScript breaks out of the host shell.

## Mandatory Routing Rules
1. **Strict Ban on `.html` Links and Full CDN URLs:**
   - **NEVER** use `.html` in `href` attributes (`href="roster.html"`, `href="index.html"`, `href="pages/roster/roster.html"`).
   - **NEVER** use hardcoded CDN or localhost URLs (`https://rapider.nyc3.cdn.digitaloceanspaces.com/...` or `http://localhost:4200/...`).
   - **NEVER** assign `.html` filenames to `location.href` in JavaScript.
2. **Enforce Clean Route Paths (`/route`) Matching `app.manifest.json`:**
   - Check `app.manifest.json` to ensure every page definition in `webPages` has a valid `route` property (e.g. `"route": "roster"`, `"path": "/roster"`).
   - All navigation links (`<a>`) MUST use clean route paths starting with `/` (e.g. `href="/roster"`, `href="/leads"`, `href="/dashboard"`) paired with `window.rapiderApi.navigate('/roster')`.
3. **Ensure Action Buttons Trigger Valid Handlers:**
   - Ensure action buttons (Submit, Save, Delete) trigger the correct API functions.
   - **CRITICAL DOM Timing:** If you use a global event delegator (e.g. `document.body.addEventListener`), wrap it in `DOMContentLoaded` or place the script at the end of `<body>`.
4. **STRICT RECORD ID ROUTING (`?id=<uuid>` — NEVER Name-Based `?person=`):**
   - All links and navigations to detail, profile, edit, or change-request pages **MUST** pass the entity's unique `id` (`href="#/profile?id=${emp.id}"`, `href="#/edit-employee?id=${emp.id}"`, `href="#/change-employee?id=${emp.id}"`).
   - **NEVER** route by display name (`?person=Marcus+Vance` or `?name=...`). Names are non-unique and break relational lookups.
   - Detail and edit pages **MUST** resolve the record ID using `window.rapiderApi?.getRouteParam?.('id') || new URLSearchParams(window.location.hash.split('?')[1] || window.location.search).get('id')`.
5. **DETAIL PAGE TABS MUST SWITCH IN-PAGE PANELS (NEVER NAVIGATE TO ROOT PAGES):**
   - Tab bars (`<nav class="tabs">`, `[role="tablist"]`) inside a record detail/profile page (e.g. `Overview`, `Job & employment`, `Documents`, `History & changes`) **MUST** switch in-page tab panels (`<button type="button" data-tab="...">`) showing **that specific record's** scoped data.
   - **NEVER** wire detail-page tabs as `<a href="#/documents">` or `<a href="#/lifecycle">` that navigate away from the record detail page to root app pages!
   - Furthermore, because the Rapider `<html-preview>` host intercepts `<a>` click events in the capture phase, in-page tab triggers **MUST** use `<button type="button" data-tab="...">` instead of `<a href="#">`.
6. **ACTIVE MENU ITEM HIGHLIGHT & SYNCHRONIZATION:**
   - The application navigation sidebar must synchronize its active visual state with the current route (`window.location.hash` or `window.location.pathname`).
   - Exactly one navigation link must have the active class (e.g. `bg-primary/10 text-primary font-semibold`) matching the current page.
   - Navigating between pages must clear stale active classes on previous links and activate the new route.
7. **BAN ON JS INLINE `style.display` OVERRIDES FOR NAVIGATION & SIDEBAR COLLAPSE:**
   - **NEVER** manipulate `.style.display = 'block'` or `.style.display = 'none'` on individual sidebar items or labels in JavaScript.
   - Sidebar collapsing must be managed strictly by toggling a CSS class (e.g. `collapsed` or `data-collapsed="true"`) on the parent `<aside>` or layout container.
   - In CSS, collapsed sidebar labels must be hidden with `display: none !important;` so that no text fragments leak when collapsed.

**✅ BEST PRACTICE (Wrapper-Safe Route Navigation):**
```html
<!-- Good: Clean route href="/roster" + SDK navigation -->
<a href="/roster" onclick="event.preventDefault(); window.rapiderApi && window.rapiderApi.navigate('/roster');">
  Learners &amp; Roster
</a>
```
```javascript
// Good: Navigate via Rapider SDK using clean route path
document.getElementById('btn-new-lead').addEventListener('click', () => {
  if (window.rapiderApi && typeof window.rapiderApi.navigate === 'function') {
    window.rapiderApi.navigate('/new-lead');
  }
});
```

**❌ BAD PRACTICE (Breaks the Rapider Wrapper — STRICTLY FORBIDDEN):**
```html
<!-- FORBIDDEN: .html file link resolves to CDN asset URL and breaks the wrapper -->
<a href="roster.html">Learners &amp; Roster</a>

<!-- FORBIDDEN: Hardcoded CDN / DigitalOcean Spaces or localhost URL -->
<a href="https://rapider.nyc3.cdn.digitaloceanspaces.com/app/814ab2ef-ad6b-4c66-9640-f8806a0c40f7/develop/assets/roster.html">Roster</a>
<a href="http://localhost:4200/app/123/new-lead">New Lead</a>

<!-- FORBIDDEN: Dead link with no route or handler -->
<a href="#">New Lead</a>
```
