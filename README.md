# 🚀 DELPHI: The Ultimate Oracle of Delphi Token and Request Management System

Welcome to the **DELPHI** repository, your all-in-one solution for token management and comprehensive request handling. DELPHI combines the power of Random Number Generation (RNG), messaging, keeper functions, and oracle services into a seamless and efficient smart contract ecosystem. This repository provides everything you need to get started with our innovative platform, from simple deployment guides to detailed usage instructions.

## 🌟 What is DELPHI?

DELPHI is a multi-faceted smart contract system designed to manage token transactions and various types of requests. It leverages the robust capabilities of Ethereum to provide:
- **ERC20 Token Management**: Secure and scalable token operations.
- **RNG Requests**: Random number generation for fair and transparent outcomes.
- **Message Requests**: Secure message verification and handling.
- **Keeper Requests**: Automated contract calls for maintenance and operations.
- **Oracle Requests**: Reliable and verifiable data retrieval from external sources.

## 📚 Why Use DELPHI?

DELPHI offers a unique blend of functionality, security, and flexibility:
- **Unified Platform**: Manage multiple request types within a single contract.
- **Scalability**: Designed for efficient token handling and request processing.
- **Security**: Robust mechanisms for secure and verifiable request fulfillment.
- **Flexibility**: Easily integrate with various external services and data sources.

## 🛠️ How to Use DELPHI

### Getting Started
### Creating Requests

#### RNG Request
Create a Random Number Generation request to ensure fair and transparent outcomes:
```
function createRNGRequest(
    uint256 blocksFromNow, 
    uint128 nativeTokenBounty, 
    uint16 tax, 
    address taxRecipient, 
    uint128 maturity
) public payable override returns (bytes32) 
{
    return RNGrequest.createRNGRequest(blocksFromNow, nativeTokenBounty, tax, taxRecipient, maturity);
}
```

#### Message Request
Set up a secure message verification request:
```
function createMessageRequest(
    bytes32 hashedAnswer, 
    uint128 nativeTokenBounty, 
    uint16 tax, 
    address taxRecipient, 
    uint256 maturity
) public payable override returns (bytes32) 
{
    return messageRequest.createMessageRequest(hashedAnswer, nativeTokenBounty, tax, taxRecipient, maturity);
}
```

#### Keeper Request
Automate contract maintenance with a keeper request:
```
function createKeeperRequest(
    address targetAddress, 
    bytes calldata callData, 
    uint128 nativeTokenBounty, 
    uint16 tax, 
    address taxRecipient, 
    uint256 maturity
) public payable override returns (bytes32) 
{
    return keeperRequest.createKeeperRequest(targetAddress, callData, nativeTokenBounty, tax, taxRecipient, maturity);
}
```

#### Oracle Request
Retrieve reliable data from external sources:
```
function createOracleRequest(
    bytes memory data, 
    address designatedFulfiller, 
    bool isOpenToAny, 
    uint128 nativeTokenBounty, 
    uint16 tax, 
    address taxRecipient, 
    uint256 maturity
) public payable override returns (bytes32) 
{
    return oracleRequest.createOracleRequest(data, designatedFulfiller, isOpenToAny, nativeTokenBounty, tax, taxRecipient, maturity);
}
```

### Fulfilling Requests

#### RNG Request
```
function fulfillRNGRequest(bytes32 requestId) public override {
    RNGrequest.fulfillRNGRequest(requestId);
    distributeReward(requestId, msg.sender);
}
```

#### Message Request
```
function fulfillMessageRequest(bytes32 requestId, string memory answer) public override {
    messageRequest.fulfillMessageRequest(requestId, answer);
    distributeReward(requestId, msg.sender);
}
```

#### Keeper Request
```
function executeKeeperRequest(bytes32 requestId) public override {
    keeperRequest.executeKeeperRequest(requestId);
    distributeReward(requestId, msg.sender);
}
```

#### Oracle Request
```
function fulfillOracleRequest(bytes32 requestId, bytes memory data) public override {
    oracleRequest.fulfillOracleRequest(requestId, data);
    if (!requests[requestId].fulfilled) {return;}
    distributeReward(requestId, msg.sender);
}
```

### Verifying Oracle Request
```
function verifyOracleRequest(bytes32 requestId, bytes32 fulfillmentId, bool correct) public override {
    oracleRequest.verifyOracleRequest(requestId, fulfillmentId, correct);
    distributeReward(requestId, msg.sender);
}
```

### Halving
Ensure continuous reward optimization with halving:
```
function halving() public {
    uint256 currentSupply = totalSupply();
    while (currentSupply >= nextHalvingPoint) {
        reward = reward / 2;
        nextHalvingPoint = nextHalvingPoint * 2;
    }
}
```

## 🔗 Interfaces

To integrate with DELPHI, implement the callback interfaces:

### IMessageCallback
```
pragma solidity ^0.8.24;

interface IMessageCallback {
    function onAnswerVerified(bytes32 requestId, bool correct) external;
}
```

### IRNGCallback
```
pragma solidity ^0.8.24;

interface IRNGCallback {
    function onRNGVerified(bytes32 requestId, uint256 randomNumber) external;
}
```

### IOracleCallback
```
pragma solidity ^0.8.24;

interface IOracleCallback {
    function onOracleVerified(bytes32 requestId, bool correct) external;
}
```

## 🤝 Contributing

We welcome contributions! Please fork the repository and submit pull requests for review.

## 📄 License

This project is licensed under the MIT License.

---

Ready to revolutionize your smart contract operations? Deploy DELPHI today and harness the power of integrated request management with secure token operations. Let's make a trillion dollars together! 🚀
