# Pass 11: E2E Expectations & Deterministic Test Coverage
**Goal:** Verify and guarantee that `e2e/expectations.json` is constructed by the builder agent with exhaustive, deterministic test coverage for **one and every page** of an application.

The E2E expectations builder agent MUST develop at least these 6 deterministic test groups for each and every page:

### 1. Test All Clickable Actions and Buttons (In the Page)
- Every interactive button (`<button>`, `[role="button"]`, `[data-action]`), tab switcher, filter pill (`[data-status]`), action icon, and modal/drawer trigger on the page MUST be tested in deterministic sequence.
- **Deterministic Action Ordering:**
  - View switchers / tab pills (e.g. `#tabLeads`, `#tabOpps`) must be clicked first to verify tab switching.
  - Filter pills (`[data-status="Approved"]`) and search inputs must be exercised to verify data filtering.
  - Modal/drawer open buttons (e.g. `#btnNew...`, `#btnQuick...`, `#btnEdit...`) must be clicked BEFORE attempting to interact with the inputs inside that container.
  - Table action buttons (row navigation, edit, delete) and modal confirm buttons (`#rapiderConfirmOkBtn`) must be exercised.

### 2. Test All Data Operations (Read/Fetch Data) (In the Page)
- Every network read request executed by the page on initial render or filter change (`findSWR`, `find`, `countSWR`, `count`, `findById`) MUST be asserted using `assert_api_payload`.
- Assertions must specify the exact `operation` (e.g. `findSWR`, `countSWR`) and `entityName` (e.g. `CrmAccount`, `CrmLead`).
- Verify that initial page queries load without errors and populate view counters, tables, or kanban boards.

### 3. Test All Routes and Navigation (In the Page)
- Every navigation link and route action on the page MUST be tested:
  - Primary record identifier links (e.g. clicking account name or lead name navigating to `#/{entity}-detail`).
  - Back buttons (e.g. `#btnGoBack`, `a.back`) returning to parent list views.
  - Drawer opening actions (`window.rapiderApi.openPageDrawer` / `showPageDrawer`).
  - Route navigation calls (`window.rapiderApi.navigate`) must be asserted via `assert_api_payload` or navigation step.

### 4. Test Dark and Light Theme
- Every page suite MUST include deterministic theme rendering validation:
  ```json
  {
    "name": "Validate Light/Dark Theme Rendering",
    "action": "validate_theme",
    "category": "theme_visual",
    "explanation": "Capture screens and verify visual suitability, contrast ratios, and theme variable usage across dark and light modes"
  }
  ```
- Ensures no unreadable text, hardcoded `#ffffff` backgrounds, or contrast violations on saturated primary/danger buttons.

### 5. Test Form Elements & SDK Mutation Payloads
- Every input element (`<input>`, `<textarea>`, `<select>`, `<rapider-phone-input>`) on the page (in forms, modals, drawers, or search bars) MUST be deterministically tested:
  - Text inputs: Type valid, realistic test values (formatted per type: proper email for `type="email"`, numbers for `type="number"`, ISO dates for `type="date"`).
  - Select inputs: Explicit `select` action choosing a valid option value.
  - Phone inputs: Type valid international phone format.
- **SDK Mutation Payload Assertions (`expectedPayload`):**
  - Submitting forms (`click` on `#btnSave...`, `#btnCreate...`) MUST be immediately followed by `assert_api_payload` verifying the mutation (`create`, `update`, `updateById`, `delete`, `deleteById`).
  - The assertion MUST include `expectedPayload` containing the deterministic payload attributes passed to the SDK function:
    ```json
    {
      "name": "Assert API create CrmAccount",
      "action": "assert_api_payload",
      "operation": "create",
      "entityName": "CrmAccount",
      "expectedPayload": {
        "name": "Apex Global Logistics",
        "industry": "Logistics & Supply Chain",
        "revenue": 750000,
        "website": "https://apexglobal.example.com"
      },
      "category": "sdk_payload",
      "explanation": "Verifies that create is called for CrmAccount with exact expected payload"
    }
    ```
  - In test mode, mutations are intercepted: no real data is altered in the backend database, but the payload sent to the SDK is strictly asserted.

### 6. Test Responsive Design (Desktop, Tablet, Mobile)
- Every page suite MUST include deterministic responsive design validation:
  ```json
  {
    "name": "Validate Responsive Viewports",
    "action": "validate_responsive",
    "category": "responsive_design",
    "explanation": "Check UI layout on Mobile (375px), Tablet (768px), and Desktop (1280px) breakpoints"
  }
  ```
- Must also include layout alignment and accessibility checks:
  ```json
  {
    "name": "Validate Margin and Padding Alignments",
    "action": "validate_layout",
    "category": "layout_alignment",
    "explanation": "Check alignments, clipping, overflows, margin, and paddings"
  },
  {
    "name": "Validate Accessibility (a11y)",
    "action": "validate_a11y",
    "category": "accessibility_a11y",
    "explanation": "Check for ARIA labels, contrast ratios, and keyboard navigation"
  }
  ```

---

### Critical Prohibitions & Mandatory Real E2E Verification Rules
- **Physical Selector Existence Verification (ZERO PHANTOM SELECTORS):** Before writing or generating any test step in `expectations.json`, the test generator MUST inspect the target HTML file and verify that every selector (`#id`, `.class`, `[data-action]`, `button`) physically exists in the rendered markup. Asserting phantom or guessed selectors that do not exist causes immediate test suite failures.
- **ZERO Silent False Positives on Missing Selectors:** E2E test runners (`run-employees-e2e.js`) MUST NEVER treat a missing DOM element in a `click`, `type`, `select`, or `assert_text` step as a conditional pass (`PASS (conditional/hidden element)`). If a required selector does not exist or is not visible, the step MUST fail (`FAIL`).
- **ZERO HTTP 4xx/5xx Tolerance:** Every E2E suite MUST attach `page.on('response')` and `page.on('pageerror')` listeners and fail immediately if any API call to `/api/` returns status `>= 400` (such as `400 Bad Request` or `422 Unprocessable Entity` from schema mismatches).
- **Mandatory Detail-Page Hydration & Anti-Leak Assertions:** For every detail/profile/edit/change page (`profile`, `edit-employee`, `change-employee`), the E2E suite MUST:
  1. Navigate from a list row in `directory` using `?id=<uuid>` and assert the URL contains `?id=` and NEVER `?person=`.
  2. Assert that the loaded page displays the clicked record's exact name, email, employee number, and role, and contains **ZERO** hardcoded wireframe strings (`Amelia Brooks`, `amelia.brooks@example.com`, `EMP-0108`, `People around Amelia`).
  3. Click every in-page tab (`[data-tab="overview"]`, `[data-tab="job"]`, `[data-tab="documents"]`, `[data-tab="history"]`) and assert that `window.location.hash` stays on `#/profile?id=<uuid>` (never navigating away to root routes like `#/documents` or `#/lifecycle`) while toggling the corresponding `[data-tab-panel]`.
- **Mandatory Connected AI Assistant Verification:** Every E2E suite MUST test opening the `Ask Rapider` drawer (and inline AI thread on pages that have one), submitting a prompt, and asserting that a contextual response bubble renders in `#chat-messages` / `#ai-log`.
- **NO Synchronous Local SDK Calls:** The `assert_api_payload` action is strictly for network requests (`find`, `create`, `update`, `updateById`, `delete`, `deleteById`, `findSWR`, `countSWR`). NEVER add expectations for synchronous local SDK helper methods like `getRouteParam` or `closePageDrawer`.
- **NO Phantom Mutations:** Never assert `delete`, `deleteById`, or `update` if the corresponding action (e.g. clicking delete and confirming in dialog) was not physically triggered in the test sequence.
- **NO Out-of-Order Interactions:** Never type into modal/drawer inputs before clicking the button that opens the modal/drawer. Opening buttons often reset form state.
