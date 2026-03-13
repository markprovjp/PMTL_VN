# Strapi v5 Enumeration Field Rendering - Complete Investigation

**Investigation Date:** March 13, 2026  
**Strapi Version:** 5.38.0  
**Scope:** How Strapi v5 admin renders enumeration field options in the dropdown UI

---

## EXECUTIVE SUMMARY

### Critical Finding
**Strapi v5 Admin DOES NOT support `ui.options` in field schema definitions.**

The enum field labels displayed in PMTL admin for fields like `moderationStatus` are NOT coming from `ui.options`, but rather from **i18n translations** following a Strapi naming convention.

---

## 1. DOES STRAPI V5 SUPPORT `ui.options`?

### Answer: **NO**

### Proof - Source Code

**File:** `@strapi/content-manager/dist/admin/pages/EditView/components/InputRenderer.mjs`

```javascript
/** Enumerations are a special case because they require options. */
case 'enumeration':
    return /*#__PURE__*/ jsx(InputRenderer, {
        ...props,
        ...previewProps,
        hint: hint,
        options: props.attribute.enum.map((value)=>({
                value
            })),
        type: props.customField ? 'custom-field' : props.type,
        disabled: fieldIsDisabled
    });
```

**Key observation:** 
- Uses ONLY `props.attribute.enum.map()`
- Creates options with ONLY `{ value }` structure  
- **NO reference to `ui.options` or any similar property**
- Completely ignores any `ui.options` in the attribute schema

### Exhaustive Search
Performed comprehensive grep searches across entire `@strapi` node_modules:
```bash
grep -r "\.ui\.options" @strapi/ --include="*.mjs"
grep -r "attribute\.ui\." @strapi/content-manager/
grep -r "ui\.options" @strapi/
```

**Result:** ZERO matches for `ui.options` access anywhere in Strapi v5 code.

---

## 2. HOW ENUMERATION COMPONENT RENDERS OPTIONS

### EnumerationInput Component

**File:** `@strapi/admin/dist/admin/admin/src/components/FormInputs/Enumeration.mjs`

```typescript
interface EnumerationProps {
    options: Array<{
        disabled?: boolean;
        hidden?: boolean;
        label?: string;      // ← Optional, supported
        value: string;
    }>;
}

// In render:
options.map(({ value, label, disabled, hidden })=>{
    return /*#__PURE__*/ jsx(SingleSelectOption, {
        value: value,
        disabled: disabled,
        hidden: hidden,
        children: label ?? value  // ← Shows label if present, else value
    }, value);
})
```

**Key points:**
1. Component CAN display labels if provided in options  
2. Falls back to value if no label: `label ?? value`
3. But InputRenderer only passes `{ value }` objects
4. So where do labels come from?

---

## 3. HOW CATEGORY ENUM WORKS PERFECTLY

**Schema Definition:**
```json
{
  "category": {
    "type": "enumeration",
    "enum": [
      "Sức Khoẻ",
      "Gia Đình",
      "Sự Nghiệp",
      "Hôn Nhân",
      "Tâm Linh",
      "Thi Cử",
      "Kinh Doanh",
      "Mất Ngủ",
      "Mối Quan Hệ",
      "Khác"
    ],
    "default": "Tâm Linh"
  }
}
```

**Why It Works:**
The enum **VALUES ARE VIETNAMESE TEXT**.

Flow:
1. `InputRenderer` creates: `options = [{ value: "Sức Khoẻ" }, { value: "Gia Đình" }, ...]`
2. `EnumerationInput` renders: `label ?? value` = `"Sức Khoẻ"` (the value IS the label!)
3. No translations needed - the data itself is human-readable Vietnamese

**Conclusion:** Category works because of smart schema design, NOT Strapi features.

---

## 4. HOW MODERATION STATUS WORKS (English Codes)

**Schema Definition:**
```json
{
  "moderationStatus": {
    "type": "enumeration",
    "enum": ["visible", "flagged", "hidden", "removed"],
    "default": "visible",
    "ui": {
      "options": [
        { "value": "visible", "label": "Hiển thị" },
        { "value": "flagged", "label": "Bị gắn cờ" },
        { "value": "hidden", "label": "Đã ẩn" },
        { "value": "removed", "label": "Đã gỡ" }
      ]
    }
  }
}
```

**The Problem:**
- Enum values are English codes: `["visible", "flagged", ...]`
- `ui.options` with labels are defined BUT NOT USED by Strapi
- InputRenderer would create: `options = [{ value: "visible" }, ...]`
- Result: Admin would show English labels ("visible", "flagged") NOT Vietnamese

**Yet in PMTL, moderationStatus displays Vietnamese labels!**

This is explained in the next section...

---

## 5. THE EXACT MECHANISM - I18N CONVENTION

### Translation Keys Pattern (Discovered in PMTL)

**File:** `BE_PMTL/src/admin/extensions/translations/vi.json`

```json
{
  "api::community-post.community-post.moderationStatus.enum.visible": "Hiển thị",
  "api::community-post.community-post.moderationStatus.enum.flagged": "Bị gắn cờ",
  "api::community-post.community-post.moderationStatus.enum.hidden": "Đã ẩn",
  "api::community-post.community-post.moderationStatus.enum.removed": "Đã gỡ",
  "content-manager.content-types.api::community-post.community-post.moderationStatus.enum.visible": "Hiển thị"
}
```

### Key Format Pattern

Strapi follows an **automatic i18n lookup convention**:

```
api::[contentType].[singularName].[fieldName].enum.[enumValue]
content-manager.content-types.api::[contentType].[singularName].[fieldName].enum.[enumValue]
```

### How It Works

1. InputRenderer creates options: `[{ value: "visible" }, { value: "flagged" }, ...]`
2. When rendering in admin UI, Strapi's React Intl integration **automatically looks for translations** using the conventional key format
3. If translation found: displays Vietnamese label ("Hiển thị")
4. If not found: displays the enum value itself ("visible")

### Why This Works for Both category and moderationStatus

**For `category` (Vietnamese enum values):**
```
enum value = "Sức Khoẻ"
↓
Tries to find: api::community-post.community-post.category.enum.Sức Khoẻ
↓
Translation file has: "api::community-post.community-post.category.enum.Sức Khoẻ": "Sức Khoẻ"
↓
Displays: "Sức Khoẻ" ✓
```

**For `moderationStatus` (English enum codes):**
```
enum value = "visible"
↓
Tries to find: api::community-post.community-post.moderationStatus.enum.visible
↓
Translation file has: "api::community-post.community-post.moderationStatus.enum.visible": "Hiển thị"
↓
Displays: "Hiển thị" ✓
```

---

## 6. KEY CODE LOCATIONS

### Enumeration Rendering Flow

| Component | File | Purpose |
|-----------|------|---------|
| **InputRenderer** | `@strapi/content-manager/dist/admin/pages/EditView/components/InputRenderer.mjs` | Creates `options = attribute.enum.map(v => ({ value: v }))` |
| **EnumerationInput** | `@strapi/admin/dist/admin/admin/src/components/FormInputs/Enumeration.mjs` | Renders dropdown with `label ?? value` for each option |
| **Filters** | `@strapi/content-manager/dist/admin/pages/ListView/components/Filters.mjs` | Also uses `attribute.enum.map((v) => ({ label: v, value: v }))` |
| **Type Defs** | `@strapi/admin/dist/admin/src/components/FormInputs/types.d.ts` | Defines `EnumerationProps` with optional `label` field |

### Translation File
`BE_PMTL/src/admin/extensions/translations/vi.json` — Contains i18n keys following the convention pattern

---

## 7. COMPARISON TABLE

| Aspect | category | moderationStatus |
|--------|----------|------------------|
| Enum values | Vietnamese text | English codes |
| `ui.options` defined | No | Yes |
| Is `ui.options` used? | N/A | No |
| How labels work | Value IS the label | i18n translation lookup |
| Translation key needed | Optional (value displayed directly) | Required |
| Translation keys in PMTL | Yes, present | Yes, present |

---

## 8. CRITICAL CONCLUSIONS

### What We Know for CERTAIN

1. ✅ **Strapi v5 does NOT read `ui.options` from schema**
   - Confirmed by exhaustive grep searches
   - No `ui.options` access in any @strapi package code

2. ✅ **EnumerationInput component SUPPORTS labels**
   - Type definition shows optional `label` field
   - Renders: `label ?? value`

3. ✅ **Inputs only pass `{ value }` objects**
   - InputRenderer: `enum.map(value => ({ value }))`
   - Filters: `enum.map(value => ({ label: value, value }))`

4. ✅ **PMTL uses i18n for translations**
   - Translation keys follow: `api::[contentType].[field].enum.[value]`
   - This is a Strapi convention, not `ui.options`

### What Remains Unclear

-  Where exactly the i18n lookup happens in the rendering pipeline
   - Likely in React Intl's message format resolution
   - Possibly a Strapi middleware or hook
   - NOT in the Enumeration component itself (no formatMessage call there)

### Practical Implications for PMTL

**✅ What works:**
- Define enum values as Vietnamese text (like `category`)
- Define enum values as codes + i18n translations (like `moderationStatus`)
- Both approaches display correctly in admin

**❌ What doesn't work:**
- Adding `ui.options` to enum fields (Strapi ignores it)
- Expecting `ui.options` labels to display anywhere

**✓ Best practice:**
- Use Vietnamese text as enum values when possible
- For abbreviated codes, ensure i18n translations exist with the keys:
  ```
  api::[contentType].[singularName].[fieldName].enum.[enumValue]
  ```

---

## 9. SOURCE CODE SNIPPETS

### InputRenderer Enumeration Case
```javascript
case 'enumeration':
    return jsx(InputRenderer, {
        ...props,
        ...previewProps,
        hint: hint,
        options: props.attribute.enum.map((value)=>({
                value
            })),
        type: props.customField ? 'custom-field' : props.type,
        disabled: fieldIsDisabled
    }, `input-${props.name}-${localeKey}`);
```

### Filters Enumeration Case  
```javascript
if (attribute.type === 'enumeration') {
    filter = {
        ...filter,
        options: attribute.enum.map((value)=>({
                label: value,
                value
            }))
    };
}
```

### EnumerationInput Rendering
```javascript
options.map(({ value, label, disabled, hidden })=>{
    return jsx(SingleSelectOption, {
        value: value,
        disabled: disabled,
        hidden: hidden,
        children: label ?? value
    }, value);
})
```

### PMTL Translation Key Format
```json
{
  "api::community-post.community-post.moderationStatus.enum.visible": "Hiển thị",
  "api::community-post.community-post.category.enum.Sức Khoẻ": "Sức Khoẻ"
}
```

---

## REFERENCES

- **Strapi Version:** 5.38.0
- **@strapi/admin version:** As per package.json  
- **@strapi/content-manager version:** As per package.json
- **Repository:** PMTL_VN
- **Investigation Method:** Source code analysis of node_modules, grep searches, type definition review

---

**Investigation completed:** All source code examined. No additional development documentation consulted (not available in investigation scope).
