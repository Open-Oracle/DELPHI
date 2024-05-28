// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../requestManager.sol";

/*
 * @title keeperRequest
 * @dev This contract extends the RequestManager contract and manages keeper requests.
 */
abstract contract keeperRequest is requestManager {
    event KeeperRequestExecuted(bytes32 indexed requestId, address indexed target, bytes data);

    /*
     * @dev Creates a new keeper request.
     * @param targetAddress The address to call for the keeper request.
     * @param callData The data to be sent to the target address.
     * @param nativeTokenBounty The amount of tokens staked for the request.
     * @param tax The tax percentage for the request (100 = 1%).
     * @param taxRecipient The address that will receive the tax.
     * @param maturity The timestamp when the request matures.
     * @return bytes32 The ID of the newly created keeper request.
     */
    function createKeeperRequest(
        address targetAddress,
        bytes calldata callData,
        uint128 nativeTokenBounty,
        uint16 tax,
        address taxRecipient,
        uint256 maturity)
        public payable virtual returns (bytes32) {
            KeeperRequestData memory keeperData = KeeperRequestData(targetAddress, callData);
            bytes32 requestId = createRequest(nativeTokenBounty, 2, abi.encode(keeperData), tax, taxRecipient, maturity);
            return requestId;
    }

    /*
     * @dev Executes an existing keeper request.
     * @param requestId The ID of the keeper request to execute.
     */
    function executeKeeperRequest(bytes32 requestId) public virtual {
        Request storage request = requests[requestId];
        require(block.timestamp >= request.maturity, "Request not matured yet");

        KeeperRequestData memory keeperData = abi.decode(request.data, (KeeperRequestData));
        (bool success,) = keeperData.targetAddress.call(keeperData.callData);
        require(success, "Keeper call failed");

        fulfillRequest(requestId);
        emit KeeperRequestExecuted(requestId, keeperData.targetAddress, keeperData.callData);
    }
}
