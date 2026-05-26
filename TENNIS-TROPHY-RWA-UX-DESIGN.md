# 🏆 1947 Ladies Doubles Championship Shield — UX Design & User Research

**Project:** Real-World Asset Tokenization Website  
**Target:** 2026 Production Frontend Overhaul  
**Status:** Complete — Ready for @scaffolder  
**Date:** May 19, 2026

---

## Table of Contents

1. [User Research Summary](#1-user-research-summary---2026-rwa-nft-market)
2. [Buyer Personas](#2-buyer-personas)
3. [Site Map / Information Architecture](#3-site-map--information-architecture)
4. [Detailed Page Designs & Interactions](#4-detailed-page-designs--interactions)
5. [Interactive Winner-Trophy Mapping Specification](#5-interactive-winner-trophy-mapping-specification)
6. [Content Strategy & Page Copy Outline](#6-content-strategy--page-copy-outline)
7. [Design System Recommendations](#7-design-system-recommendations)
8. [Implementation Handoff Notes](#8-implementation-handoff-notes)

---

## 1. User Research Summary — 2026 RWA NFT Market

### 1.1 Market Context

The NFT market has undergone a **"Great Reset"** since the 2021-2022 speculative peak. By 2026, the market is fundamentally different:

| Metric | Value |
|--------|-------|
| Global NFT Market Volume (2024) | ~$8.9B organic |
| Unique Buyers (peak 2024) | ~7.6M |
| RWA Tokenized Asset Projection (BCG 2030) | $16T |
| Avg. NFT Sale Price | ~$100 (down from $421 peak) |
| Physical/Phygital Asset CAGR | **34.28%** |
| Collectors Segment Market Share | 43.3% |
| RWA token creation on Solana | 25% of all tokens by 2026 |

**Key shift:** The market transformed from *high-value, low-participation* speculative trading to *accessible, utility-driven* ownership of real assets.

### 1.2 Who Buys Tokenized Real-World Assets in 2026?

**By segment:**

| Segment | Share | Profile |
|---------|-------|---------|
| **Institutional Collectors / HNWIs** | ~35% | Portfolio diversification, blue-chip physical assets |
| **Web3-Native Collectors** | ~30% | Gen Z/Millennial, already hold crypto, want tangible assets |
| **Mainstream "Phygital" Buyers** | ~20% | New to crypto, value tangible backing, high trust threshold |
| **Speculative/Investment** | ~15% | Seeking fractional ownership of high-value assets |

**By geography:**

| Region | Market Share | Key Characteristics |
|--------|-------------|---------------------|
| Asia-Pacific | 35% | Mobile-first, P2E background, highest NFT adoption rates |
| North America | ~25% | Fastest-growing CAGR (34.84%), tech-savvy, regulatory clarity |
| Europe | ~20% | Compliance-conscious, luxury interest, slower adoption |
| Emerging Markets | ~20% | Financial inclusion, alternative assets, remittance use |

### 1.3 What Motivates RWA Buyers?

| Motivation | Weight | Notes |
|-----------|--------|-------|
| **Historical significance / provenance** | 🏆 **Primary** | The story IS the value for trophy/memorabilia |
| **Collectibility / uniqueness** | 🏆 **Primary** | One-of-a-kind assets command premium |
| **Investment / appreciation** | ✅ **Strong** | But secondary to story for collectibles |
| **Fractional access** | ✅ **Strong** | Opens ownership to non-HNWIs |
| **Portfolio diversification** | 🔶 Moderate | More relevant for institutional buyers |
| **Social status / signaling** | 🔶 Moderate | Less than peak NFT era, but still relevant |

### 1.4 Key Buyer Concerns (2026)

| Concern | Importance | How to Address |
|---------|-----------|----------------|
| **Authenticity & Provenance** | 🔴 Critical | On-chain verification + independent appraisal docs |
| **Physical Custody** | 🔴 Critical | Clear custodian info, insurance, audit trail |
| **Liquidity** | 🟡 Important | Secondary market plan, buyback options |
| **Legal Validity** | 🟡 Important | Smart contract linked to legal ownership document |
| **Asset Condition** | 🟡 Important | Recent photos, condition reports, material specs |
| **Counterfeit Risk** | 🟢 Moderate | Blockchain immutability + serial numbers |
| **Fraud / Scams** | 🟢 Moderate | KYC platform, reputable marketplace |

### 1.5 Platforms Used by RWA Buyers in 2026

| Platform | Type | Relevance |
|----------|------|-----------|
| **OpenSea** | General NFT | High — still dominant discovery channel |
| **ARKHIVE / rwa.io** | Specialized RWA | High — growing niche marketplaces |
| **Fractional / Syndicate** | Fractional ownership | Medium — if trophy is fractionally owned |
| **Custom dApps** | Project-specific | **This is us** — dedicated site drives trust |
| **Blur / X2Y2** | Trading-focused | Low — better for speculative, not RWA |

> **Key insight for our design:** Most RWA buyers *discover* on OpenSea but *purchase* through dedicated project sites where trust is established. Our website needs to be the trust anchor.
>
> **Key insight about trophy RWA specifically:** Unlike generic RWA (real estate, gold), a **trophy's value is its story**. The 1947 origin, 77+ years of winners, the physical artifact — these are the purchase drivers. The UX should feel like exploring a museum exhibit, not a DeFi dashboard.

### 1.6 Demographic Profile of an RWA Trophy Buyer

| Attribute | Profile |
|-----------|---------|
| Age | 30–55 (sweet spot: 38–50) |
| Net Worth | $200K–$5M (upper-middle / HNWI) |
| Crypto Experience | Mixed: 40% crypto-native, 60% newcomers attracted by the asset |
| Tennis Interest | High — likely a tennis fan, collector, or historian |
| Decision Style | Deliberate, research-heavy, trust-sensitive |
| Tech Comfort | Moderate+ — can handle MetaMask but won't tolerate friction |

---

## 2. Buyer Personas

### Persona 1: "The Tennis Historian" — Eleanor (48)

```
┌─────────────────────────────────────────────────────────┐
│  "I don't care about crypto. I care about preserving    │
│   tennis history. This trophy belongs in the story."    │
└─────────────────────────────────────────────────────────┘
```

| Attribute | Detail |
|-----------|--------|
| **Background** | Retired tennis coach, now consultant. Upper-middle class. Has a small collection of vintage tennis memorabilia. |
| **Location** | London, UK |
| **Annual Income** | £120K |
| **Crypto Experience** | **Beginner** — has heard of NFTs, doesn't own any. Uses a bank. |
| **Motivation** | Preservation of sports history. Emotional connection to the 1947 tournament era. Knows several of the names engraved. |
| **Investment Goals** | Holds collectibles long-term (5-10 years). Not looking to flip. Wants to be the "steward" of the trophy. |
| **Pain Points** | Confused by wallets, gas fees, "connect wallet" buttons. Distrusts crypto due to scam stories. Needs hand-holding. |
| **Discovery Path** | Tennis history blog → saw the trophy mentioned → search → our site |
| **How to Convert** | Clear "what is this" explanation. Trust signals (legal docs, insurance). Low-friction wallet onboarding. Email me if I get stuck. |
| **Objections** | "Is this a scam?" "What happens if the platform goes away?" "How do I know the real trophy exists?" |

**Design implications:** Needs a prominent "New to RWA?" / "How it works" section. Jargon must be explained or avoided. Trussst signals everywhere. Prefer fiat-on-ramp over requiring existing crypto.

---

### Persona 2: "The Crypto Collector" — Marcus (34)

```
┌─────────────────────────────────────────────────────────┐
│  "I've been in NFTs since 2021. This is actually real — │
│   physical assets with provenance. That's the next wave."│
└─────────────────────────────────────────────────────────┘
```

| Attribute | Detail |
|--------|--------|
| **Background** | Software engineer turned crypto investor. Built a decent portfolio in the bull runs. Now diversifying into RWA. |
| **Location** | Austin, TX, USA |
| **Annual Income** | $250K from crypto + consulting |
| **Crypto Experience** | **Advanced** — DeFi, NFTs, cross-chain. Owns hardware wallets. |
| **Motivation** | First-mover advantage in RWA. Sees historical trophies as undervalued. Wants to display in his home office. |
| **Investment Goals** | Medium-to-long hold. Will sell if price appreciates significantly. May fractionalize later. |
| **Pain Points** | Few quality RWA projects exist. Most are scams or poorly executed. Needs verifiable on-chain provenance. |
| **Discovery Path** | OpenSea new collection → rwa.io newsletter → direct search |
| **How to Convert** | Show me the smart contract. Etherscan link. On-chain winner data. Wallet-native experience. Fast transaction with low gas. |
| **Objections** | "Is this legally enforceable?" "What's the custody arrangement?" "Can I verify the physical asset myself?" |

**Design implications:** Wants the full technical spec. Needs Etherscan links, contract verification, custody audit trail. Power-user features: quick buy, gas-optimized, wallet-aware flows.

---

### Persona 3: "The Tennis-Investor Dad" — Raj (42)

```
┌─────────────────────────────────────────────────────────┐
│  "I love tennis, I have some ETH, and this feels like a │
│   conversation piece that might actually hold value."    │
└─────────────────────────────────────────────────────────┘
```

| Attribute | Detail |
|--------|--------|
| **Background** | VP-level in finance/tech. Played college tennis. Upper-income professional. |
| **Location** | Mumbai, India (works remote for US firm) |
| **Annual Income** | $180K |
| **Crypto Experience** | **Intermediate** — holds some ETH/BTC, has used MetaMask, bought an NFT once. |
| **Motivation** | Tangible asset + tennis passion. Good story for his home bar. "My friends will ask about this." |
| **Investment Goals** | 3-7 year hold. Would consider selling for right price. Sees as alternative asset allocation. |
| **Pain Points** | Has been burned by a rug pull before. Wants due diligence evidence. Time-poor — needs quick decisions. |
| **Discovery Path** | Tennis forum → Reddit r/tennis → Google search "tennis trophy NFT" |
| **How to Convert** | Price clarity. Trust badges. Quick checkout. Mobile-friendly. |
| **Objections** | "Is this a good deal?" "How does this compare to buying vintage memorabilia?" "Can I resell?" |

**Design implications:** Comparison-friendly design. Price history. Clear call-to-action. Mobile-responsive is critical. Needs "compare to traditional collectible" section.

---

### Persona 4: "The Institutional Steward" — Patricia (56)

```
┌─────────────────────────────────────────────────────────┐
│  "This trophy belongs in a museum. We'd like to explore │
│   acquiring it for our tennis hall of fame."            │
└─────────────────────────────────────────────────────────┘
```

| Attribute | Detail |
|--------|--------|
| **Background** | Curator/acquisitions director at a tennis museum or sports memorabilia institution. |
| **Location** | Newport, RI / Wimbledon, UK |
| **Organization** | Non-profit museum, sports hall of fame, or university athletic department |
| **Crypto Experience** | **Low** — her legal team handles blockchain. She cares about the object. |
| **Motivation** | Acquire the actual physical trophy for display. Or acquire NFT + loan arrangement for physical. |
| **Investment Goals** | Permanent collection acquisition, not investment. |
| **Pain Points** | Legal complexity of NFT ownership for non-profits. Custody logistics. Insurance. Charity/gift tax implications. |
| **Discovery Path** | Tennis historian network → museum newsletter → direct inquiry |
| **How to Convert** | Direct contact form. "Request institutional inquiry" button. PDF prospectus download. |
| **Objections** | "How does NFT ownership work with museum insurance?" "Can we display the physical trophy?" "Tax implications?" |

**Design implications:** Needs an "Institutional Inquiries" section. Downloadable PDF with legal/insurance details. Direct contact form (not just wallet-only). Physical display arrangement options.

---

## 3. Site Map / Information Architecture

### 3.1 Structure

```
🏠 HOME (index)
  ├─ Hero: Trophy visual + tagline
  ├─ "Tokenization" Explained (1-min read)
  ├─ Why This Trophy Matters (history highlight)
  ├─ How It Works (3-step process)
  ├─ Trust Signals (custody, legal, authentication)
  └─ CTAs: View Trophy → Gallery | Learn More → About

🖼️ GALLERY (gallery/)
  ├─ Trophy Card Grid
  │   ├─ Trophy image
  │   ├─ Name + year
  │   ├─ Price / "Make Offer"
  │   └─ Quick stats (winners, material)
  ├─ Filters: Year, Material, Price Range
  ├─ Sort: Recent, Price (low/high), Historical Significance
  └─ Empty State / Loading / Pagination

🏆 TROPHY DETAIL (trophy/[id])
  ├─ Large Trophy Image (with interactive annotation)
  ├─ ⭐ Interactive Winner Selection
  ├─ Winner Timeline (visual timeline, 1947-present)
  ├─ Trophy Specs (material, dimensions, condition, weight)
  ├─ Ownership & Provenance
  │   ├─ Current owner
  │   ├─ Transfer history (timeline)
  │   └─ Etherscan links
  ├─ Custodian Info
  │   ├─ Current physical location
  │   ├─ Storage facility type
  │   └─ Insurance details
  ├─ Buy Now / Make Offer CTA
  ├─ Institutional Inquiry (if applicable)
  └─ Share / Bookmark

📖 ABOUT & PROCESS (about/)
  ├─ What is a Physical-Backed NFT?
  ├─ How Custody Works
  ├─ Legal Framework
  ├─ Authentication Process
  ├─ Risks & Disclaimers
  └─ FAQ

❓ FAQ (faq/)
  ├─ For Buyers (general)
  ├─ For Crypto-Natives (technical)
  ├─ For Institutions (legal/custody)
  └─ For Sellers (future feature)

📞 CONTACT (contact/)
  ├─ General Inquiries
  ├─ Institutional Inquiries
  └─ Support / Troubleshooting

📝 BLOG / NEWS (blog/) — stretch goal
  ├─ Trophy history articles
  ├─ Tokenization explainers
  └─ Market updates
```

### 3.2 Navigation

```
┌──────────────────────────────────────────────────────────┐
│  [🏆 LOGO]  Gallery  About  FAQ  Contact  [🔗 Connect] │
│                         [🔍 Search]                      │
└──────────────────────────────────────────────────────────┘
```

**Mobile nav:** Hamburger with slide-out drawer. Bottom tab bar with: Home, Gallery, About, Wallet.

---

## 4. Detailed Page Designs & Interactions

### 4.1 Homepage

#### Layout (Desktop)

```
┌──────────────────────────────────────────────────────────────┐
│ [Nav: Trophy Logo | Gallery | About | FAQ | [Connect Wallet]]│
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────┐  ┌──────────────────────────────┐  │
│  │                     │  │  Own a Piece of Tennis History │  │
│  │                     │  │                                │  │
│  │   TROPHY HERO IMAGE │  │  The 1947 Ladies Doubles      │  │
│  │   (large, dramatic,│  │  Championship Shield — one of   │  │
│  │    studio lighting) │  │  tennis's most historic trophies│  │
│  │                     │  │  tokenized on Ethereum.        │  │
│  │                     │  │                                │  │
│  │                     │  │  [View the Trophy →]           │  │
│  └─────────────────────┘  │  [How It Works ↓]              │  │
│                            └──────────────────────────────┘  │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│  "What is RWA Tokenization?"  (simple 2-line explanation)    │
│                                                              │
│  A Real-World Asset (RWA) NFT is a digital certificate       │
│  that proves ownership of a physical item — in this case,    │
│  a historic tennis trophy. The NFT lives on the Ethereum     │
│  blockchain. The trophy lives in a secure, insured vault.    │
│  Own the NFT, own the trophy.                                │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Why This Trophy Matters                                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            │
│  │  Since 1947  │ │  77 Seasons  │ │ Championship │            │
│  │  A post-war  │ │  Of winners  │ │ Legacy of    │            │
│  │  tennis      │ │  engraved on │ │ top-tier      │            │
│  │  tradition   │ │  the shield  │ │ competition   │            │
│  └─────────────┘ └─────────────┘ └─────────────┘            │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  How It Works (3 Steps)                                      │
│                                                              │
│  ┌──────────┐     ┌──────────┐     ┌──────────┐             │
│  │  Step 1  │ →   │  Step 2  │ →   │  Step 3  │             │
│  │  Connect │     │  Acquire │     │  Own the │             │
│  │  Wallet  │     │  Trophy  │     │  History │             │
│  └──────────┘     └──────────┘     └──────────┘             │
│                                                              │
│  1. Connect your Ethereum wallet (MetaMask, WalletConnect)   │
│  2. Purchase the trophy NFT (ETH on any L2/Ethereum)        │
│  3. The NFT is transferred to you. Trophy stays vaulted.    │
│     You can visit it, display it, or sell it.               │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Trust Signals                                               │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ 🔒 Secure│ │ 📜 Legal │ │ ✅ Audit │ │ 🏛 Vault │       │
│  │ Custody  │ │ Backing  │ │ Verified │ │  Insured │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
│                                                              │
│  • Trophy stored at [vault name] — bonded, climate-controlled │
│  • Legal ownership documented via [law firm]                  │
│  • Smart contract audited by [auditor]                       │
│  • Fully insured against loss/damage                         │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Ready to explore?  [View the Trophy Gallery →]              │
│                                                              │
│                                                              │
└──────────────────────────────────────────────────────────────┘
│ Footer: Trophy Logo | Links | Socials | Disclaimer           │
└──────────────────────────────────────────────────────────────┘
```

#### Interaction Spec

| Element | Behavior |
|---------|----------|
| Trophy Hero Image | Parallax scroll effect. Slight zoom on hover. Click to open lightbox. |
| "View the Trophy" | Smooth scroll to gallery link. On mobile: navigates to `/gallery` |
| "How It Works" | Smooth scroll to 3-step section |
| Stats Counters | Animate count-up on scroll into view (0 → 77, 0 → 1947) |
| Connect Wallet | Opens RainbowKit modal on desktop, slide-up sheet on mobile |
| Trust Icons | Subtle scale animation on hover |
| Bottom CTA | Pulse animation every 5s to draw attention |

---

### 4.2 Gallery Page

#### Layout

```
┌──────────────────────────────────────────────────────────────┐
│ [Nav]                                    [🔗 Wallet] [🔍]    │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Trophy Gallery                                              │
│  Browse our tokenized tennis trophies.                       │
│                                                              │
│  Filters:  [All Years ▼] [Any Material ▼] [Price ▼]         │
│  Sort by:  [Recent ▼]                                        │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                     │
│  │ 🏆       │ │ 🏆       │ │ 🏆       │                     │
│  │ Trophy   │ │ Trophy   │ │ Trophy   │                     │
│  │ Photo    │ │ Photo    │ │ Photo    │                      │
│  │          │ │          │ │          │                     │
│  │ 1947 Champ│ │ 1947 Champ│ │ 1947 Champ│                  │
│  │ Shield   │ │ Shield   │ │ Shield   │                     │
│  │          │ │          │ │          │                     │
│  │ 77 winners│ │ Silver   │ │ ¤0.5 ETH │                    │
│  │ [View →] │ │ [View →] │ │ [View →] │                    │
│  └──────────┘ └──────────┘ └──────────┘                     │
│                                                              │
│  [Load More...]                                              │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

**Note:** For the MVP/single-asset scenario, the gallery may show only one trophy with a hero treatment rather than a grid. The gallery grid should be designed as a reusable component for future multi-asset support.

#### Filter/Sort Interactions

| Filter | Options | UX Pattern |
|--------|---------|------------|
| Year | "All", "1940s", "1950s", ..., "2020s" | Dropdown |
| Material | "All", "Silver", "Hardwood", "Silverplate" | Dropdown |
| Price | Slider (ETH range) or pre-set buckets | Range slider |
| Sort | "Recent minted", "Price: Low → High", "Price: High → Low", "Most winners" | Select |

#### Empty State

```
┌──────────────────────────────────────────────────────┐
│                                                      │
│             🏆                                       │
│       No Trophies Found                              │
│                                                      │
│       No trophies match your filters. Try a          │
│       broader search.                                │
│                                                      │
│       [Clear Filters]                                │
│                                                      │
└──────────────────────────────────────────────────────┘
```

---

### 4.3 Trophy Detail Page

This is the **centerpiece** of the experience. Layout is carefully divided into zones.

#### Zone Layout

```
┌──────────────────────────────────────────────────────────────┐
│ [Nav]                                         [🔗 Wallet]    │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  # ← Back to Gallery                                         │
│                                                              │
│  ┌─────────────────────────────────┐  ┌────────────────────┐ │
│  │                                 │  │ 1947 Ladies Doubles│ │
│  │        TROPHY HERO IMAGE        │  │ Championship Shield│ │
│  │   (full width, high res)        │  │                    │ │
│  │                                 │  │ #001 · Sepolia     │ │
│  │    [Interactive overlay —       │  │                    │ │
│  │     click winner → see location]│  │ A historic trophy  │ │
│  │                                 │  │ awarded since 1947.│ │
│  │                                 │  │ 77 champions       │ │
│  │                                 │  │ engraved.          │ │
│  │                                 │  │                    │ │
│  │                                 │  │ ┌────────────────┐ │ │
│  │                                 │  │ │  Buy Now · 0.5 │ │ │
│  │                                 │  │ │      ETH       │ │ │
│  │                                 │  │ │  Make Offer ▼  │ │ │
│  │                                 │  │ └────────────────┘ │ │
│  │                                 │  │                    │ │
│  │                                 │  │ [Institutional     │ │
│  │                                 │  │  Inquiry →]        │ │
│  └─────────────────────────────────┘  └────────────────────┘ │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ⭐ Interact With the Winners                                 │
│                                                              │
│  Click any name below to see where the 1947 era champions    │
│  are engraved on the trophy.                                 │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  TROPHY IMAGE (smaller, with highlighted area)          │  │
│  │                                                        │  │
│  │           ┌─────────────────────┐                      │  │
│  │           │  1947 - A. Smith ←  │ ← pointer line       │  │
│  │           │  1948 - B. Jones    │    from selected      │  │
│  │           │  1949 - C. Brown    │    name to location   │  │
│  │           │  ...                │    on trophy          │  │
│  │           └─────────────────────┘                      │  │
│  │                                                        │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  Winner List (scrollable):                                   │
│  ┌──────┬──────────────────┬────────┐                        │
│  │ 1947 │ A. Smith         │ [📍]   │  ← click to highlight │
│  │ 1948 │ B. Jones         │ [📍]   │                       │
│  │ 1949 │ C. Brown         │ [📍]   │                       │
│  │ ...  │ ...              │ [📍]   │                       │
│  │ 2024 │ Latest Champion  │ [📍]   │                       │
│  └──────┴──────────────────┴────────┘                        │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Trophy Specifications                                       │
│                                                              │
│  ┌──────────┬────────────────────┐                           │
│  │ Material │ Silverplate, Hardwd│                           │
│  │ Height   │ 24 inches (61 cm)  │                           │
│  │ Width    │ 12 inches (30 cm)  │                           │
│  │ Weight   │ 8.5 lbs (3.9 kg)  │                           │
│  │ Era      │ Post-War 1947     │                           │
│  └──────────┴────────────────────┘                           │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Ownership & Provenance                                      │
│                                                              │
│  Current Owner: 0x1234...5678 [🔗 Etherscan]                 │
│                                                              │
│  Provenance Timeline:                                        │
│  2024 ──────────────────── Minted to Custodian               │
│  2024 ──────────────────── Transferred to Current Owner      │
│  ┌───────────────────────────────────────────────────────┐   │
│  │ 📅 Timeline entry 1                                  │   │
│  │ 📅 Timeline entry 2                                  │   │
│  │ ...│  │                                                │   │
│  └───────────────────────────────────────────────────────┘   │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Custody & Vault                                             │
│                                                              │
│  📍 Current Location: [Vault Name], [City, Country]          │
│  🏛 Facility: Climate-controlled, 24/7 security, bonded     │
│  🛡 Insurance: Fully insured up to [value]                   │
│  🔍 Next Audit: [Date]                                      │
│                                                              │
│  [View Custody Certificate ↓]   [Request Visit →]           │
│                                                              │
└──────────────────────────────────────────────────────────────┘
│ Footer                                                       │
└──────────────────────────────────────────────────────────────┘
```

#### Page Sections In Detail

**A. Hero Section (Top)**
- Trophy image fills left half showing the whole trophy in hero aspect ratio
- Right column: trophy name, token ID badge, network badge, description
- Primary CTA: "Buy Now" (with ETH price) and "Make Offer" dropdown
- Secondary CTA: "Institutional Inquiry" (opens contact form)
- "Back to Gallery" breadcrumb

**B. Winner Interaction Zone (see Section 5 for full spec)**
- Split layout: trophy thumbnail (left) with interactive winner list (right)
- Click any row → trophy image highlights the engraved area + animated pointer line
- Selected winner row gets a subtle background highlight + location dot
- Trophy image uses an SVG overlay with named regions for each winner era cluster

**C. Trophy Specs**
- 2-column grid: Material, Height, Width, Weight, Era
- Clean key-value display with subtle dividers

**D. Ownership & Provenance**
- Current owner (truncated address + Etherscan link)
- Ownership provenance timeline (mint → transfers → current)
- Each timeline entry: date, type (Mint/Transfer/CustodianUpdate), transaction hash link
- Vertical timeline with dots and connecting lines

**E. Custody & Vault**
- Physical location of the trophy
- Facility type (vault/bank/secure storage)
- Insurance information
- Next scheduled physical audit
- "Request Visit" opens a contact form for in-person viewing

---

## 5. Interactive Winner-Trophy Mapping Specification

### 5.1 Concept

The trophy has physical engravings of winner names arranged chronologically. When a user clicks a winner name in the list, the trophy image should visually indicate where that winner's name is physically located on the trophy.

### 5.2 Visual Anatomy of the Trophy

```
              ┌────────────────┐
              │   ✦ FINIAL ✦   │  ← Championship emblem
              └────────────────┘
                       │
              ┌────────────────┐
              │  1947-1955     │  ← Era 1: Early Champions
              │  A. Smith      │    (engraved on shield panel)
              │  B. Jones      │
              │  C. Brown      │
              │  ...           │
              └────────────────┘
              ┌────────────────┐
              │  1956-1970     │  ← Era 2: Golden Era
              │  D. Taylor     │    (engraved on shield panel)
              │  E. Williams   │
              │  F. Davis      │
              │  ...           │
              └────────────────┘
              ┌────────────────┐
              │  1971-1990     │  ← Era 3: Modern Era
              │  G. Wilson     │    (engraved on shield panel)
              │  H. Moore      │
              │  I. Clark      │
              │  ...           │
              └────────────────┘
              ┌────────────────┐
              │  1991-2024     │  ← Era 4: Contemporary
              │  J. Lewis      │    (engraved on base/plinth)
              │  K. Walker     │
              │  L. Hall       │
              │  ...           │
              └────────────────┘
              ┌────────────────┐
              │      BASE      │
              │  (Hardwood)    │
              └────────────────┘
```

### 5.3 Technical Implementation

#### Data Structure

```typescript
interface WinnerMapping {
  year: number;
  name: string;
  regionId: string;      // Maps to an SVG region on the trophy overlay
  regionName: string;    // Display name: "Shield Panel - Era 1"
  regionCoords: {        // Bounding box on trophy image (normalized 0-1)
    x: number;
    y: number;
    width: number;
    height: number;
  };
  era: 'early' | 'golden' | 'modern' | 'contemporary';
}

// Era clusters
const ERA_ZONES: Record<string, { label: string; years: [number, number]; regionId: string }> = {
  early:        { label: "1947–1955", years: [1947, 1955], regionId: "era-early" },
  golden:       { label: "1956–1970", years: [1956, 1970], regionId: "era-golden" },
  modern:       { label: "1971–1990", years: [1971, 1990], regionId: "era-modern" },
  contemporary: { label: "1991–2024", years: [1991, 2024], regionId: "era-contemporary" },
};
```

#### Component Architecture

```
<InteractiveWinnerView>
  ├── <TrophyImageWithOverlay>
  │     ├── <img> (trophy photo with `object-fit: contain`)
  │     └── <svg overlay> (position: absolute, same aspect ratio)
  │           ├── <rect> (highlighted region, based on selectedWinner.regionId)
  │           └── <line> + <circle> (pointer from region to name label)
  │
  └── <WinnerList>
        └── <WinnerRow> (repeated)
              ├── Year
              ├── Name
              └── LocationDot (animated indicator when selected)
```

#### Interaction Flows

**Flow 1: Click Winner in List → Highlight on Trophy**

1. User clicks a `<WinnerRow>` or taps the [📍] icon
2. State: `selectedWinnerId` updates to `{year}-{name}`
3. Trophy image: animated SVG highlight fades in on the corresponding `regionId` rectangle (opacity 0 → 0.2, border)
4. Pointer line animates from the region to a floating name label near the image
5. Selected row gets: `.bg-green-900/20` + `.border-l-4.border-green-500` + scale animation
6. Other rows dim slightly (opacity: 0.5)
7. Click again or click "Clear selection" to reset

**Flow 2: Hover Winner in List → Preview on Trophy**

1. On `onMouseEnter`, a lighter highlight on the region (opacity 0.1, no pointer line)
2. On `onMouseLeave`, revert
3. Does NOT clear a click-based selection

**Flow 3: Auto-Rotate (optional feature)**

1. If the user hasn't interacted for 10 seconds, auto-cycle through winners
2. One winner every 4 seconds, smooth transition
3. Pause on interaction

#### CSS / Animation Spec

| Element | CSS Rule | Implementation |
|---------|---------|----------------|
| Highlight rect | `transition: opacity 400ms ease, fill 300ms ease` | SVG `<rect>` with `rx="4"`; fill `rgba(34, 197, 94, 0.15)` + stroke `rgba(34, 197, 94, 0.6)` when selected |
| Pointer line | `transition: d 500ms ease` (or animate x2,y2 via JS) | SVG `<line>` from region center to label; spring animation in framer-motion |
| Selected row | `transition: background-color 200ms, border-color 200ms` | Tailwind: `selected:bg-green-900/20 selected:border-l-4 selected:border-green-500` |
| Hover row | `transition: opacity 150ms` | Reduce opacity of non-hovered rows to 0.5 |
| Floating label | Fade + slide: `opacity 300ms, transform 300ms` | Positioned absolutely near the image; SVG `<text>` or HTML overlay |
| Trophy image | `object-fit: contain; position: relative` | Container sets aspect ratio matching the actual trophy photo |

### 5.4 Responsive Behavior

| Breakpoint | Layout |
|-----------|--------|
| ≥1024px (desktop) | Side-by-side: trophy thumbnail (40%) + winner list (60%) |
| 768-1023px (tablet) | Stack: image above list, max-h trophy image = 400px |
| <768px (mobile) | Stack: image (250px max) above compact list (4-5 rows visible, scroll). Pointer lines hidden — use color highlight only. Tap row → scrolls trophy to top + highlights region. |

### 5.5 Data Requirements

The trophy image needs an accompanying **region map JSON** file that defines the `regionId` bounding boxes on the image. This should be generated once by the product team:

```json
{
  "imageWidth": 1200,
  "imageHeight": 1600,
  "regions": [
    {
      "id": "era-early",
      "label": "Early Champions (1947-1955)",
      "x": 200, "y": 300, "width": 400, "height": 150
    },
    {
      "id": "era-golden",
      "label": "Golden Era (1956-1970)",
      "x": 200, "y": 480, "width": 400, "height": 180
    },
    {
      "id": "era-modern",
      "label": "Modern Era (1971-1990)",
      "x": 200, "y": 690, "width": 400, "height": 200
    },
    {
      "id": "era-contemporary",
      "label": "Contemporary Era (1991-2024)",
      "x": 300, "y": 950, "width": 350, "height": 150
    }
  ]
}
```

If precise pixel coords are unavailable, fall back to **era-based visual regions** with estimated bounding boxes that can be refined later.

---

## 6. Content Strategy & Page Copy Outline

### 6.1 Voice & Tone

| Attribute | Guideline |
|-----------|-----------|
| **Voice** | Authoritative but warm. Like a museum curator who also understands Web3. |
| **Tone** | Respectful (it's a historic artifact), confident (we've done this right), accessible (explains clearly). |
| **Jargon policy** | First mention: define. Second mention: use shorthand. Third mention: assume understanding. |
| **Pacing** | Short paragraphs. Bullet points for specs. Narrative paragraphs for history. |
| **Target reading level** | Grade 8-10 for main content. Grade 12 for legal sections. |
| **Emotional hooks** | Pride (part of 77-year legacy), wonder (touching history), confidence (secure and trusted). |

### 6.2 Homepage Copy Outline

**Hero:**

```
H1: Own a Piece of Tennis History

Sub: The 1947 Ladies Doubles Championship Shield — a perpetual trophy held by champions for 77 years — is now tokenized on Ethereum for the first time.

[View the Trophy →]
```

**What is RWA Tokenization? Section:**

```
H2: What Does "Tokenized" Mean?

A real-world asset (RWA) NFT is a digital certificate of ownership linked to a physical item.

✅ You buy the NFT → You own the trophy
✅ Trophy stays safe in a vault (bonded, insured, audited)
✅ You can sell the NFT → ownership transfers on-chain

Think of it like digital deed for a house — except this trophy has a story spanning 77 years.

[Learn More → /about]
```

**Why This Trophy Matters Section:**

```
H2: A Legacy 77 Years in the Making

1947 — The year this championship shield was first awarded. Post-war. A new era for women's tennis.

77 seasons of champions. Each name engraved in silverplate. A tradition that has outlasted wars, changing rules, and generations of athletes.

This isn't just a trophy. It's a timeline of sports history you can own.
```

**How It Works Section:**

```
H2: How to Own a Trophy

Step 1: Connect
Set up an Ethereum wallet. We'll guide you through it.

Step 2: Acquire
Buy the trophy NFT with ETH. Simple. No hidden fees.

Step 3: Own
The NFT is yours. Trophy stays vaulted. You get full ownership rights including the right to display, visit, or resell.
```

**Trust Signals Section:**

```
H2: Built on Trust

🔒 Physical Custody — The trophy resides in [vault name]: a bonded, climate-controlled facility with 24/7 security.

📜 Legal Framework — Ownership is documented via [law firm]. The smart contract is structured as a binding legal agreement.

✅ Audit Trail — Every transaction is on-chain and publicly verifiable on Etherscan.

🏛 Fully Insured — The trophy is insured at full replacement value against loss, theft, or damage.

🔄 Secondary Market — Can't hold forever? Sell on OpenSea or our marketplace anytime.
```

### 6.3 Trophy Detail Page Copy Outline

```
H1: 1947 Ladies Doubles Championship Shield

Badges: #Token [001] · [Sepolia/Mainnet]

Description:
The perpetual championship shield of the [Tournament Name], awarded to the Ladies Doubles champions each year since 1947. Crafted from silverplate and hardwood, this trophy bears the engraved names of 77 champion duos.

▸ Historical significance: Post-war revival of the tournament
▸ 77 champion pairs engraved
▸ Original craftsmanship from [year]

[Interactive winner selector — see Section 5]

[Trophy Specs Table]
[Custody Info]
[Provenance Timeline]

CTAs:
[Buy Now · 0.5 ETH]
[Make Offer ▼] → Dropdown: Offer ETH / Offer USD / Request financing
[Institutional Inquiry →] → Opens contact form pre-filled with trophy ID
```

### 6.4 About / Process Page Copy Outline

```
H1: How Trophy Tokenization Works

Sections:
1. What is a Physical-Backed NFT?
   - Analogy: digital deed to a physical object
   - Difference from traditional NFTs (art vs. physical asset)
   - How blockchain proves ownership

2. How Custody Works
   - Trophy location: [vault name]
   - Chain of custody process
   - Regular physical audits
   - How to request a visit

3. Legal Framework
   - Smart contract as legal instrument
   - Governing law
   - Rights transferred vs. retained
   - Intellectual property considerations

4. Authentication
   - How trophy was verified
   - Appraisal documentation
   - Photographic evidence
   - Chain of custody before tokenization

5. Risks & Disclaimers
   - Market risk: value may fluctuate
   - Custody risk (mitigated by insurance)
   - Regulatory risk
   - Smart contract risk (audited, but no guarantee)
   - Not financial advice

[Download Full Prospectus (PDF) →]
```

### 6.5 FAQ Copy Outline

```
General:
Q: How do I buy this? — Step-by-step guide.
Q: Do I receive the physical trophy? — No; NFT = ownership rights.
Q: Can I visit the trophy? — Yes; contact us to arrange a visit.
Q: What if the trophy is damaged? — Fully insured.
Q: Can I resell? — Yes; on OpenSea, or directly.

Technical:
Q: What wallet do I need? — MetaMask, WalletConnect, or Coinbase Wallet.
Q: What chain is this on? — Ethereum (Sepolia testnet for demo; Mainnet for production).
Q: How do I verify authenticity? — Check Etherscan, verify contract, request audit report.
Q: Gas fees? — Paid in ETH for on-chain transactions.

Institutional:
Q: Can my museum acquire this? — Yes; contact us for institutional arrangements.
Q: How does custody work for non-profits? — We can arrange long-term display loans.
Q: Tax implications? — Consult your tax advisor; we provide transaction records.
Q: Can we feature the trophy? — Licensing inquiries welcome.
```

---

## 7. Design System Recommendations

### 7.1 Brand Colors

```
// Primary Colors
--color-gold:        #C9A84C    // Trophy precious metal accent
--color-gold-light:  #E4C76B
--color-gold-dark:   #A6883B

// Backgrounds
--color-bg-dark:     #0C0F1A    // Near-black with blue undertones
--color-bg-card:     #151826    // Card backgrounds
--color-bg-elevated: #1C2033    // Elevated surfaces (modals, hover)

// Text
--color-text-primary:   #F0F2F8
--color-text-secondary: #8B92A8
--color-text-muted:     #5C6180

// Accents (trustworthy green)
--color-accent:      #22C55E    // Success, buy, confirm
--color-accent-dark: #16A34A

// UI Elements
--color-border:      #252940    // Subtle borders
--color-border-light:#323659    // Active/focused borders
--color-danger:      #EF4444    // Errors, disconnections
--color-warning:     #F59E0B    // Caution

// Tennis-themed
--color-tennis-green:  #2E7D32
--color-tennis-yellow: #E8C84A
--color-clay-red:      #B65C3A    // Optional accent
```

**Why this palette:**
- Deep navy-blacks evoke premium museums and luxury galleries
- Gold accents directly reference the trophy's precious metal
- Green accents for buy/success actions (a subtle tennis nod without yelling "sports")
- Professional, not playful — builds trust for high-value RWA

### 7.2 Typography

```
// Headings (Display font — serif for heritage feel)
--font-display: 'Playfair Display', 'Georgia', serif

// Body (Modern sans-serif for readability)
--font-body: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif

// Mono (Code/contracts/timestamps)
--font-mono: 'JetBrains Mono', 'Fira Code', monospace

// Scale
--text-xs:   0.75rem  (12px)
--text-sm:   0.875rem (14px)
--text-base: 1rem     (16px)
--text-lg:   1.125rem (18px)
--text-xl:   1.25rem  (20px)
--text-2xl:  1.5rem   (24px)  // Section headings
--text-3xl:  1.875rem (30px)
--text-4xl:  2.25rem  (36px)  // H1
--text-5xl:  3rem     (48px)  // Hero H1
```

**Usage:**
- Hero headings: `Playfair Display` 3rem (elegant, museum-like)
- Section headings: `Playfair Display` 1.5rem (softer weight)
- Body text: `Inter` 1rem
- Stats/numbers: `Inter` semibold
- Addresses/tx hashes: `JetBrains Mono`
- Buttons: `Inter` semibold

### 7.3 Component Library

**Core Components (build from Tailwind):**

| Component | Style | Notes |
|-----------|-------|-------|
| **Button (Primary)** | `bg-gold text-bg-dark px-6 py-3 rounded-xl font-semibold hover:bg-gold-light transition-all` | "Buy Now", "Connect" |
| **Button (Secondary)** | `bg-card border border-border text-text-primary px-6 py-3 rounded-xl hover:bg-elevated transition-all` | "Make Offer", "View on Etherscan" |
| **Button (Ghost)** | `text-text-secondary hover:text-text-primary px-4 py-2 transition-all` | "Cancel", "Back" |
| **Card** | `bg-card border border-border rounded-2xl p-6` | Trophy cards, info blocks |
| **Badge** | `px-3 py-1 rounded-full text-sm font-medium` | Network, token ID, status |
| **Input** | `bg-bg-dark border border-border rounded-xl px-4 py-3 text-text-primary placeholder-text-muted` | Forms, search |
| **Modal** | `bg-card border border-border rounded-3xl shadow-2xl max-w-md w-full p-8` | Transfer modal, Confirm |
| **Table** | `w-full border-separate border-spacing-0` | Winner list, specs |
| **Timeline** | Vertical line + dots with entry cards | Provenance history |
| **Tabs** | Pill-style tab bar with active indicator | About page sections |
| **Skeleton** | Animated pulse placeholder | Loading states |

**Third-party UI dependencies (keep minimal):**
- `@rainbow-me/rainbowkit` — Wallet connection (already installed)
- `framer-motion` — Animations (winner highlight, scroll, fade) — **new dependency**
- `lucide-react` — Icons (already installed)
- `@tanstack/react-query` — Data fetching (already installed)

### 7.4 Layout Grid

```
--max-width: 1280px (max-w-7xl)
--grid-columns: 12
--gutter: 24px (px-6 on mobile, px-8 on desktop)

Responsive breakpoints:
  sm: 640px (mobile landscape)
  md: 768px (tablet)
  lg: 1024px (desktop)
  xl: 1280px (wide)
```

### 7.5 Dark Mode

Design is dark-mode-first (matches existing implementation). Light mode is stretch goal. If implemented:

- Swap `bg-gray-950` → `bg-gray-50`
- Swap `text-white` → `text-gray-900`
- Gold accent stays, borders go lighter
- Card backgrounds: white with subtle shadow

---

## 8. Implementation Handoff Notes

### 8.1 New Pages to Build

| Page | Route | Priority | Depends On |
|------|-------|----------|------------|
| About / Process | `/about` | High | Content copy |
| FAQ | `/faq` | High | FAQ content |
| Contact | `/contact` | Medium | Contact form |

### 8.2 Existing Pages to Redesign

| Page | Route | Changes |
|------|-------|---------|
| Home | `/` | Full redesign per Section 4.1. Add How It Works, Trust Signals. Remove placeholder layout. |
| Gallery | `/gallery` | Add filters + sort (Section 4.2). Keep card grid but use gold accent. |
| Trophy Detail | `/trophy/[id]` | **Major upgrade.** Add interactive winner mapping (Section 5). Add provenance timeline. Add custody section. Redesign hero layout. Add institutional CTA. |

### 8.3 New Components to Create

| Component | File | Description |
|-----------|------|-------------|
| `InteractiveWinnerView` | `components/InteractiveWinnerView.tsx` | Main orchestrator for winner interaction |
| `TrophyImageWithOverlay` | `components/TrophyImageWithOverlay.tsx` | Trophy image + SVG overlay + highlight + pointer |
| `WinnerList` | `components/WinnerList.tsx` | Scrollable winner table with hover/select |
| `WinnerRow` | `components/WinnerRow.tsx` | Individual winner row with selectable state |
| `ProvenanceTimeline` | `components/ProvenanceTimeline.tsx` | Vertical timeline of ownership events |
| `CustodyInfo` | `components/CustodyInfo.tsx` | Physical custody section with vault details |
| `HowItWorks` | `components/HowItWorks.tsx` | 3-step explainer (reusable for home + about) |
| `TrustSignals` | `components/TrustSignals.tsx` | Trust badge grid (reusable) |
| `InstitutionalInquiry` | `components/InstitutionalInquiry.tsx` | Contact form for institutional buyers |
| `FilterBar` | `components/FilterBar.tsx` | Gallery filter controls |
| `PriceDisplay` | `components/PriceDisplay.tsx` | ETH + USD price with chart sparkline |

### 8.4 Data Structures to Add

```typescript
// Add to lib/types.ts (new file)

export interface WinnerMapping {
  year: number;
  name: string;
  regionId: string;
  era: 'early' | 'golden' | 'modern' | 'contemporary';
}

export interface TrophyRegion {
  id: string;
  label: string;
  x: number;
  y: number;
  width: number;
  height: number;
}

export interface TrophySpecs {
  material: string;
  height: string;
  width: string;
  weight: string;
  era: string;
  condition: string;
}

export interface ProvenanceEvent {
  type: 'mint' | 'transfer' | 'custodian_update' | 'audit';
  date: string;
  description: string;
  txHash?: string;
  from?: string;
  to?: string;
}

export interface CustodyInfo {
  facility: string;
  location: string;
  security: string;
  insurance: string;
  nextAudit: string;
}
```

### 8.5 Dependencies to Add

```bash
npm install framer-motion
```

### 8.6 File Changes Summary

| File | Action |
|------|--------|
| `app/page.tsx` | Replace with new homepage layout |
| `app/layout.tsx` | Add Playfair Display font import |
| `app/gallery/page.tsx` | Add FilterBar component, sort controls |
| `app/trophy/[id]/page.tsx` | Redesign: add InteractiveWinnerView, ProvenanceTimeline, CustodyInfo |
| `app/about/page.tsx` | **New:** About/process page |
| `app/faq/page.tsx` | **New:** FAQ page |
| `app/contact/page.tsx` | **New:** Contact page |
| `app/globals.css` | Add custom CSS variables for gold palette |
| `lib/types.ts` | **New:** TypeScript interfaces |
| `lib/contract.ts` | Add winner region mapping data |
| `public/trophy-annotations.json` | **New:** Trophy image region coordinates |
| `components/*` | Create 10+ new components |
| `tailwind.config.ts` | Add gold palette colors |

### 8.7 Acceptance Checklist

- [ ] Homepage has hero with trophy image + value prop
- [ ] Homepage has "What is RWA Tokenization" section (jargon-free)
- [ ] Homepage has "Why This Trophy Matters" (history storytelling)
- [ ] Homepage has "How It Works" (3-step process)
- [ ] Homepage has Trust Signals section
- [ ] Gallery has filters (year, material, price) and sort
- [ ] Gallery cards show key metadata
- [ ] Trophy Detail has interactive winner selection
- [ ] Clicking a winner name highlights the location on the trophy image
- [ ] Winner list is scrollable, parsed from on-chain data
- [ ] Trophy specs displayed (material, dimensions, condition)
- [ ] Provenance timeline shown (mint → transfers → current)
- [ ] Custody information displayed (facility, insurance, next audit)
- [ ] Buy Now / Make Offer CTAs present
- [ ] Institutional Inquiry button/flow present
- [ ] About page explains tokenization, custody, legal, authentication
- [ ] FAQ page addresses all buyer types (general, tech, institutional)
- [ ] Contact page with institutional form
- [ ] Design follows gold + navy palette
- [ ] Typography: Playfair Display for headings, Inter for body
- [ ] Mobile responsive (all pages)
- [ ] Winner regions JSON file created with bounding boxes
- [ ] All animations smooth (`framer-motion`)
- [ ] Wallet connect works via RainbowKit
- [ ] Dark theme consistent throughout

---

## Appendix: Visual Design References

### Reference Sites for Inspiration

| Site | Why |
|------|-----|
| **Sotheby's Metaverse** | Museum-grade luxury + NFT integration |
| **Christie's 3.0** | High-end auction UI for digital assets |
| **ARKHIVE (arkv.io)** | Best-in-class RWA NFT marketplace UX |
| **Museum of Modern Art (MoMA.org)** | Typography and spacing for historical content |
| **Wimbledon.com** | Tennis heritage, gold/green palette |

### Design Principles

1. **The trophy is the hero** — Every layout prioritizes the trophy image. Content supports the image, never competes.
2. **Progressive disclosure** — Surface the headline ("Own tennis history") first. Layer details on demand.
3. **Trust through transparency** — Show the vault, the contract, the legal docs. Nothing hidden.
4. **Museum, not marketplace** — The tone is curatorial. The purchase is secondary to the experience.
5. **Mobile-first, but desktop-rich** — The trophy detail page deserves a big screen. Design for both, optimize for desktop.
6. **Accessible Web3** — Don't assume crypto knowledge. Explain wallets. Provide fallbacks for non-wallet users.

---

*End of UX Design Document — Ready for @scaffolder implementation*
}