// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../requestManager.sol";
import "../../interfaces/IRNGCallback.sol";

/*
 * @title RNGRequest
 * @dev This contract extends the RequestManager contract and manages RNG (Random Number Generation) requests.
 */
abstract contract RNGrequest is requestManager {
    event RNGRequestVerified(bytes32 indexed requestId, uint256 randomNumber);

    /*
     * @dev Creates a new RNG request.
     * @param blocksFromNow The number of blocks from the current block to determine the RNG.
     * @param nativeTokenBounty The amount of tokens staked for the request.
     * @param tax The tax percentage for the request (100 = 1%).
     * @param taxRecipient The address that will receive the tax.
     * @param maturity The timestamp when the request matures.
     * @return bytes32 The ID of the newly created RNG request.
     */
    function createRNGRequest(uint256 blocksFromNow, uint128 nativeTokenBounty, uint16 tax, address taxRecipient, uint128 maturity)
    public payable virtual returns (bytes32) {
        require(blocksFromNow > 0 && blocksFromNow <= 256, "Invalid block range");

        RNGRequestData memory rngData = RNGRequestData(uint64(block.number + blocksFromNow));
        bytes32 requestId = createRequest(nativeTokenBounty, 0, abi.encode(rngData), tax, taxRecipient, maturity);
        return requestId;
    }

    /*
     * @dev Fulfills an existing RNG request.
     * @param requestId The ID of the RNG request to fulfill.
     */
    function fulfillRNGRequest(bytes32 requestId) public virtual {
        Request storage request = requests[requestId];
        require(block.timestamp >= request.maturity, "Request not matured yet");

        RNGRequestData memory rngData = abi.decode(request.data, (RNGRequestData));
        require(block.number > rngData.blockNumber, "Too early to verify");
        require(block.number <= rngData.blockNumber + 256, "Request expired");

        bytes32 blockHash = blockhash(rngData.blockNumber);
        require(blockHash != bytes32(0), "Invalid block hash");

        uint256 randomNumber = uint256(blockHash) % 1000000;
        fulfillRequest(requestId);

        emit RNGRequestVerified(requestId, randomNumber);
        IRNGCallback(request.requester).onRNGVerified(requestId, randomNumber);
    }
}
