# Guide: Suite Brand & Collapsible Sidebar Navigation Standards

## Overview
Every Rapider application belongs to a specific business suite (e.g. HR Suite, Finance Suite, Projects Suite, Operations Suite, Marketing Suite, etc.). To provide a professional, unified experience across the entire Rapider ecosystem, all applications MUST follow these canonical standards:
1. Replace fake Rapider logos and placeholder brandmarks with authentic Suite Icons and Suite Titles.
2. Implement collapsible sidebar navigation with instant compact icon-only mode.
3. Feature an interactive right-caret expand icon that reveals on the top Suite icon when hovering over the collapsed sidebar.
4. Persist user collapsed preferences across page navigations via `localStorage`.

---

## 1. Application Manifest Requirements (`app.manifest.json`)
Every app's `app.manifest.json` MUST define an `appSuite` object containing:
- `key`: The uppercase suite acronym (e.g., `"HR"`, `"FIN"`, `"APM"`, `"OPS"`, `"MFG"`, `"MKT"`, `"LRN"`, `"CRM"`, `"PLT"`, `"DEV"`, `"COM"`, `"PRS"`, `"SUP"`).
- `title`: The official full suite title (e.g., `"Rapider HR & Talent Suite"`).
- `shortTitle`: The concise title used in UI headers (e.g., `"HR Suite"`).
- `icon`: The FontAwesome icon class representing the suite (e.g., `"fas fa-users"`, `"fas fa-wallet"`, `"fas fa-layer-group"`).

```json
"appSuite": {
  "key": "HR",
  "title": "Rapider HR & Talent Suite",
  "shortTitle": "HR Suite",
  "icon": "fas fa-users"
}
```

---

## 2. Canonical Suite Icon Mapping
| Suite Key | Short Title | FontAwesome Icon | Description |
|-----------|-------------|------------------|-------------|
| `HR` | HR Suite | `fas fa-users` | HR, People & Talent Management |
| `FIN` | Finance Suite | `fas fa-wallet` | Accounting, Billing, Expenses, Finance |
| `APM` | Projects Suite | `fas fa-layer-group` | Agile Project Management, Planning, Resources |
| `OPS` | Operations Suite | `fas fa-cogs` | Asset Management, Inventory, Procurement, Vendors |
| `MFG` | Manufacturing Suite | `fas fa-industry` | BOM, MRP, PLM, Production, Quality |
| `MKT` | Marketing Suite | `fas fa-bullhorn` | Campaigns, Email, Events, Forms, Social |
| `LRN` | Learning Suite | `fas fa-graduation-cap` | Content Studio, In-Class, Online Learning |
| `CRM` | CRM Suite | `fas fa-handshake` | Customer Relationship Management |
| `PLT` | Platform Suite | `fas fa-cubes` | Design System, Architecture & Platform |
| `DEV` | Developer Suite | `fas fa-code` | Developer Tools, Translation, Code |
| `COM` | Commerce Suite | `fas fa-shopping-cart` | eCommerce, POS, Product Catalog |
| `PRS` | Personal Suite | `fas fa-user` | Habits, Fitness, Goals, Wellness, Journal |
| `SUP` | Support Suite | `fas fa-headset` | Customer Support & Service Portals |

---

## 3. Sidebar Header HTML Structure
Replace legacy `.brand` elements containing `<span class="brandmark">r</span>rapider` with the following canonical structure:

```html
<div class="brand-row">
  <a class="brand" href="#/overview" title="HR Suite">
    <span class="suite-icon-container">
      <i class="suite-icon fas fa-users"></i>
      <i class="suite-expand-icon fas fa-chevron-right"></i>
    </span>
    <span class="suite-title">HR Suite</span>
  </a>
  <button type="button" class="sidebar-collapse-btn" title="Collapse sidebar" aria-label="Collapse sidebar">
    <i class="fas fa-chevron-left"></i>
  </button>
</div>
```

---

## 4. CSS Specification (`<style data-collapsible-sidebar>`)
```css
.brand-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 10px 23px;
  position: relative;
  min-height: 32px;
}
.brand-row .brand, a.brand {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 16px;
  font-weight: 720;
  letter-spacing: -0.8px;
  color: inherit;
  text-decoration: none;
  min-width: 0;
  flex: 1;
}
.suite-icon-container {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  flex-shrink: 0;
}
.suite-icon-container .suite-icon {
  font-size: 16px;
  color: inherit;
  transition: transform 0.15s ease;
}
.suite-icon-container .suite-expand-icon {
  display: none !important;
  font-size: 15px;
  color: var(--purple, #6854df);
}
.sidebar-collapse-btn {
  background: transparent;
  border: 1px solid transparent;
  cursor: pointer;
  padding: 5px 7px;
  border-radius: 6px;
  color: var(--muted, #758097);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  min-height: auto;
  line-height: 1;
  transition: all 0.2s ease;
}
.sidebar-collapse-btn:hover {
  background: var(--soft, #eeeaff);
  color: var(--purple, #6854df);
  border-color: #cfc7f4;
}

/* Collapsed State */
.layout.sidebar-collapsed {
  grid-template-columns: 68px minmax(0, 1fr) !important;
}
.sidebar.sidebar-collapsed,
#apm-sidebar.sidebar-collapsed,
.sidebar-collapsed .sidebar {
  width: 68px !important;
  min-width: 68px !important;
  max-width: 68px !important;
  padding-left: 8px !important;
  padding-right: 8px !important;
  transition: width 0.2s ease, padding 0.2s ease;
}
.sidebar.sidebar-collapsed .brand-row,
.sidebar-collapsed .brand-row {
  justify-content: center !important;
  padding: 0 0 20px 0 !important;
  width: 100% !important;
}
.sidebar.sidebar-collapsed .brand-row .brand,
.sidebar-collapsed .brand-row .brand {
  justify-content: center !important;
  flex: none !important;
  cursor: pointer;
  padding: 0 !important;
  gap: 0 !important;
}
.sidebar.sidebar-collapsed .suite-title,
.sidebar-collapsed .suite-title,
.sidebar.sidebar-collapsed .sidebar-collapse-btn,
.sidebar-collapsed .sidebar-collapse-btn,
.sidebar.sidebar-collapsed .close-nav,
.sidebar-collapsed .close-nav,
.sidebar.sidebar-collapsed .navclose,
.sidebar-collapsed .navclose {
  display: none !important;
}

/* Centering icons in collapsed mode */
.sidebar.sidebar-collapsed .appbox,
.sidebar-collapsed .appbox {
  justify-content: center !important;
  padding: 8px 4px !important;
  margin-bottom: 16px !important;
}
.sidebar.sidebar-collapsed .appbox span:not(.appicon),
.sidebar-collapsed .appbox span:not(.appicon),
.sidebar.sidebar-collapsed .appbox b,
.sidebar-collapsed .appbox b,
.sidebar.sidebar-collapsed .appbox small,
.sidebar-collapsed .appbox small {
  display: none !important;
}

/* Center nav items and hide all text labels */
.sidebar.sidebar-collapsed .nav a,
.sidebar-collapsed .sidebar .nav a,
.sidebar.sidebar-collapsed .nav-item,
.sidebar-collapsed .sidebar .nav-item {
  justify-content: center !important;
  padding: 10px 0 !important;
  width: 44px !important;
  margin: 0 auto 4px auto !important;
  font-size: 0 !important;
}
.sidebar.sidebar-collapsed .nav a svg,
.sidebar-collapsed .sidebar .nav a svg,
.sidebar.sidebar-collapsed .nav a i,
.sidebar-collapsed .sidebar .nav a i,
.sidebar.sidebar-collapsed .nav-item svg,
.sidebar-collapsed .sidebar .nav-item svg,
.sidebar.sidebar-collapsed .nav-item i,
.sidebar-collapsed .sidebar .nav-item i {
  font-size: 16px !important;
  width: 18px !important;
  height: 18px !important;
  margin: 0 !important;
}
.sidebar.sidebar-collapsed .sidebar-label,
.sidebar-collapsed .sidebar .sidebar-label,
.sidebar.sidebar-collapsed .navlabel,
.sidebar-collapsed .sidebar .navlabel,
.sidebar.sidebar-collapsed .side-bottom strong,
.sidebar-collapsed .sidebar .side-bottom strong,
.sidebar.sidebar-collapsed .side-bottom small,
.sidebar-collapsed .sidebar .side-bottom small,
.sidebar.sidebar-collapsed .profile-link strong,
.sidebar-collapsed .sidebar .profile-link strong,
.sidebar.sidebar-collapsed .profile-link small,
.sidebar-collapsed .sidebar .profile-link small,
.sidebar.sidebar-collapsed #active-project-wrapper,
.sidebar-collapsed .sidebar #active-project-wrapper {
  display: none !important;
}
.sidebar.sidebar-collapsed .profile-link,
.sidebar-collapsed .sidebar .profile-link {
  justify-content: center !important;
  padding: 12px 0 0 !important;
}

/* Top Suite Icon -> Expand Icon (Right Caret) when mouse hovers over collapsed menu/icons */
.sidebar.sidebar-collapsed:hover .brand-row .suite-icon,
.sidebar-collapsed .sidebar:hover .brand-row .suite-icon,
.sidebar.sidebar-collapsed .brand-row:hover .suite-icon,
.sidebar-collapsed .brand-row:hover .suite-icon {
  display: none !important;
}
.sidebar.sidebar-collapsed:hover .brand-row .suite-expand-icon,
.sidebar-collapsed .sidebar:hover .brand-row .suite-expand-icon,
.sidebar.sidebar-collapsed .brand-row:hover .suite-expand-icon,
.sidebar-collapsed .brand-row:hover .suite-expand-icon {
  display: inline-flex !important;
  cursor: pointer;
  animation: pulse-caret 1.2s infinite ease-in-out;
}
@keyframes pulse-caret {
  0%, 100% { transform: translateX(0); }
  50% { transform: translateX(2px); }
}
```

---

## 5. JavaScript Implementation (`<script data-collapsible-sidebar>`)
```javascript
(function() {
  function initCollapsibleSidebar() {
    const sidebar = document.querySelector('aside.sidebar, #apm-sidebar, aside');
    if (!sidebar) return;
    const layout = document.querySelector('.layout') || document.querySelector('.flex.h-screen') || document.body;

    function setCollapsed(collapsed) {
      if (collapsed) {
        sidebar.classList.add('sidebar-collapsed');
        if (layout) layout.classList.add('sidebar-collapsed');
        try { localStorage.setItem('rapider_sidebar_collapsed', 'true'); } catch(e) {}
      } else {
        sidebar.classList.remove('sidebar-collapsed');
        if (layout) layout.classList.remove('sidebar-collapsed');
        try { localStorage.setItem('rapider_sidebar_collapsed', 'false'); } catch(e) {}
      }
    }

    // Collapse button click handler
    const collapseBtns = sidebar.querySelectorAll('.sidebar-collapse-btn, #btn-sidebar-collapse');
    collapseBtns.forEach(btn => {
      btn.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        setCollapsed(true);
      });
    });

    // Expand click on top Suite icon / right caret when collapsed
    const brand = sidebar.querySelector('.brand');
    const brandRow = sidebar.querySelector('.brand-row');
    const suiteIconContainer = sidebar.querySelector('.suite-icon-container');

    function handleExpandClick(e) {
      if (sidebar.classList.contains('sidebar-collapsed') || (layout && layout.classList.contains('sidebar-collapsed'))) {
        e.preventDefault();
        e.stopPropagation();
        setCollapsed(false);
      }
    }

    if (suiteIconContainer) {
      suiteIconContainer.addEventListener('click', handleExpandClick);
    }
    if (brand) {
      brand.addEventListener('click', function(e) {
        if (sidebar.classList.contains('sidebar-collapsed') || (layout && layout.classList.contains('sidebar-collapsed'))) {
          handleExpandClick(e);
        }
      });
    }
    if (brandRow) {
      brandRow.addEventListener('click', function(e) {
        if (sidebar.classList.contains('sidebar-collapsed') || (layout && layout.classList.contains('sidebar-collapsed'))) {
          handleExpandClick(e);
        }
      });
    }

    // Restore persistent state from localStorage
    try {
      if (localStorage.getItem('rapider_sidebar_collapsed') === 'true') {
        setCollapsed(true);
      }
    } catch(e) {}
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initCollapsibleSidebar);
  } else {
    initCollapsibleSidebar();
  }
})();
```
