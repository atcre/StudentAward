# StudentAward

StudentAward is a transparent evaluation system for academic achievement recognition and grant distribution built on the Stacks blockchain. This smart contract provides a decentralized platform for managing student registrations, evaluations, and monetary awards with full transparency and immutable records.

## Features

- **Student Registration**: Secure registration system linking students to their wallet addresses
- **Multi-Role Authorization**: Contract owner and authorized evaluators with different permission levels
- **Evaluation System**: Comprehensive evaluation tracking with scores, subjects, and comments
- **Award Management**: Three-tier award system (Excellence, Achievement, Merit) with monetary rewards
- **Fund Management**: Secure deposit and withdrawal system for award distribution
- **Transparent Records**: All evaluations and awards are permanently recorded on-chain
- **Statistical Tracking**: Real-time contract statistics and student performance metrics

## Technical Specifications

- **Blockchain**: Stacks
- **Language**: Clarity
- **Version**: 1.0.0
- **Clarity Version**: 2
- **Epoch**: 2.5

## Installation

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development toolkit
- [Node.js](https://nodejs.org/) (v14 or higher)
- [Stacks CLI](https://docs.stacks.co/docs/cli)

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd StudentAward
```

2. Navigate to the contract directory:
```bash
cd StudentAward_contract
```

3. Install dependencies:
```bash
npm install
```

4. Verify contract syntax:
```bash
clarinet check
```

5. Run tests:
```bash
clarinet test
```

## Usage Examples

### Deploy Contract

```bash
clarinet deploy --testnet
```

### Register a Student

```clarity
(contract-call? .StudentAward register-student "John Doe" 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
```

### Authorize an Evaluator

```clarity
(contract-call? .StudentAward authorize-evaluator 'ST2REHHS5J3CERCRBEPMGH7921Q6PYKAADT7JP2VB)
```

### Submit an Evaluation

```clarity
(contract-call? .StudentAward submit-evaluation u1 "Mathematics" u85 "Excellent problem-solving skills")
```

### Create an Award

```clarity
(contract-call? .StudentAward create-award u1 u1 u1000000 "Outstanding academic performance")
```

### Claim an Award

```clarity
(contract-call? .StudentAward claim-award u1)
```

## Contract Functions Documentation

### Public Functions

#### `register-student`
Registers a new student in the system.
- **Parameters**: `name` (string-ascii 50), `wallet` (principal)
- **Authorization**: Contract owner only
- **Returns**: Student ID

#### `authorize-evaluator`
Grants evaluation permissions to a principal.
- **Parameters**: `evaluator` (principal)
- **Authorization**: Contract owner only
- **Returns**: Boolean success

#### `submit-evaluation`
Records an evaluation for a student.
- **Parameters**: `student-id` (uint), `subject` (string-ascii 30), `score` (uint), `comments` (string-ascii 200)
- **Authorization**: Contract owner or authorized evaluator
- **Returns**: Evaluation ID

#### `create-award`
Creates a monetary award for a student.
- **Parameters**: `student-id` (uint), `award-type` (uint), `amount` (uint), `reason` (string-ascii 100)
- **Authorization**: Contract owner only
- **Returns**: Award ID

#### `claim-award`
Allows students to claim their awards.
- **Parameters**: `award-id` (uint)
- **Authorization**: Award recipient only
- **Returns**: Boolean success

#### `deposit-funds`
Deposits STX tokens to fund awards.
- **Parameters**: `amount` (uint)
- **Authorization**: Contract owner only
- **Returns**: Boolean success

### Read-Only Functions

#### `get-student`
Retrieves student information by ID.
- **Parameters**: `student-id` (uint)
- **Returns**: Student data or none

#### `get-student-by-wallet`
Retrieves student information by wallet address.
- **Parameters**: `wallet` (principal)
- **Returns**: Student data or none

#### `get-evaluation`
Retrieves evaluation details.
- **Parameters**: `student-id` (uint), `evaluation-id` (uint)
- **Returns**: Evaluation data or none

#### `get-award`
Retrieves award information.
- **Parameters**: `award-id` (uint)
- **Returns**: Award data or none

#### `get-average-score`
Calculates average score for a student.
- **Parameters**: `student-id` (uint)
- **Returns**: Average score or none

#### `get-contract-stats`
Returns contract statistics.
- **Returns**: Total students, awards, and contract balance

#### `is-evaluator`
Checks if a principal is an authorized evaluator.
- **Parameters**: `evaluator` (principal)
- **Returns**: Boolean authorization status

#### `get-award-type-name`
Returns human-readable award type name.
- **Parameters**: `award-type` (uint)
- **Returns**: Award type string

### Award Types

- **Excellence Award** (u1): Highest tier recognition
- **Achievement Award** (u2): Mid-tier accomplishment
- **Merit Award** (u3): Entry-level recognition

### Error Codes

- `ERR_UNAUTHORIZED` (u100): Insufficient permissions
- `ERR_STUDENT_NOT_FOUND` (u101): Student does not exist
- `ERR_INVALID_SCORE` (u102): Score outside valid range (0-100)
- `ERR_AWARD_NOT_FOUND` (u103): Award does not exist
- `ERR_INSUFFICIENT_FUNDS` (u104): Insufficient contract balance
- `ERR_ALREADY_EVALUATED` (u105): Duplicate evaluation attempt
- `ERR_INVALID_AWARD_TYPE` (u106): Invalid award type specified

## Deployment Guide

### Testnet Deployment

1. Configure testnet settings in `settings/Testnet.toml`
2. Deploy using Clarinet:
```bash
clarinet deploy --testnet
```

### Mainnet Deployment

1. Configure mainnet settings in `settings/Mainnet.toml`
2. Ensure thorough testing on testnet
3. Deploy to mainnet:
```bash
clarinet deploy --mainnet
```

### Post-Deployment Setup

1. Authorize initial evaluators
2. Deposit initial funds for awards
3. Register first batch of students
4. Test evaluation and award processes

## Security Notes

### Access Control
- **Contract Owner**: Has full administrative control including student registration, evaluator authorization, award creation, and fund management
- **Authorized Evaluators**: Can submit evaluations for registered students
- **Students**: Can only claim awards designated for their wallet address

### Fund Security
- Award funds are held securely in the contract
- Students can only claim awards specifically created for them
- Contract owner controls fund deposits and award creation
- All transactions are recorded immutably on the blockchain

### Input Validation
- Evaluation scores are limited to 0-100 range
- Award types are validated against predefined constants
- Student and award existence is verified before operations
- Duplicate claims are prevented through status tracking

### Best Practices
- Regularly audit evaluator permissions
- Monitor contract balance and award distributions
- Implement multi-signature controls for high-value deployments
- Keep detailed off-chain records for backup and compliance
- Test all functions thoroughly on testnet before mainnet deployment

## Project Structure

```
StudentAward_contract/
├── contracts/
│   └── StudentAward.clar      # Main smart contract
├── settings/
│   ├── Devnet.toml           # Development network config
│   ├── Testnet.toml          # Testnet configuration
│   └── Mainnet.toml          # Mainnet configuration
├── .vscode/                  # VSCode settings
├── Clarinet.toml            # Project configuration
├── package.json             # Node.js dependencies
└── tsconfig.json            # TypeScript configuration
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.