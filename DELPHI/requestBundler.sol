// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Import statements for the contracts
import "./request/oracleRequest.sol";
import "./request/RNGrequest.sol";
import "./request/messageRequest.sol";
import "./request/keeperRequest.sol";

// Define the abstract contract
abstract contract requestBundler is oracleRequest, RNGrequest, messageRequest, keeperRequest {
    // This abstract contract inherits from ContractA, ContractB, ContractC, and ContractD
    // It doesn't implement any functionality on its own
}
