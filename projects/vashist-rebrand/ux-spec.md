# Vashist Rebrand — UX Specification
**Project:** Personal Website Rebrand  
**Date:** 2026-05-24  
**Designer:** @ux  
**Status:** ✅ Complete

---

## 1. Room-by-Room Wireframes

### THE PIVOT — 6 Gallery Rooms

Each room is a full viewport experience. No scrolling within rooms — snap holds you in place.

```
┌─────────────────────────────────────────────────────────────┐
│ ROOM 1: THE DOORWAY (Hero)                                  │
│ ─────────────────────────────────────────────────────────── │
│                                                             │
│     ┌──────────────────────────────────────────┐            │
│     │                                          │            │
│     │     [ MACRO TEXTURE: Weathered wood      │            │
│     │       or aged metal, full-bleed ]        │            │
│     │                                          │            │
│     │          ROHIT VASHIST                   │
│     │          ─────────────                   │
│     │                                          │
│     │     Product Leader • Systems Thinker     │
│     │     Federal AI • Web3 Architecture       │
│     │                                          │
│     │              [ ↓ ]                       │
│     │                                          │
│     └──────────────────────────────────────────┘            │
│                                                             │
│  Full-bleed texture background. Name centered.              │
│  Single downward indicator (subtle pulse).                  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ ROOM 2: THE PILLARS (What I Do)                             │
│ ─────────────────────────────────────────────────────────── │
│                                                             │
│     THREE PILLARS                                           │
│     ─────────────                                           │
│                                                             │
│     ┌──────────┐  ┌──────────┐  ┌──────────┐                │
│     │  🏛️      │  │  🌐      │  │  🧠      │                │
│     │          │  │          │  │          │                │
│     │Government│  │  Web3 &  │  │Philosophy│                │
│     │Moderniza-│  │  AI      │  │  &       │                │
│     │  tion    │  │Innovation│  │ Practice │                │
│     │          │  │          │  │          │                │
│     │ [macro   │  │ [macro   │  │ [macro   │                │
│     │  stone]  │  │ circuit] │  │  ink]    │                │
│     └──────────┘  └──────────┘  └──────────┘                │
│                                                             │
│  3-column layout. Each pillar has texture thumbnail.        │
│  Hover: subtle scale (1.02) + shadow lift.                  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ ROOM 3: THE ARC (About / Journey)                           │
│ ─────────────────────────────────────────────────────────── │
│                                                             │
│     THE ARC                                                 │
│     ───────                                                 │
│                                                             │
│     ┌────────────────────┐  ┌────────────────────┐          │
│     │                    │  │                    │          │
│     │   [Macro texture:  │  │  Two civilizations:│          │
│     │    flowing water   │  │                    │          │
│     │    or sand dunes]  │  │  India's           │          │
│     │                    │  │  spirituality      │          │
│     │                    │  │  +                 │          │
│     │                    │  │  America's         │          │
│     │                    │  │  capitalism        │          │
│     │                    │  │                    │          │
│     │                    │  │  [Continue story]  │          │
│     └────────────────────┘  └────────────────────┘          │
│                                                             │
│  2-column: texture left, narrative right.                   │
│  Text reveals line-by-line on entry.                        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ ROOM 4: THE WORK (Impact)                                   │
│ ─────────────────────────────────────────────────────────── │
│                                                             │
│     IMPACT                                                  │
│     ──────                                                  │
│                                                             │
│     ┌──────────┐                                            │
│     │ $350M+   │  Program Leadership                        │
│     │ 80M+     │  Users Served                              │
│     │ 10+      │  Years Experience                          │
│     │ Top 10   │  GSA AI Hackathon                          │
│     └──────────┘                                            │
│                                                             │
│     ┌─────────────────────────────────────────────────────┐ │
│     │ SAM.gov Entity Registration                         │ │
│     │ [macro: paper texture]    7 days → 3 days          │ │
│     ├─────────────────────────────────────────────────────┤ │
│     │ FPDS Natural Language Search                        │ │
│     │ [macro: fiber optic]      Bedrock + OpenSearch     │ │
│     ├─────────────────────────────────────────────────────┤ │
│     │ GSA AI Hackathon Winner                             │ │
│     │ [macro: circuit board]    Custom GPT for DOE       │ │
│     └─────────────────────────────────────────────────────┘ │
│                                                             │
│  Stats row at top. Project cards stack below.               │
│  Each card: texture thumb left, content right.              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ ROOM 5: THE PRINCIPLES (Philosophy)                         │
│ ─────────────────────────────────────────────────────────── │
│                                                             │
│     CORE PRINCIPLES                                         │
│     ───────────────                                         │
│                                                             │
│     ┌─────────────────────────────────────────────────────┐ │
│     │  Life is Experience                                 │ │
│     │  [macro: hands holding clay]                        │ │
│     ├─────────────────────────────────────────────────────┤ │
│     │  Intentions Outshine Results                        │ │
│     │  [macro: compass needle]                            │ │
│     ├─────────────────────────────────────────────────────┤ │
│     │  Curiosity Compounds                                │ │
│     │  [macro: spiral shell]                              │ │
│     ├─────────────────────────────────────────────────────┤ │
│     │  Inner Peace Is Expensive                           │ │
│     │  [macro: still water]                               │ │
│     └─────────────────────────────────────────────────────┘ │
│                                                             │
│  Vertical stack of 4 principle cards.                       │
│  Each: full-width card, texture background, text overlay.   │
│  Scroll-snap within room: NO. Single viewport.              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ ROOM 6: THE THRESHOLD (Contact)                             │
│ ─────────────────────────────────────────────────────────── │
│                                                             │
│     ┌─────────────────────────────────────────────────────┐ │
│     │                                                     │ │
│     │     [Macro texture: Open doorway,                  │ │
│     │      light streaming through,                       │ │
│     │      or horizon line]                               │ │
│     │                                                     │ │
│     │              LET'S BUILD                            │
│     │              ───────────                            │ │
│     │                                                     │ │
│     │     rohit@vash1st.com                               │ │
│     │                                                     │ │
│     │     [LinkedIn]  [GitHub]  [Twitter]                 │ │
│     │                                                     │ │
│     └─────────────────────────────────────────────────────┘ │
│                                                             │
│  Full-bleed texture. Centered CTA.                          │
│  Social links as minimal icons.                             │
│  Email as primary action.                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Scroll Snap Behavior

### CSS Scroll-Snap Specs

```css
/* Container */
.gallery-container {
  height: 100vh;
  width: 100vw;
  overflow-y: scroll;
  scroll-snap-type: y mandatory;
  scroll-behavior: smooth;
}

/* Each room */
.room {
  height: 100vh;
  width: 100vw;
  scroll-snap-align: start;
  scroll-snap-stop: always;
  position: relative;
}

/* Optional: snap on touch devices */
@media (pointer: coarse) {
  .gallery-container {
    scroll-snap-type: y proximity;
  }
}
```

### Snap Behavior Rules

| Trigger | Behavior |
|---------|----------|
| Scroll > 50% to next room | Snap to next room |
| Scroll < 50% to next room | Snap back to current |
| Fast flick | Snap in flick direction |
| Slow drag | Snap to nearest room |
| Keyboard (↓/↑) | Snap to next/prev room |
| Touch swipe | Natural feel, snap on release |

### Snap Duration
- **CSS default:** 300-400ms
- **Recommended:** `scroll-behavior: smooth` (browser native)
- **No custom JS easing** — let browser handle performance

---

## 3. Animation Choreography

### Room Entry Animations

Each room animates ONCE when first entering viewport.

```
ROOM 1 (Hero) — Immediate, no scroll trigger
├── Background texture: fade in (0ms, 800ms duration)
├── Name "ROHIT VASHIST": 
│   └── Fade up from y: 30px (200ms delay, 600ms duration)
├── Tagline:
│   └── Fade up from y: 20px (400ms delay, 500ms duration)
└── Scroll indicator:
    └── Fade in + subtle bounce (800ms delay, infinite)

ROOM 2 (Pillars) — On snap complete
├── Title "THREE PILLARS":
│   └── Fade in (0ms, 400ms)
├── Pillar 1 (Gov):
│   └── Scale from 0.9 + fade (100ms delay, 500ms)
├── Pillar 2 (Web3):
│   └── Scale from 0.9 + fade (200ms delay, 500ms)
├── Pillar 3 (Philosophy):
│   └── Scale from 0.9 + fade (300ms delay, 500ms)
└── Stagger: 100ms between each

ROOM 3 (The Arc) — On snap complete
├── Texture (left):
│   └── Slide from x: -50px + fade (0ms, 700ms)
├── Title "THE ARC":
│   └── Fade up (200ms delay, 400ms)
├── Narrative text:
│   └── Line-by-line reveal (400ms base, 150ms stagger per line)
└── Total sequence: ~1.5s

ROOM 4 (Impact) — On snap complete
├── Stats row:
│   └── Count-up animation (0ms, 1200ms duration)
├── Project cards:
│   └── Slide up from y: 40px + fade (stagger 150ms each)
└── Card textures: subtle parallax on scroll (optional)

ROOM 5 (Principles) — On snap complete
├── Title: fade in (0ms, 400ms)
├── Principle cards:
│   └── Slide from right x: 60px + fade (stagger 200ms)
└── Texture in each card: slow zoom (20s duration, subtle)

ROOM 6 (Contact) — On snap complete
├── Background: fade in (0ms, 800ms)
├── "LET'S BUILD":
│   └── Scale from 0.95 + fade (300ms delay, 600ms)
├── Email:
│   └── Fade up (500ms delay, 400ms)
└── Social icons:
    └── Pop in scale (700ms base, 100ms stagger)
```

### Easing Functions

```css
/* Standard entrance */
--ease-out-expo: cubic-bezier(0.16, 1, 0.3, 1);

/* Bounce/pop */
--ease-out-back: cubic-bezier(0.34, 1.56, 0.64, 1);

/* Smooth fade */
--ease-out-quart: cubic-bezier(0.25, 1, 0.5, 1);
```

### Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  .room * {
    animation: none !important;
    transition: opacity 200ms ease !important;
  }
}
```

---

## 4. Typography Scale

### Font Families

```css
--font-display: 'Editorial New', Georgia, serif;
--font-body: 'Space Grotesk', -apple-system, sans-serif;
```

### Type Scale

| Element | Font | Size | Weight | Line Height | Letter Spacing |
|---------|------|------|--------|-------------|----------------|
| Hero Name | Editorial New | 72px / 4.5rem | 400 | 1.1 | -0.02em |
| Room Titles | Editorial New | 48px / 3rem | 400 | 1.2 | -0.01em |
| Section Labels | Space Grotesk | 14px / 0.875rem | 500 | 1.4 | 0.1em (uppercase) |
| Body Large | Space Grotesk | 20px / 1.25rem | 400 | 1.6 | 0 |
| Body | Space Grotesk | 16px / 1rem | 400 | 1.6 | 0 |
| Stats Number | Editorial New | 64px / 4rem | 300 | 1 | -0.02em |
| Stats Label | Space Grotesk | 12px / 0.75rem | 500 | 1.4 | 0.05em (uppercase) |
| Pillar Title | Space Grotesk | 18px / 1.125rem | 600 | 1.3 | 0 |
| Pillar Desc | Space Grotesk | 14px / 0.875rem | 400 | 1.5 | 0 |
| Principle Quote | Editorial New | 28px / 1.75rem | 400 | 1.4 | 0 |
| CTA Text | Editorial New | 36px / 2.25rem | 400 | 1.2 | 0 |
| Email | Space Grotesk | 20px / 1.25rem | 500 | 1.4 | 0.02em |

### Responsive Typography

```css
/* Tablet */
@media (max-width: 1024px) {
  --hero-name: 56px;
  --room-title: 40px;
  --stat-number: 48px;
}

/* Mobile */
@media (max-width: 640px) {
  --hero-name: 40px;
  --room-title: 32px;
  --stat-number: 36px;
  --principle-quote: 22px;
  --cta-text: 28px;
}
```

---

## 5. Spacing System

### Base Unit: 8px

```css
--space-1: 8px;
--space-2: 16px;
--space-3: 24px;
--space-4: 32px;
--space-5: 48px;
--space-6: 64px;
--space-7: 96px;
--space-8: 128px;
```

### Room Padding

```css
/* Desktop */
.room {
  padding: var(--space-6) var(--space-7); /* 64px 96px */
}

/* Tablet */
@media (max-width: 1024px) {
  .room {
    padding: var(--space-5) var(--space-6); /* 48px 64px */
  }
}

/* Mobile */
@media (max-width: 640px) {
  .room {
    padding: var(--space-4) var(--space-3); /* 32px 24px */
  }
}
```

### Component Spacing

| Element | Margin/Padding |
|---------|----------------|
| Room title to content | var(--space-5) / 48px |
| Between pillar cards | var(--space-4) / 32px |
| Between project cards | var(--space-3) / 24px |
| Between principle cards | var(--space-3) / 24px |
| Stat number to label | var(--space-1) / 8px |
| Between stats | var(--space-5) / 48px |
| Social icon spacing | var(--space-3) / 24px |

### Breathing Room

- **Minimum touch target:** 44px × 44px
- **Card internal padding:** var(--space-4) / 32px
- **Text max-width:** 65ch (readability)
- **Content max-width:** 1200px (contained rooms)

---

## 6. Mobile Adaptation

### Breakpoints

```css
--bp-desktop: 1280px;
--bp-laptop: 1024px;
--bp-tablet: 768px;
--bp-mobile: 640px;
```

### Room-by-Room Mobile Stacking

#### Room 1: Hero
- **Desktop:** Centered, large name
- **Mobile:** Same layout, reduced type size
- **Adjustment:** Scroll indicator more prominent (mobile users need cue)

#### Room 2: Pillars
```
Desktop:        Mobile:
┌──┬──┬──┐      ┌────┐
│ 1│ 2│ 3│      │ 1  │
└──┴──┴──┘      ├────┤
                │ 2  │
                ├────┤
                │ 3  │
                └────┘
```
- Stack vertically on mobile
- Full-width cards
- Maintain texture thumbnails (smaller)

#### Room 3: The Arc
```
Desktop:        Mobile:
┌────┬────┐     ┌────┐
│tex │txt │     │txt │ (texture becomes
│    │    │     ├────┤  background)
└────┴────┘     │cta │
                └────┘
```
- Texture becomes full-bleed background
- Text overlays with scrim (dark gradient)
- Narrative text shortened or scrollable

#### Room 4: Impact
```
Desktop:        Mobile:
Stats row       Stats 2×2 grid
Cards side      Cards stack
                (full width)
```
- Stats: 2×2 grid on mobile
- Project cards: full width, stacked
- Texture thumbnails: left side, smaller

#### Room 5: Principles
```
Desktop:        Mobile:
Vertical stack  Vertical stack
(full cards)    (compact cards)
```
- Same structure, tighter spacing
- Text overlay on texture (always)
- Reduced quote font size

#### Room 6: Contact
- **Desktop:** Centered, spacious
- **Mobile:** Same, email wraps if needed
- **Social icons:** larger touch targets (48px)

### Mobile-Specific Behaviors

```css
/* Swipe hint on first visit */
.swipe-hint {
  display: none;
}

@media (pointer: coarse) {
  .swipe-hint {
    display: block;
    animation: fade-out 3s forwards;
  }
}

/* Larger touch targets */
@media (pointer: coarse) {
  .pillar-card,
  .project-card,
  .principle-card {
    min-height: 120px;
  }
  
  .social-icon {
    width: 48px;
    height: 48px;
  }
}
```

---

## 7. Texture Placement

### Macro Image Strategy

**Rule:** Every room has texture. No empty white space.

### Texture Map

| Room | Texture Type | Placement | Treatment |
|------|--------------|-----------|-----------|
| **1. Hero** | Weathered wood, aged metal, or stone | Full-bleed background | Dark overlay (rgba(26,27,58,0.4)) for text contrast |
| **2. Pillars** | Government: sandstone/concrete; Web3: circuit/metal; Philosophy: ink/paper | Card backgrounds, 30% of card area | Subtle, desaturated, overlaid with color tint |
| **3. The Arc** | Flowing water, sand dunes, or fabric | Left 50% (desktop), full-bleed (mobile) | Gradient fade to content area |
| **4. Impact** | SAM.gov: paper texture; FPDS: fiber optic; Hackathon: circuit board | Card thumbnails, left-aligned | Small crop (80×80px), macro detail |
| **5. Principles** | Life: hands/clay; Intentions: compass; Curiosity: shell; Peace: still water | Full card backgrounds | Heavy overlay (rgba(26,27,58,0.6)), text on top |
| **6. Contact** | Open doorway, horizon, or light rays | Full-bleed background | Light overlay (rgba(245,245,240,0.1)) |

### Texture Specifications

```css
/* Standard texture treatment */
.texture-bg {
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
}

/* Dark overlay for text readability */
.texture-overlay-dark {
  background: linear-gradient(
    rgba(26, 27, 58, 0.7),
    rgba(26, 27, 58, 0.5)
  );
}

/* Light overlay */
.texture-overlay-light {
  background: linear-gradient(
    rgba(245, 245, 240, 0.1),
    rgba(245, 245, 240, 0.05)
  );
}

/* Card texture (small) */
.card-texture {
  width: 80px;
  height: 80px;
  border-radius: 4px;
  object-fit: cover;
  filter: saturate(0.8) contrast(1.1);
}
```

### Texture Sources

**Recommended approach:**
1. **Unsplash** (free): search "macro texture [material]"
2. **Pexels** (free): similar macro texture searches
3. **Original photography:** Vash to capture personal textures

**Required textures list:**
- [ ] Weathered wood grain
- [ ] Sandstone/concrete surface
- [ ] Circuit board macro
- [ ] Ink on paper
- [ ] Flowing water or sand
- [ ] Paper texture (aged)
- [ ] Fiber optic strands
- [ ] Hands holding clay
- [ ] Compass detail
- [ ] Spiral shell
- [ ] Still water surface
- [ ] Open doorway with light

### Performance

```css
/* Lazy load textures */
.texture-bg {
  background-image: none;
}

.texture-bg[data-loaded="true"] {
  background-image: url('...');
}

/* Preload next room's texture */
const preloadTexture = (url) => {
  const img = new Image();
  img.src = url;
};
```

---

## 8. Color Application

### Palette: Dawn at the Ghat

```css
--sandstone: #D4A574;    /* Primary accent, hover states */
--indigo: #1A1B3A;       /* Primary background, text on light */
--saffron: #FF9933;      /* CTA, highlights, active states */
--marble: #F5F5F0;       /* Text on dark, secondary background */
```

### Usage Map

| Element | Color | Usage |
|---------|-------|-------|
| Page background | --indigo | All rooms |
| Primary text | --marble | Body, headings on dark |
| Accent text | --sandstone | Highlights, quotes |
| CTA elements | --saffron | Buttons, links, active states |
| Card backgrounds | --indigo (lightened 5%) | Subtle separation |
| Borders | --sandstone (30% opacity) | Dividers, outlines |

---

## 9. Implementation Checklist

### Phase 1: Structure
- [ ] HTML skeleton with 6 rooms
- [ ] CSS scroll-snap implementation
- [ ] Viewport-height room containers

### Phase 2: Visual
- [ ] Typography loaded (Editorial New, Space Grotesk)
- [ ] Color variables applied
- [ ] Texture images sourced and optimized

### Phase 3: Animation
- [ ] Intersection Observer for entry triggers
- [ ] CSS animations for each room
- [ ] Reduced motion support

### Phase 4: Responsive
- [ ] Mobile stacking layouts
- [ ] Touch-friendly interactions
- [ ] Performance optimization

### Phase 5: Polish
- [ ] Cross-browser testing
- [ ] Accessibility audit
- [ ] Performance audit (Lighthouse)

---

## 10. File Structure

```
/workspace/projects/vashist-rebrand/
├── ux-spec.md              (this file)
├── design-system.md        (colors, typography, components)
├── assets/
│   └── textures/
│       ├── hero-wood.jpg
│       ├── pillar-gov.jpg
│       ├── pillar-web3.jpg
│       ├── pillar-philosophy.jpg
│       ├── arc-water.jpg
│       ├── impact-paper.jpg
│       ├── impact-fiber.jpg
│       ├── impact-circuit.jpg
│       ├── principle-clay.jpg
│       ├── principle-compass.jpg
│       ├── principle-shell.jpg
│       ├── principle-water.jpg
│       └── contact-doorway.jpg
└── implementation/
    ├── index.html
    ├── css/
    │   ├── main.css
    │   ├── rooms.css
    │   └── animations.css
    └── js/
        └── gallery.js
```

---

**Next Steps:**
1. @design — Create visual mockups from these specs
2. @dev — Begin HTML/CSS structure
3. @content — Finalize text for each room
4. @assets — Source and optimize texture images

**Deadline:** 2026-05-24 (TODAY)
