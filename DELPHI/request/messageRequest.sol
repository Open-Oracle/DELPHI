// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../requestManager.sol";
import "../../interfaces/IMessageCallback.sol";

/*
 * @title MessageRequest
 * @dev This contract extends the RequestManager contract and manages message requests.
 */
abstract contract messageRequest is requestManager {
    event MessageRequestVerified(bytes32 indexed requestId, bool correct);

    /*
     * @dev Creates a new message request.
     * @param hashedAnswer The hashed answer for the message request.
     * @param nativeTokenBounty The amount of tokens staked for the request.
     * @param tax The tax percentage for the request (100 = 1%).
     * @param taxRecipient The address that will receive the tax.
     * @param maturity The timestamp when the request matures.
     * @return bytes32 The ID of the newly created message request.
     */
    function createMessageRequest(
        bytes32 hashedAnswer,
        uint128 nativeTokenBounty,
        uint16 tax,
        address taxRecipient,
        uint256 maturity)
        public payable virtual returns (bytes32) {
            MessageRequestData memory msgData = MessageRequestData(hashedAnswer);
            bytes32 requestId = createRequest(nativeTokenBounty, 1, abi.encode(msgData), tax, taxRecipient, maturity);
            return requestId;
    }

    /*
     * @dev Fulfills an existing message request.
     * @param requestId The ID of the message request to fulfill.
     * @param answer The answer to verify against the hashed answer.
     */
    function fulfillMessageRequest(bytes32 requestId, string memory answer) public virtual {
        Request storage request = requests[requestId];
        require(block.timestamp >= request.maturity, "Request not matured yet");

        MessageRequestData memory msgData = abi.decode(request.data, (MessageRequestData));
        require(keccak256(abi.encodePacked(answer)) == msgData.hashedAnswer, "Incorrect answer");

        fulfillRequest(requestId);
        emit MessageRequestVerified(requestId, true);
        IMessageCallback(request.requester).onAnswerVerified(requestId, true);
    }
}
