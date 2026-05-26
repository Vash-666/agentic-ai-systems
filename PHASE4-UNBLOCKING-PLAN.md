# RWA Tennis Trophy Tokenization — Phase 4 Unblocking Plan

**Project:** RWA-TROPHY-001  
**Status:** Phase 4 In Progress — Blocked on Data Finalization  
**Priority:** P1 (High — teaching portfolio + potential revenue)  
**Date:** May 26, 2026  
**Owner:** @product (Product Manager)  

---

## Executive Summary

Phase 4 (Smart Contract Development) is 70% complete with production-grade contracts, tests, and deployment scripts ready. However, three critical blockers prevent testnet deployment and Phase 4 completion:

1. **Champion data finalization** — Owner is manually correcting entries in Champion Transcription Tracker
2. **Environment configuration** — Missing `.env` file with real API keys and credentials
3. **IPFS asset preparation** — High-res trophy photos need upload and metadata finalization

This plan defines specific tasks, owners, success criteria, and a 7-day timeline to unblock Phase 4 and proceed to testnet deployment.

---

## Current State Assessment

### ✅ What's Complete (70%)

| Component | Status | Quality |
|-----------|--------|---------|
| TrophyNFT.sol (ERC-721) | ✅ Complete | Production-grade |
| Hardhat dev environment | ✅ Complete | Multi-network configured |
| Test suite (9 tests) | ✅ Complete | All passing |
| Deployment scripts | ✅ Complete | Etherscan verification ready |
| Metadata template | ✅ Complete | ERC-721 compliant |
| UX Design Document | ✅ Complete | Ready for frontend |

### 🔴 Critical Blockers (30% Remaining)

| Blocker | Impact | Owner | Status |
|---------|--------|-------|--------|
| Champion data finalization | Cannot populate metadata or winner arrays | Human/Owner | ⏸️ In Progress |
| Environment config (.env) | Cannot deploy to testnet or use IPFS | @scaffolder | ❌ Not Started |
| IPFS asset preparation | Cannot mint NFT without valid tokenURI | @content | ❌ Not Started |

---

## Phase 4 Completion Definition

Phase 4 is **COMPLETE** when:

1. **Contract Deployed**: TrophyNFT.sol deployed to Sepolia testnet
2. **Verified**: Contract verified on Sepolia Etherscan
3. **Minted**: At least one test NFT minted with valid IPFS metadata
4. **Viewable**: NFT visible on OpenSea testnet
5. **Documented**: All CIDs, addresses, and transaction hashes recorded
6. **Tested**: All 9 existing tests pass + manual integration test complete

---

## Unblocking Plan — Detailed Tasks

### BLOCKER 1: Champion Data Finalization

**Task ID:** TROPHY-DATA-001  
**Priority:** 🔴 CRITICAL  
**Owner:** Human/Owner (with @content support)  
**Estimated Effort:** 4-6 hours (spread over 2-3 days)  
**Deadline:** Day 3 (May 28, 2026)

#### Description
The owner is manually correcting entries in the Champion Transcription Tracker (.docx). This data must be finalized before metadata JSON can be populated and winner arrays can be stored on-chain.

#### Sub-Tasks

| Sub-Task | Description | Effort | Dependencies |
|----------|-------------|--------|--------------|
| 1.1 | Complete transcription review and corrections in .docx | 2-3h | None |
| 1.2 | Validate year ranges (1945-1973 vs 1947 stated in code) | 30m | 1.1 |
| 1.3 | Document family lineage patterns (Humberstone, Meeson, Moore, Surman, Kydd) | 30m | 1.1 |
| 1.4 | Export corrected data to JSON format | 1h | 1.1-1.3 |
| 1.5 | Validate JSON structure against schema | 30m | 1.4 |

#### Required Output Format

```json
{
  "champions": [
    {"year": 1947, "winners": ["Name1", "Name2"], "event": "Ladies Doubles"},
    {"year": 1948, "winners": ["Name1", "Name2"], "event": "Ladies Doubles"},
    ...
  ],
  "metadata": {
    "yearRange": "1947-1973",
    "totalPlaques": 28,
    "totalWinners": 77,
    "families": ["Humberstone", "Meeson", "Moore", "Surman", "Kydd"]
  }
}
```

#### Success Criteria
- [ ] All 28 years transcribed and validated
- [ ] Year range discrepancy resolved (1945 vs 1947)
- [ ] JSON file exported and validated
- [ ] Family lineage patterns documented

#### Escalation Path
- **Day 2:** If corrections >50% complete, proceed with partial data for testing
- **Day 3:** If blocked, escalate to @switch for decision on proceeding with placeholder data

---

### BLOCKER 2: Environment Configuration

**Task ID:** TROPHY-ENV-001  
**Priority:** 🔴 CRITICAL  
**Owner:** @scaffolder  
**Estimated Effort:** 2-3 hours  
**Deadline:** Day 2 (May 27, 2026)

#### Description
Create `.env` file with real API keys and credentials required for testnet deployment and IPFS integration.

#### Sub-Tasks

| Sub-Task | Description | Effort | Dependencies |
|----------|-------------|--------|--------------|
| 2.1 | Create `.env` file from `.env.example` template | 15m | None |
| 2.2 | Set up Alchemy account and get Sepolia RPC URL | 30m | None |
| 2.3 | Create MetaMask wallet for deployment | 15m | None |
| 2.4 | Get Etherscan API key for contract verification | 15m | None |
| 2.5 | Set up Pinata account and get API credentials | 30m | None |
| 2.6 | Fund deployment wallet with Sepolia ETH | 15m | 2.3 |
| 2.7 | Test all credentials (RPC connection, IPFS upload) | 30m | 2.1-2.6 |

#### Required Environment Variables

```bash
# RPC Provider (Alchemy/Infura)
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY

# Deployment Wallet
PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE

# Etherscan Verification
ETHERSCAN_API_KEY=YOUR_ETHERSCAN_KEY

# IPFS (Pinata)
PINATA_API_KEY=YOUR_PINATA_KEY
PINATA_API_SECRET=YOUR_PINATA_SECRET
PINATA_JWT=YOUR_PINATA_JWT

# Contract Address (populated after deployment)
CONTRACT_ADDRESS=
```

#### Security Requirements
- [ ] `.env` added to `.gitignore`
- [ ] Private key never committed to git
- [ ] Wallet used ONLY for testnet (zero mainnet funds)
- [ ] API keys have minimal required permissions

#### Success Criteria
- [ ] `.env` file created with all required variables
- [ ] Sepolia RPC connection tested and working
- [ ] Deployment wallet funded with ≥0.5 Sepolia ETH
- [ ] Pinata IPFS upload tested and working
- [ ] Etherscan API key verified working

#### Resources
- Sepolia Faucet: https://sepoliafaucet.com/
- Alchemy Signup: https://alchemy.com
- Pinata Signup: https://pinata.cloud

---

### BLOCKER 3: IPFS Asset Preparation

**Task ID:** TROPHY-IPFS-001  
**Priority:** 🔴 CRITICAL  
**Owner:** @content (with @scaffolder support)  
**Estimated Effort:** 3-4 hours  
**Deadline:** Day 4 (May 29, 2026)

#### Description
Upload high-res trophy photos to IPFS via Pinata and create final metadata JSON with actual champion data.

#### Sub-Tasks

| Sub-Task | Description | Effort | Dependencies |
|----------|-------------|--------|--------------|
| 3.1 | Select and prepare high-res trophy photos (enhanced contrast) | 30m | None |
| 3.2 | Create upload script (`scripts/upload-ipfs.js`) | 1h | 2.5 |
| 3.3 | Upload trophy images to IPFS via Pinata | 30m | 3.1, 3.2 |
| 3.4 | Create final metadata JSON with champion data | 1h | 1.5, 3.3 |
| 3.5 | Upload metadata JSON to IPFS | 15m | 3.4 |
| 3.6 | Verify IPFS CIDs are accessible | 15m | 3.5 |
| 3.7 | Document all CIDs for reference | 15m | 3.6 |

#### Metadata JSON Structure

```json
{
  "name": "1947 Ladies Doubles Championship Shield",
  "description": "A historic perpetual trophy awarded to the Ladies Doubles champions since 1947. This token represents ownership of the physical trophy.",
  "image": "ipfs://CID_FOR_TROPHY_IMAGE",
  "attributes": [
    {"trait_type": "Year", "value": "1947"},
    {"trait_type": "Event", "value": "Ladies Doubles"},
    {"trait_type": "Material", "value": "Silverplate, Hardwood"},
    {"trait_type": "Total Winners", "value": 77},
    {"trait_type": "Era", "value": "Post-War"}
  ],
  "winners": [
    {"year": 1947, "names": ["Winner1", "Winner2"]},
    ...
  ],
  "external_url": "https://trophy-rwa.example.com/trophy/1",
  "animation_url": null
}
```

#### Success Criteria
- [ ] Trophy images uploaded to IPFS with accessible CIDs
- [ ] Metadata JSON created and uploaded to IPFS
- [ ] All CIDs documented in `deployment-info.json`
- [ ] IPFS content verified accessible via gateway

---

## Coordination Plan

### Agent Responsibilities

| Agent | Responsibilities | Deliverables |
|-------|------------------|--------------|
| **@product** (me) | Overall coordination, timeline tracking, blocker escalation | This plan, daily status updates, final report |
| **@scaffolder** | Environment setup, deployment scripts, IPFS integration | `.env` file, working deployment, IPFS CIDs |
| **@content** | Champion data export, metadata creation, documentation | `champions.json`, `metadata.json`, docs |
| **@switch** | Escalation decisions, resource allocation, timeline adjustments | Go/no-go decisions, blocker resolution |

### Communication Protocol

**Daily Standups (Async):**
```
Format: TROPHY-[TASK-ID] | [time spent] | Owner: @[name] | Status: [Complete/In Progress/Blocked]

Example:
TROPHY-ENV-001 | 2.5h | Owner: @scaffolder | Status: Complete ✅
- Alchemy RPC configured
- Wallet funded with 0.5 Sepolia ETH
- Pinata upload tested
→ Ready for IPFS task
```

**Blocker Escalation:**
```
Format: 🚨 BLOCKER: [TASK-ID]
Issue: [specific problem]
Impact: [timeline/scope]
Need: [specific help/decision]
Owner: @[name]
```

### Handoff Points

| From | To | Trigger | Handoff Content |
|------|-----|---------|-----------------|
| @scaffolder | @content | `.env` ready | Environment file + credentials test results |
| Human/Owner | @content | Champion data complete | Validated `champions.json` file |
| @content | @scaffolder | Metadata ready | IPFS CIDs + metadata JSON |
| @scaffolder | @product | Deployment complete | Contract address, tx hashes, OpenSea link |

---

## Timeline & Milestones

### 7-Day Sprint Plan

| Day | Date | Focus | Key Deliverables | Owner |
|-----|------|-------|------------------|-------|
| **1** | May 26 | **PLANNING** | This unblocking plan, team alignment | @product |
| **2** | May 27 | **ENVIRONMENT** | `.env` configured, wallet funded | @scaffolder |
| **3** | May 28 | **DATA** | Champion data finalized, JSON exported | Human/Owner |
| **4** | May 29 | **IPFS** | Images uploaded, metadata created | @content |
| **5** | May 30 | **DEPLOYMENT** | Contract deployed to Sepolia, verified | @scaffolder |
| **6** | May 31 | **MINTING** | Test NFT minted, OpenSea visible | @scaffolder |
| **7** | Jun 1 | **VALIDATION** | Final testing, documentation, handoff | @product |

### Daily Milestones

```
Day 1 (May 26): PLANNING COMPLETE
├── Unblocking plan finalized
├── Team roles confirmed
└── Kickoff communication sent

Day 2 (May 27): ENVIRONMENT READY
├── .env file created
├── All API credentials tested
├── Wallet funded with Sepolia ETH
└── Handoff to data task

Day 3 (May 28): DATA FINALIZED
├── Champion transcription complete
├── Year range discrepancy resolved
├── champions.json exported and validated
└── Handoff to IPFS task

Day 4 (May 29): IPFS COMPLETE
├── Trophy images uploaded
├── Metadata JSON created and uploaded
├── All CIDs documented
└── Handoff to deployment task

Day 5 (May 30): CONTRACT DEPLOYED
├── TrophyNFT deployed to Sepolia
├── Contract verified on Etherscan
└── Deployment info recorded

Day 6 (May 31): NFT MINTED
├── Test NFT minted with IPFS metadata
├── NFT visible on OpenSea testnet
└── Manual integration test complete

Day 7 (Jun 1): PHASE 4 COMPLETE
├── All success criteria met
├── Documentation finalized
├── Report to @switch
└── Handoff to Phase 5 planning
```

---

## Success Criteria Summary

### Phase 4 Complete When:

| # | Criterion | Verification Method |
|---|-----------|---------------------|
| 1 | Contract deployed to Sepolia | Etherscan link |
| 2 | Contract verified on Etherscan | Verified badge visible |
| 3 | Test NFT minted | Transaction hash recorded |
| 4 | NFT visible on OpenSea | OpenSea testnet link |
| 5 | Valid IPFS metadata | CID accessible via gateway |
| 6 | All 9 tests pass | `npx hardhat test` output |
| 7 | Manual integration test complete | Checklist signed off |

### Quality Gates

| Gate | Requirement | Owner |
|------|-------------|-------|
| Q1 | Champion data validated (no duplicates, correct years) | @content |
| Q2 | Environment variables secure (no leaks, .gitignore correct) | @scaffolder |
| Q3 | IPFS content accessible (CIDs resolve within 10s) | @content |
| Q4 | Contract deploys without errors | @scaffolder |
| Q5 | NFT displays correctly on OpenSea | @product |

---

## Risk Assessment & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Champion data delays | Medium | High | Parallel work on IPFS prep; use placeholder data for testing if needed |
| RPC provider issues | Low | Medium | Have backup providers (Infura, Alchemy, QuickNode) |
| IPFS upload failures | Low | Medium | Retry logic in upload script; test with small file first |
| Gas price spikes | Low | Low | Monitor gas; use EIP-1559 dynamic fees |
| Wallet funding delays | Medium | Medium | Multiple faucet sources; request from multiple faucets |
| Pinata rate limits | Low | Low | Batch uploads; implement exponential backoff |

### Contingency Plans

**If Champion Data Delayed Past Day 3:**
- Use placeholder winner data for test deployment
- Proceed with IPFS upload of trophy images only
- Update metadata with real data once available
- Deploy updated contract or use `updateWinners()` function if implemented

**If Environment Setup Blocked:**
- Use local Hardhat network for initial testing
- Document exact steps needed for testnet
- Escalate to @switch for resource allocation

**If IPFS Upload Fails:**
- Try alternative IPFS providers (NFT.Storage, Web3.Storage)
- Use centralized hosting temporarily with plan to migrate
- Document fallback procedure

---

## Reporting to @switch

### Status Report Format

```
TO: @switch
FROM: @product
RE: RWA-TROPHY-001 Phase 4 Unblocking — Status Update

EXECUTIVE SUMMARY:
[One-line status: On track / At risk / Blocked]

PROGRESS:
• [Task ID]: [Status] — [brief description]
• [Task ID]: [Status] — [brief description]

BLOCKERS:
• [Task ID]: [Issue] — [escalation request if any]

NEXT 24H:
• [What will be completed by next report]

DECISIONS NEEDED:
• [Any decisions required from @switch]

RISK LEVEL: [Green / Yellow / Red]
```

### Daily Reporting Schedule

| Day | Report Time | Content |
|-----|-------------|---------|
| Day 1 | EOD May 26 | Plan finalized, team aligned |
| Day 2 | EOD May 27 | Environment setup status |
| Day 3 | EOD May 28 | Data finalization status |
| Day 4 | EOD May 29 | IPFS upload status |
| Day 5 | EOD May 30 | Deployment status |
| Day 6 | EOD May 31 | Minting and validation status |
| Day 7 | EOD Jun 1 | Phase 4 completion report |

---

## Post-Phase 4: Phase 5 Preview

Once Phase 4 is complete, the following Phase 5 tasks will be ready to begin:

| Phase 5 Task | Description | Owner |
|--------------|-------------|-------|
| Frontend dApp | Build Next.js frontend per UX design document | @scaffolder |
| Wallet Integration | RainbowKit + wagmi integration | @scaffolder |
| Winner Interaction | Implement interactive winner-trophy mapping | @scaffolder |
| Gallery Page | Trophy gallery with filters and sort | @content |
| Phygital Link | QR code generation, certificate design | @content |

---

## Appendix: Quick Reference

### File Locations

| File | Path | Purpose |
|------|------|---------|
| Smart Contract | `contracts/TrophyNFT.sol` | Main ERC-721 contract |
| Tests | `test/TrophyNFT.test.js` | Test suite |
| Deployment Script | `scripts/deploy.js` | Deployment automation |
| Mint Script | `scripts/mint-trophy.js` | Minting automation |
| Metadata Template | `metadata/trophy-metadata-template.json` | Template |
| Environment Template | `.env.example` | Template for .env |
| UX Design | `TENNIS-TROPHY-RWA-UX-DESIGN.md` | Full UX spec |

### Useful Commands

```bash
# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test

# Start local node
npx hardhat node

# Deploy locally
npx hardhat run scripts/deploy.js --network localhost

# Deploy to Sepolia
npx hardhat run scripts/deploy.js --network sepolia

# Verify contract
npx hardhat verify --network sepolia DEPLOYED_ADDRESS

# Mint trophy
npx hardhat run scripts/mint-trophy.js --network sepolia
```

### External Resources

- **Sepolia Faucet:** https://sepoliafaucet.com/
- **OpenSea Testnet:** https://testnets.opensea.io/
- **Sepolia Etherscan:** https://sepolia.etherscan.io/
- **Pinata IPFS:** https://pinata.cloud/
- **Alchemy:** https://alchemy.com/

---

**Document Version:** 1.0  
**Created:** May 26, 2026  
**Owner:** @product  
**Next Review:** Daily during sprint  

---

*This plan is ready for execution. Let's unblock Phase 4 and ship this trophy to testnet! 🏆*