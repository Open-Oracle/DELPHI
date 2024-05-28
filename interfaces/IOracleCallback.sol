// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
 * @title IOracleCallback
 * @dev Interface for the callback function to handle Oracle verification
 */
interface IOracleCallback {
    function onOracleVerified(bytes32 requestId, bool correct) external;
}
