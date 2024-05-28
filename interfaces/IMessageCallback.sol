// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
 * @title IMessageCallback
 * @dev Interface for the callback function to handle message verification
 */
interface IMessageCallback {
    function onAnswerVerified(bytes32 requestId, bool correct) external;
}
