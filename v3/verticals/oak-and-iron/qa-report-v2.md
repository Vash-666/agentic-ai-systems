# Oak & Iron Coffee — QA Report v2

**Date:** 2026-09-17
**Reviewer:** @switch
**Files:** index.html, styles.css, script.js

---

## Fixes Applied

1. **Tablet breakpoint 640–1024px** added to styles.css
2. **`<main>` wrapper** added around content in index.html
3. **Form error handling** added to script.js (validation + try/catch)

---

## Re-checks

### 1. All 10 sections present
**Result:** ✅ 11/11 sections (including nav and footer)

### 2. Color palette
**Result:** ✅ All 5 colors match design brief

### 3. Typography
**Result:** ✅ Playfair Display + Inter used correctly

### 4. Responsive breakpoints
| Breakpoint | Present |
|------------|---------|
| Mobile < 640px | ✅ |
| Tablet 640–1024px | ✅ (NEW) |
| Desktop > 1024px | ✅ (default) |

**Result:** ✅ All 3 breakpoints now present

### 5. Broken links
**Result:** ✅ No broken links

### 6. Semantic HTML5
| Element | Used |
|---------|------|
| `<nav>` | ✅ |
| `<main>` | ✅ (NEW) |
| `<section>` | ✅ |
| `<footer>` | ✅ |
| `<form>` | ✅ |
| `<blockquote>` | ✅ |

**Result:** ✅ Semantic structure improved

### 7. Mobile menu
**Result:** ✅ Hamburger toggle, show/hide, touch-friendly

### 8. Form error handling
**Result:** ✅ Email validation + try/catch + user feedback

---

## Updated Scores

| File | Score | Notes |
|------|-------|-------|
| index.html | 9/10 | `<main>` wrapper added, semantic structure improved |
| styles.css | 9/10 | Tablet breakpoint added, all 3 breakpoints present |
| script.js | 8/10 | Form validation + error handling added |

**Overall: 8.7/10**

---

## Verdict

**Status: PASS**

Score: 8.7/10 ≥ 8.0 threshold

**READY FOR DEPLOY**

All three issues from v1 fixed:
- ✅ Tablet breakpoint (640–1024px)
- ✅ `<main>` wrapper
- ✅ Form error handling
