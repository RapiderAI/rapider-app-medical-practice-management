# Pass 17: Input Formatting & International Phone Masking
**Goal:** Verify and fix the formatting and masking of specific input fields (e.g., Phone numbers, Dates, Currency).

## 1. International Phone Number Fields
- **CRITICAL:** Rapider applications serve users worldwide. **NEVER hardcode a single-country phone mask** (such as US-only `+{1} (000) 000-0000`).
- **Standard Component:** All phone number fields must use the shared international phone component bundled in `rapider-components.js`:
  - **Option A (Declarative Web Component):**
    ```html
    <rapider-phone-input id="phone" default-country="US"></rapider-phone-input>
    ```
  - **Option B (Progressive Enhancement on existing `<input>`):**
    ```javascript
    RapiderPhoneInput.attach(document.getElementById('phone'), { defaultCountry: 'US' });
    ```
- **Requirements for Phone Fields:**
  1. **Country Selector:** Must show international country code, flag emoji, and dial code (`+1`, `+44`, `+90`, etc.).
  2. **Dynamic Masking:** Mask must adjust automatically when a different country is selected.
  3. **Custom / Freeform Option:** The dropdown MUST include a "Custom" option (`🌐 Custom`) that disables masking and allows freeform input (extensions, symbols, or unlisted international numbers).
  4. **Form Compatibility:** Reading `document.getElementById('phone').value` must transparently return the complete formatted international string (e.g., `+1 (534) 454-5454` or the custom string).

## 2. Other Input Formatting (Dates, Currency, Numbers)
- Use standard HTML5 input types (`date`, `number`) or Rapider components (`<rapider-number-input>`).
- Format currencies with appropriate symbol and 2 decimal places.
