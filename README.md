# Oracle of Delphi - The Premier Automation Service Platform

Welcome to DELPHI, a state-of-the-art oracle service platform designed to streamline on-chain task automation while incentivizing user participation. DELPHI empowers developers to build powerful, self-sustaining systems that reward users with scarce native tokens and additional bounties. Discover how DELPHI can revolutionize your blockchain applications!

## Overview

DELPHI is a comprehensive contract suite that integrates multiple types of requests: RNG (Random Number Generation), Message, Keeper, and Oracle. By leveraging DELPHI, you can create automated systems that incentivize request fulfillment with native tokens or ETH, driving user engagement and participation.

## Key Features

- **Versatile Request Handling**: Supports RNG, Message, Keeper, and Oracle requests.
- **Incentivized Ecosystem**: Rewards users for fulfilling requests with native tokens and bounties.
- **Self-Sustaining Automation**: Build systems that fund themselves through user interactions.
- **Scalable and Extendable**: Deploy as-is or enhance with additional layers for advanced functionality.

## Bounty and Reward System

DELPHI's reward system incentivizes participation from both developers and users. Here's how it works:

- **Bounties**: Users can stake native tokens or ETH as bounties for fulfilling requests. This encourages prompt and accurate fulfillment of tasks.
- **Rewards**: When a request is fulfilled, the fulfiller receives a reward in native tokens. Additionally, a portion of the bounty is distributed as an incentive.
- **Incentives for Use**: The more users interact with DELPHI, the more they can earn. This creates a thriving ecosystem where users are motivated to engage regularly.

## Getting Started

Integrate DELPHI into your project to start leveraging its powerful oracle services. Below is a step-by-step guide to help you make the most of DELPHI's capabilities.

### Step 1: Interact with the DELPHI Contract

You can interact with the already deployed DELPHI contract to create and fulfill various types of requests. Here are examples of how to do that.

#### Creating an RNG Request

To create an RNG request, call the `createRNGRequest` function with the necessary parameters:

```
pragma solidity ^0.8.24;

interface IDelphi {
    function createRNGRequest(
        uint256 blocksFromNow, 
        uint128 nativeTokenBounty, 
        uint16 tax, 
        address taxRecipient, 
        uint128 maturity
    ) external payable returns (bytes32);
}

contract YourContract {
    IDelphi delphi;

    constructor(address delphiAddress) {
        delphi = IDelphi(delphiAddress);
    }

    function requestRandomNumber(uint256 blocksFromNow, uint128 nativeTokenBounty) external payable {
        delphi.createRNGRequest{value: msg.value}(blocksFromNow, nativeTokenBounty, 100, msg.sender, uint128(block.timestamp + 1 hours));
    }
}
```

#### Fulfilling an RNG Request

To fulfill an RNG request, you can call the `fulfillRNGRequest` function:

```
pragma solidity ^0.8.24;

interface IDelphi {
    function fulfillRNGRequest(bytes32 requestId) external;
}

contract YourContract {
    IDelphi delphi;

    constructor(address delphiAddress) {
        delphi = IDelphi(delphiAddress);
    }

    function fulfillRandomRequest(bytes32 requestId) external {
        delphi.fulfillRNGRequest(requestId);
    }
}
```

### Step 2: Implement Callback Interfaces

To handle the results of fulfilled requests, implement the necessary callback interfaces in your contract. Here’s an example for RNG requests:

#### RNG Callback Interface

```
pragma solidity ^0.8.24;

interface IRNGCallback {
    function onRNGVerified(bytes32 requestId, uint256 randomNumber) external;
}

contract YourContract is IRNGCallback {
    function onRNGVerified(bytes32 requestId, uint256 randomNumber) external override {
        // Handle the RNG result
    }
}
```

### Step 3: Build and Deploy

Build and deploy your contract that integrates with DELPHI. Use DELPHI's versatile oracle services to create innovative, automated systems that can engage users and incentivize participation.

## Example Use Case

Imagine creating a decentralized lottery system where users can buy tickets, and the winning ticket is selected using DELPHI's RNG service. Users are incentivized to participate as the reward increases with more ticket sales, and the system remains transparent and fair.

## Incentives for Developers and Users

DELPHI's ecosystem thrives on active participation from both developers and users:

- **For Developers**: Build advanced, automated applications that can sustain themselves through user interactions. Integrate DELPHI’s oracle services to enhance functionality and ensure reliability.
- **For Users**: Engage with the platform by fulfilling requests and earning rewards. The more you participate, the more you earn, creating a cycle of continuous engagement and benefit.

## Conclusion

DELPHI provides the tools needed to create dynamic, self-sustaining blockchain applications. Whether you're building a decentralized game, a prediction market, or any other system requiring reliable oracle services, DELPHI has you covered. Start integrating DELPHI today and unlock the full potential of your blockchain projects!

