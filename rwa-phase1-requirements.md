# Phase 1 Requirements: Blockchain Foundation
**Project:** RWA Tokenization Platform  
**Phase:** 1 (Weeks 1-2: Foundation)  
**Agent:** @product (Product Manager)  
**Date:** 2026-05-17  
**Quality Target:** 8.5/10

---

## Executive Summary

Phase 1 establishes the foundational blockchain infrastructure required for the RWA tokenization platform. This phase focuses on creating the `@blockchain` agent and implementing core blockchain connectivity skills including wallet management, RPC connections, and basic transaction execution.

**Success Criteria:**
- Query ETH balance in <2 seconds
- Send testnet transactions in <10 seconds
- @blockchain agent quality score ≥8.5/10

---

## 1. User Stories

### US-001: Blockchain Agent Deployment
**As a** system orchestrator  
**I want** a dedicated blockchain operations agent  
**So that** all blockchain-related tasks are handled by a specialized agent

**Acceptance Criteria:**
- [ ] @blockchain agent configuration file created at `agents/blockchain/config.yaml`
- [ ] Agent registered with @switch orchestrator
- [ ] Agent responds to blockchain-related intents
- [ ] Agent quality score ≥8.5/10 on test tasks
- [ ] Agent can handle parallel execution requests

**Priority:** P0 (Critical)  
**Estimated Effort:** 2 days

---

### US-002: RPC Connection Management
**As a** blockchain operator  
**I want** reliable RPC endpoint connections with automatic failover  
**So that** blockchain operations continue even if one provider fails

**Acceptance Criteria:**
- [ ] Support for multiple RPC providers (Infura, Alchemy, QuickNode)
- [ ] Automatic failover when primary RPC is unavailable
- [ ] Connection health checks every 30 seconds
- [ ] Latency <500ms for standard JSON-RPC calls
- [ ] Support for Ethereum mainnet and testnets (Sepolia, Holesky)
- [ ] Graceful error handling with meaningful error messages

**Priority:** P0 (Critical)  
**Estimated Effort:** 2 days

---

### US-003: Secure Wallet Management
**As a** platform user  
**I want** secure wallet creation and management  
**So that** I can interact with the blockchain without exposing private keys

**Acceptance Criteria:**
- [ ] HD wallet generation (BIP-39/BIP-44 compliant)
- [ ] Encrypted key storage (AES-256-GCM)
- [ ] No raw private keys in logs or memory dumps
- [ ] Support for multiple wallet accounts
- [ ] Address derivation for Ethereum (EIP-55 checksum)
- [ ] Key backup and recovery mechanism
- [ ] Integration with environment variables for sensitive data

**Priority:** P0 (Critical)  
**Estimated Effort:** 3 days

---

### US-004: Balance Query Operations
**As a** platform user  
**I want** to query ETH and ERC-20 token balances  
**So that** I can monitor my assets in real-time

**Acceptance Criteria:**
- [ ] Query native ETH balance by address
- [ ] Query ERC-20 token balances by contract address
- [ ] Response time <2 seconds for single balance query
- [ ] Batch balance queries supported (up to 10 addresses)
- [ ] Formatted output with proper decimal places
- [ ] Cache balances for 60 seconds to reduce RPC calls

**Priority:** P1 (High)  
**Estimated Effort:** 1 day

---

### US-005: Testnet Transaction Execution
**As a** platform developer  
**I want** to send transactions on testnet  
**So that** I can test operations without spending real funds

**Acceptance Criteria:**
- [ ] Send ETH transfers on Sepolia testnet
- [ ] Automatic gas estimation with EIP-1559 support
- [ ] Transaction signing with secure key management
- [ ] Transaction receipt polling with timeout
- [ ] Transaction hash returned and logged
- [ ] End-to-end latency <10 seconds
- [ ] Clear error messages for failed transactions

**Priority:** P1 (High)  
**Estimated Effort:** 2 days

---

### US-006: Smart Contract Interaction (Read-Only)
**As a** platform user  
**I want** to call read-only functions on smart contracts  
**So that** I can retrieve on-chain data without spending gas

**Acceptance Criteria:**
- [ ] Call any view/pure function by ABI and contract address
- [ ] Support for common data types (uint, string, address, bool, arrays)
- [ ] Parse and format return values automatically
- [ ] Cache results for 5 minutes
- [ ] Support multiple contract calls in parallel
- [ ] Clear error handling for revert reasons

**Priority:** P2 (Medium)  
**Estimated Effort:** 2 days

---

### US-007: Blockchain Event Monitoring
**As a** platform operator  
**I want** to listen for on-chain events  
**So that** I can react to blockchain activity in real-time

**Acceptance Criteria:**
- [ ] Subscribe to contract events via WebSocket
- [ ] Filter events by topic and contract address
- [ ] Event callback system for agent notifications
- [ ] Automatic reconnection on WebSocket failure
- [ ] Event persistence to local log file
- [ ] Support for historical event querying

**Priority:** P2 (Medium)  
**Estimated Effort:** 2 days

---

## 2. Dependencies

### 2.1 External Services

| Service | Purpose | Setup Required | Cost |
|---------|---------|----------------|------|
| Infura | Primary RPC provider | Account + API key | Free tier: 100K req/day |
| Alchemy | Backup RPC provider | Account + API key | Free tier: 300M compute units/mo |
| QuickNode | Tertiary RPC provider | Account + API key | Pay-as-you-go |
| Sepolia Faucet | Test ETH acquisition | Wallet address | Free |

### 2.2 Node.js Packages

| Package | Version | Purpose |
|---------|---------|---------|
| ethers | ^6.13.0 | Ethereum interaction library |
| viem | ^2.21.0 | Modern Ethereum library (alternative) |
| @ethereumjs/wallet | ^2.0.0 | Wallet management |
| bip39 | ^3.1.0 | Mnemonic generation |
| winston | ^3.14.0 | Logging |
| dotenv | ^16.4.0 | Environment configuration |
| ws | ^8.18.0 | WebSocket client |

### 2.3 System Requirements

- Node.js >= 18.0.0
- OpenClaw runtime with skill support
- Network access to RPC endpoints
- Secure storage for encrypted keys

### 2.4 Internal Dependencies

| Component | Status | Integration Point |
|-----------|--------|-------------------|
| @switch (Orchestrator) | ✅ Active | Agent registration and routing |
| @quality (Auditor) | ✅ Active | Transaction audit for high-value ops |
| Skill framework | ✅ Active | SKILL.md execution |

---

## 3. File Structure

```
workspace/
├── agents/
│   └── blockchain/
│       ├── config.yaml              # Agent configuration
│       ├── persona.md               # Agent persona and capabilities
│       └── handlers/
│           ├── balance.js           # Balance query handler
│           ├── transaction.js       # Transaction handler
│           ├── contract.js          # Contract interaction handler
│           └── events.js            # Event monitoring handler
├── skills/
│   └── blockchain/
│       ├── SKILL.md                 # Skill definition and commands
│       ├── package.json             # Node dependencies
│       ├── src/
│       │   ├── index.js             # Skill entry point
│       │   ├── provider.js          # RPC connection manager
│       │   ├── wallet.js            # Wallet management
│       │   ├── transaction.js       # Transaction builder
│       │   ├── contract.js          # Contract ABI handler
│       │   ├── events.js            # Event listener
│       │   └── utils/
│       │       ├── formatter.js     # Output formatting
│       │       ├── validator.js     # Input validation
│       │       └── cache.js         # Simple caching layer
│       └── tests/
│           ├── provider.test.js
│           ├── wallet.test.js
│           └── transaction.test.js
├── config/
│   └── blockchain/
│       ├── networks.yaml            # Network configurations
│       └── rpc-providers.yaml       # RPC endpoint configs
├── .env.example                     # Environment variables template
└── docs/
    └── blockchain/
        ├── setup.md                 # Setup instructions
        └── api-reference.md         # API documentation
```

---

## 4. Installation Steps

### Step 1: Environment Setup (Day 1)

```bash
# 1.1 Create skill directory
mkdir -p skills/blockchain/src/utils
mkdir -p skills/blockchain/tests
mkdir -p agents/blockchain/handlers
mkdir -p config/blockchain

# 1.2 Initialize Node.js project
cd skills/blockchain
npm init -y

# 1.3 Install dependencies
npm install ethers@^6.13.0 winston@^3.14.0 dotenv@^16.4.0 ws@^8.18.0
npm install --save-dev jest@^29.7.0

# 1.4 Create .env file from template
cp .env.example .env
```

### Step 2: RPC Provider Configuration (Day 1-2)

```bash
# 2.1 Sign up for RPC services
# - Infura: https://infura.io
# - Alchemy: https://alchemy.com
# - QuickNode: https://quicknode.com

# 2.2 Configure environment variables
# Edit .env file:
cat > .env << 'EOF'
# RPC Provider API Keys
INFURA_API_KEY=your_infura_key_here
INFURA_API_SECRET=your_infura_secret_here
ALCHEMY_API_KEY=your_alchemy_key_here
QUICKNODE_API_KEY=your_quicknode_key_here

# Network Selection (mainnet, sepolia, holesky)
DEFAULT_NETWORK=sepolia

# Wallet Configuration
WALLET_MNEMONIC=your_secure_mnemonic_here
WALLET_PASSWORD=encryption_password_here

# Logging
LOG_LEVEL=info
EOF
```

### Step 3: Core Skill Implementation (Day 2-4)

```bash
# 3.1 Create provider connection manager
# File: skills/blockchain/src/provider.js

# 3.2 Implement wallet management
# File: skills/blockchain/src/wallet.js

# 3.3 Build transaction handler
# File: skills/blockchain/src/transaction.js

# 3.4 Create contract interaction layer
# File: skills/blockchain/src/contract.js

# 3.5 Implement event monitoring
# File: skills/blockchain/src/events.js
```

### Step 4: SKILL.md Creation (Day 4)

```bash
# 4.1 Create skill definition
cat > skills/blockchain/SKILL.md << 'EOF'
# blockchain - Blockchain Operations Skill

Interact with Ethereum and EVM-compatible blockchains.

## Commands

### balance
Query ETH or token balance for an address.

```bash
openclaw blockchain balance <address> [token_address]
```

### send
Send ETH or tokens to an address.

```bash
openclaw blockchain send <to_address> <amount> [token_address]
```

### call
Call a read-only contract function.

```bash
openclaw blockchain call <contract> <function> [args...]
```

### deploy
Deploy a smart contract.

```bash
openclaw blockchain deploy <bytecode> [abi] [args...]
```

## Configuration

Requires RPC_PROVIDER and WALLET_MNEMONIC environment variables.
EOF
```

### Step 5: Agent Configuration (Day 5)

```bash
# 5.1 Create agent configuration
cat > agents/blockchain/config.yaml << 'EOF'
agent:
  name: blockchain
  display_name: "@blockchain"
  role: Blockchain Operations Specialist
  model: claude-sonnet-4.5
  
capabilities:
  - transaction_execution
  - balance_queries
  - contract_interaction
  - event_monitoring
  - gas_optimization

dependencies:
  - skill: blockchain
    version: "^1.0.0"
  
routing:
  intents:
    - pattern: "send.*eth|transfer.*token|transaction"
      handler: transaction
    - pattern: "balance|check.*balance|get.*balance"
      handler: balance
    - pattern: "call.*contract|read.*contract"
      handler: contract
    - pattern: "deploy.*contract|create.*token"
      handler: deploy
      
quality:
  target_score: 8.5
  audit_threshold: 0.1  # ETH value requiring @quality audit
EOF

# 5.2 Create agent persona
cat > agents/blockchain/persona.md << 'EOF'
# @blockchain Agent Persona

You are a blockchain operations specialist. Your role is to:

1. Execute transactions safely and efficiently
2. Query on-chain data accurately
3. Interact with smart contracts
4. Monitor blockchain events
5. Optimize gas usage

Always:
- Validate addresses before operations
- Estimate gas before sending transactions
- Use testnet for testing
- Log all operations for audit
- Report transaction hashes clearly

Never:
- Expose private keys
- Skip transaction simulation for high-value ops
- Ignore failed transaction receipts
EOF
```

### Step 6: Testing & Validation (Day 6-7)

```bash
# 6.1 Run unit tests
npm test

# 6.2 Get test ETH from Sepolia faucet
# Visit: https://sepoliafaucet.com
# Enter wallet address

# 6.3 Test balance query
openclaw blockchain balance 0xYourAddress --network sepolia

# 6.4 Test transaction
openclaw blockchain send 0xRecipientAddress 0.001 --network sepolia

# 6.5 Verify agent quality score
openclaw quality audit --agent blockchain --task "send 0.001 ETH"
```

### Step 7: Integration with @switch (Day 7-8)

```bash
# 7.1 Register agent with orchestrator
openclaw agents register blockchain

# 7.2 Test routing
# Send message to @switch: "check my ETH balance"
# Verify @blockchain handles the request

# 7.3 Test parallel execution
# Send multiple balance queries simultaneously
```

---

## 5. Configuration Reference

### Environment Variables

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `INFURA_API_KEY` | Yes | Infura project ID | `1234567890abcdef` |
| `INFURA_API_SECRET` | No | Infura project secret | `secret_key_here` |
| `ALCHEMY_API_KEY` | Yes | Alchemy API key | `alchemy_key_here` |
| `QUICKNODE_API_KEY` | No | QuickNode endpoint | `quicknode_url` |
| `DEFAULT_NETWORK` | No | Default chain | `sepolia` |
| `WALLET_MNEMONIC` | Yes | HD wallet seed phrase | `word1 word2 ... word12` |
| `WALLET_PASSWORD` | Yes | Encryption password | `secure_password` |
| `LOG_LEVEL` | No | Logging verbosity | `info` |

### Network Configurations

```yaml
# config/blockchain/networks.yaml
networks:
  mainnet:
    chain_id: 1
    rpc_providers:
      - infura
      - alchemy
      - quicknode
    explorer: https://etherscan.io
    
  sepolia:
    chain_id: 11155111
    rpc_providers:
      - infura
      - alchemy
    explorer: https://sepolia.etherscan.io
    faucet: https://sepoliafaucet.com
    
  holesky:
    chain_id: 17000
    rpc_providers:
      - infura
      - alchemy
    explorer: https://holesky.etherscan.io
```

---

## 6. Testing Checklist

### Unit Tests

- [ ] Provider connection and failover
- [ ] Wallet generation and encryption
- [ ] Balance query formatting
- [ ] Transaction building and signing
- [ ] Contract call encoding/decoding
- [ ] Event parsing and filtering

### Integration Tests

- [ ] End-to-end balance query on Sepolia
- [ ] Send testnet transaction
- [ ] Call ERC-20 balanceOf function
- [ ] Listen for Transfer events
- [ ] Agent routing from @switch
- [ ] Parallel transaction execution

### Performance Tests

- [ ] Balance query <2s (100 requests)
- [ ] Transaction submission <10s
- [ ] RPC failover <1s
- [ ] Concurrent operations (10 parallel)

---

## 7. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| RPC rate limiting | Medium | Medium | Multi-provider failover, caching |
| Private key exposure | Low | Critical | Encryption, environment isolation, no logs |
| Testnet instability | Medium | Low | Support multiple testnets |
| Gas price volatility | Medium | Medium | EIP-1559 dynamic fees |
| Skill integration issues | Low | Medium | Comprehensive testing, rollback plan |

---

## 8. Success Metrics

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| Balance query latency | <2s | Average of 100 requests |
| Transaction latency | <10s | End-to-end testnet transfer |
| RPC uptime | >99.9% | Health check monitoring |
| Agent quality score | ≥8.5/10 | @quality audit results |
| Test coverage | >80% | Jest coverage report |
| Transaction success rate | >99% | Testnet operation logs |

---

## 9. Handoff to Phase 2

Upon completion of Phase 1, the following will be delivered:

1. ✅ @blockchain agent deployed and operational
2. ✅ SKILL.md for blockchain operations
3. ✅ RPC connection management with failover
4. ✅ Secure wallet management system
5. ✅ Balance query and transaction capabilities
6. ✅ Documentation and test coverage

**Next Phase Dependencies:**
- @blockchain agent must be operational
- Token factory contracts need deployment capability
- IPFS integration for metadata storage

---

## 10. Appendix

### A. Useful Resources

- [Ethers.js Documentation](https://docs.ethers.org/v6/)
- [Viem Documentation](https://viem.sh/)
- [Sepolia Testnet](https://sepolia.dev/)
- [EIP-1559 Gas Market](https://eips.ethereum.org/EIPS/eip-1559)
- [ERC-20 Token Standard](https://eips.ethereum.org/EIPS/eip-20)

### B. Faucet Links

- Sepolia: https://sepoliafaucet.com
- Alchemy Sepolia: https://sepoliafaucet.com
- Infura Sepolia: https://www.infura.io/faucet/sepolia

### C. Test Contract Addresses (Sepolia)

| Contract | Address | Purpose |
|----------|---------|---------|
| WETH | 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9 | Wrapped ETH |
| USDC | 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238 | Test USDC |
| Uniswap V2 | 0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008 | DEX testing |

---

**Document Version:** 1.0  
**Last Updated:** 2026-05-17  
**Author:** @product (Product Manager Agent)
