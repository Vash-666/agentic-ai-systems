# UX Design Brief: Vash1st.com 2026
## Step 6/9 — Complete Design Specifications

**Date:** 2026-05-26  
**Status:** Design Complete — Ready for Build

---

## Global Design System

### Typography

| Element | Font | Size | Weight | Line Height | Letter Spacing |
|---------|------|------|--------|-------------|----------------|
| Hero Name | Cormorant Garamond | 120px | 300 (Light) | 1.0 | -0.02em |
| Section Title | Cormorant Garamond | 72px | 400 | 1.1 | -0.01em |
| Body Large | Inter | 24px | 300 | 1.6 | 0 |
| Body | Inter | 18px | 400 | 1.7 | 0 |
| Caption | Inter | 14px | 500 | 1.5 | 0.05em |
| CTA | Inter | 16px | 500 | 1.0 | 0.1em |

### Color System

```css
:root {
  /* Base */
  --bg-primary: #0A0A0B;
  --bg-elevated: #141415;
  --text-primary: #FAFAF9;
  --text-secondary: #A1A1AA;
  --border: #262626;
  
  /* Accents */
  --accent-gold: #C9A84C;
  --accent-indigo: #4F46E5;
  --accent-teal: #14B8A6;
  --accent-sky: #0EA5E9;
  --accent-amber: #D97706;
  
  /* Gradients */
  --gradient-hero: radial-gradient(ellipse at 50% 0%, rgba(201,168,76,0.15) 0%, transparent 50%);
  --gradient-builder: radial-gradient(ellipse at 50% 0%, rgba(79,70,229,0.12) 0%, transparent 50%);
  --gradient-seeker: radial-gradient(ellipse at 50% 0%, rgba(20,184,166,0.12) 0%, transparent 50%);
  --gradient-pilot: radial-gradient(ellipse at 50% 0%, rgba(14,165,233,0.12) 0%, transparent 50%);
  --gradient-investor: radial-gradient(ellipse at 50% 0%, rgba(217,119,6,0.12) 0%, transparent 50%);
}
```

### Spacing System

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Micro adjustments |
| sm | 8px | Tight spacing |
| md | 16px | Default padding |
| lg | 32px | Section padding |
| xl | 64px | Large gaps |
| 2xl | 128px | Section margins |
| 3xl | 192px | Major section breaks |

### Animation Timing

```css
:root {
  --ease-out-expo: cubic-bezier(0.16, 1, 0.3, 1);
  --ease-in-out-sine: cubic-bezier(0.37, 0, 0.63, 1);
  --duration-fast: 300ms;
  --duration-normal: 600ms;
  --duration-slow: 1000ms;
  --duration-dramatic: 1500ms;
}
```

---

## Section 1: HERO

### Layout
- **Height:** 100vh (full viewport)
- **Structure:** Centered content, vertical flex
- **Z-index:** Base layer (0)

### Visual Elements

**Background:**
- Base: `--bg-primary`
- Gradient overlay: `--gradient-hero` (subtle gold glow from top)
- Texture: 2% opacity noise grain (SVG filter)

**AI Reactive Element:**
- Type: Canvas-based neural orb
- Position: Center, behind text (z-index: -1)
- Behavior: 
  - Gentle pulse (4s cycle, sine wave)
  - Mouse proximity: Subtle attraction (max 20px movement)
  - Scroll: Fades and shrinks as user scrolls down
- Colors: Gold (#C9A84C) at 30% opacity, connected nodes

**Scroll Indicator:**
- Position: Bottom center, 64px from bottom
- Element: Animated line (vertical, 40px)
- Animation: Continuous bounce (1.5s cycle)
- Text: "Scroll" in caption style, below line

### Content

```
[AI Orb — Centered, Behind]

Vash
Builder. Seeker.

[I built things in the future.]

[Scroll Indicator]
```

### Animations

**Page Load Sequence:**
1. Background gradient fades in (0-500ms)
2. AI orb materializes (300-1000ms, scale 0.8→1, opacity 0→0.3)
3. "Vash" appears (800-1400ms, y: 30→0, opacity)
4. "Builder. Seeker." appears (1200-1800ms)
5. Bracket text fades in (1600-2200ms)
6. Scroll indicator appears (2000-2500ms)

**Scroll Behavior:**
- Hero content parallax: 0.3x scroll speed
- AI orb: Scales down to 0.5, fades to 0.1
- Complete fade out by 50vh scrolled

---

## Section 2: THE BUILDER

### Layout
- **Height:** Min 100vh
- **Structure:** Asymmetric two-column (40/60 split)
- **Left:** Icon + Title
- **Right:** Body copy, stacked paragraphs

### Visual Elements

**Background:**
- Base: `--bg-primary`
- Gradient: `--gradient-builder` (indigo from top)
- Left edge: Subtle vertical line (1px, indigo at 20% opacity)

**Primordial Icon:**
- Type: SVG — Branching tree/neural pattern
- Position: Left column, top
- Size: 120px × 120px
- Color: `--accent-indigo` at 60% opacity
- Animation: Gentle rotation (120s full cycle, continuous)
- Stroke: 1.5px, rounded caps

**Section Indicator:**
- Position: Left edge, vertically centered
- Element: "01" in caption style, rotated -90deg
- Color: `--text-secondary` at 40% opacity

### Content

```
[Left Column]

[Tree/Neural Icon — 120px]

The Builder

[Right Column]

Systems are my language.

I build where code meets governance —
tokenization protocols, NLP engines,
AI that shapes how societies function.

A decade in emerging tech
teaches you pattern recognition.
You learn to spot what's real
before the hype arrives.

Certified Ethereum Expert.
Federal AI modernization.
Startups that raised, scaled,
and sometimes failed.

Every system is a bet on the future.
```

### Animations

**Scroll Into View:**
1. Section indicator fades in (0-400ms)
2. Icon draws in (SVG stroke animation, 0-1200ms)
3. "The Builder" slides up (300-900ms)
4. Paragraphs stagger in (600ms each, 200ms stagger)

**Continuous:**
- Icon: Ultra-slow rotation (imperceptible daily movement)

---

## Section 3: THE SEEKER

### Layout
- **Height:** Min 100vh
- **Structure:** Centered, narrow column (max-width: 640px)
- **Alignment:** Center text

### Visual Elements

**Background:**
- Base: `--bg-primary`
- Gradient: `--gradient-seeker` (teal from top)
- Texture: Subtle concentric circles (SVG, 5% opacity, emanating from center)

**Primordial Icon:**
- Type: SVG — Spiral/labyrinth
- Position: Above title, centered
- Size: 100px × 100px
- Color: `--accent-teal` at 50% opacity
- Animation: Slow clockwise rotation (60s cycle)

**Section Indicator:**
- Position: Right edge, vertically centered
- Element: "02" rotated 90deg

### Content

```
[Centered Column]

[Spiral Icon — 100px]

The Seeker

But systems without wisdom
are just noise.

I walk the line where ancient East
meets modern West —
questions of life, meaning, soul.
The psychology of transformation.

At inflection points,
founders and executives come to me.
Not for answers.
For the right questions.

External success without internal clarity
is hollow.
```

### Animations

**Scroll Into View:**
1. Spiral icon scales up (0.8→1) and fades in
2. Title appears with blur-in effect
3. Each paragraph fades in with y-translate (staggered)
4. Last line has slight delay for emphasis

**Special Effect:**
- On scroll, concentric circles subtly expand (parallax 0.1x)

---

## Section 4: THE PILOT

### Layout
- **Height:** Min 100vh
- **Structure:** Full-width, content left-aligned but with generous left padding (20%)
- **Feeling:** Open, airy, horizon-like

### Visual Elements

**Background:**
- Base: `--bg-primary`
- Gradient: `--gradient-pilot` (sky blue from top-left)
- Visual: Subtle horizon line (1px, 30% from bottom, sky blue at 10%)

**Primordial Icon:**
- Type: SVG — Stylized wings
- Position: Left, aligned with title
- Size: 80px × 80px
- Color: `--accent-sky` at 60% opacity
- Animation: Gentle flap (subtle scale Y, 3s cycle)

**Section Indicator:**
- Position: Left edge, bottom third
- Element: "03"

### Content

```
[Left-Aligned, 20% Padding]

[Wings Icon — 80px]

The Pilot

The sky teaches what no classroom can.

Instrument-rated private pilot.
Hours of preparation
for moments of presence.

Above the clouds,
there is no room for ego.
Only humility, precision,
and the vast quiet
that puts everything in perspective.

What you learn at 10,000 feet
changes how you walk on earth.
```

### Animations

**Scroll Into View:**
1. Horizon line draws from left to right (0-1500ms)
2. Wings icon fades in with gentle "landing" motion (y: -20→0)
3. Title appears
4. Paragraphs cascade in with increasing delay

**Continuous:**
- Wings: Subtle breathing motion (scale 1→1.02→1)

---

## Section 5: THE INVESTOR

### Layout
- **Height:** Min 100vh
- **Structure:** Right-aligned content (text-align: right, 60% width)
- **Feeling:** Grounded, patient, timeless

### Visual Elements

**Background:**
- Base: `--bg-primary`
- Gradient: `--gradient-investor` (amber from bottom-right)
- Texture: Subtle grid pattern (very faint, suggests charts/graphs without being literal)

**Primordial Icon:**
- Type: SVG — Ouroboros (circle/snake eating tail)
- Position: Right, aligned with title
- Size: 100px × 100px
- Color: `--accent-amber` at 50% opacity
- Animation: Slow rotation (90s cycle)

**Section Indicator:**
- Position: Right edge, top third
- Element: "04" rotated 90deg

### Content

```
[Right-Aligned, 60% Width]

[Ouroboros Icon — 100px]

The Investor

Patient capital in a world of noise.

I invest in blockchain, AI,
transformative technologies —
not for quarterly returns,
but for decades of compound wisdom.

The best returns come
to those who wait.
Who prepare. Who see patterns
others miss in the chaos.

Long-term thinking
is the ultimate edge.
```

### Animations

**Scroll Into View:**
1. Ouroboros draws itself (SVG stroke animation, circular)
2. Title fades in from right
3. Paragraphs stagger in from right

**Continuous:**
- Ouroboros: Eternal rotation (symbolizes cycles, patience)

---

## Section 6: CLOSING / CTA

### Layout
- **Height:** 60vh (shorter, intentional brevity)
- **Structure:** Centered, minimal
- **Feeling:** Quiet invitation, no pressure

### Visual Elements

**Background:**
- Base: `--bg-primary`
- No gradient (return to pure dark)
- Subtle: Single gold orb (30px) at center-top, 10% opacity (echo of hero)

### Content

```
[Centered]

If something here resonated,

rohit.vashist@live.com

That's the only signal I need.
```

### Animations

**Scroll Into View:**
1. Text fades in gently
2. Email address has subtle gold underline that draws in
3. Final line appears with slight delay

**Interaction:**
- Email: Hover reveals copy icon
- Click: mailto: link

---

## Technical Specifications

### Component Library

```typescript
// Section wrapper
interface SectionProps {
  id: string;
  accent: 'gold' | 'indigo' | 'teal' | 'sky' | 'amber';
  children: React.ReactNode;
}

// Animated text
interface TextRevealProps {
  children: string;
  delay?: number;
  as?: 'h1' | 'h2' | 'p';
}

// Primordial icon
interface IconProps {
  type: 'tree' | 'spiral' | 'wings' | 'ouroboros';
  size: number;
  color: string;
  animate?: boolean;
}

// AI Orb (Canvas)
interface NeuralOrbProps {
  mousePosition: { x: number; y: number };
  scrollProgress: number;
}
```

### Animation Hooks

```typescript
// useScrollProgress — returns 0-1 for section visibility
// useMousePosition — returns normalized x,y
// useInView — triggers when element enters viewport
// useParallax — returns transform based on scroll
```

### Performance Targets

- First Contentful Paint: < 1.5s
- Largest Contentful Paint: < 2.5s
- Cumulative Layout Shift: < 0.1
- Animation frame rate: 60fps
- Total bundle: < 200kb (gzipped)

### Accessibility

- Reduced motion: Respect `prefers-reduced-motion`
- Color contrast: All text meets WCAG AAA
- Focus states: Visible, gold outline
- Screen reader: Semantic HTML, aria-labels

---

## Quality Checklist

- [ ] Typography renders perfectly across devices
- [ ] Animations are smooth (60fps)
- [ ] Color transitions feel cohesive
- [ ] Icons are recognizable at all sizes
- [ ] Voice is consistent throughout
- [ ] No visual clutter
- [ ] Mobile experience is immersive
- [ ] Load time is fast
- [ ] Accessibility is complete

---

**Design Brief Complete**  
**Ready for:** Step 7/9 — Scaffold/Build  
**Estimated Build Time:** 3-4 days
