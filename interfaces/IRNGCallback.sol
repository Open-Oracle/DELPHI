// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
 * @title IRNGCallback
 * @dev Interface for the callback function to handle RNG verification
 * @note callbacks allow for external contracts to execute logic upon request fulfillment
 */
interface IRNGCallback {
    function onRNGVerified(bytes32 requestId, uint256 randomNumber) external;
}
