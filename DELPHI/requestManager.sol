// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./oracleStorage.sol";
import "../ERC20/ERC20mi.sol";

/*
 * @title RequestManager
 * @dev This contract extends the ERC20p contract and manages various types of requests.
 */
abstract contract requestManager is oracleStorage, ERC20mi{

    /*
     * @dev Creates a new request.
     * @param NativeTknBounty The amount of tokens staked for the request.
     * @param requestType The type of request (0: RNG, 1: Message, 2: Keeper, 3: Oracle).
     * @param data The data specific to the request type.
     * @param tax The tax percentage for the request (100 = 1%).
     * @param taxRecipient The address that will receive the tax.
     * @param maturity The timestamp when the request matures.
     * @return bytes32 The ID of the newly created request.
     */
    function createRequest(
        uint128 NativeTknBounty,
        uint8 requestType,
        bytes memory data,
        uint16 tax,
        address taxRecipient,
        uint256 maturity)
        internal returns (bytes32) {
            require(balanceOf[msg.sender] >= NativeTknBounty, "Insufficient token balance to stake");

            bytes32 requestId = keccak256(abi.encodePacked(msg.sender, block.timestamp, nonce));
            requests[requestId] = Request({
                requester: msg.sender,
                ethBounty: uint128(msg.value),
                NativeTknBounty: NativeTknBounty,
                fulfilled: false,
                requestType: requestType,
                data: data,
                tax: tax,
                taxRecipient: taxRecipient,
                maturity: maturity
            });

            _burn(msg.sender, NativeTknBounty);
            emit RequestCreated(requestId, msg.sender, msg.value, NativeTknBounty, requestType, tax, taxRecipient);
            return requestId;
    }

    /*
     * @dev Fulfills an existing request.
     * @param requestId The ID of the request to fulfill.
     */
    function fulfillRequest(bytes32 requestId) internal {
        Request storage request = requests[requestId];
        require(request.requester != address(0), "Invalid request ID");
        require(!request.fulfilled, "Already fulfilled");
        require(block.timestamp >= request.maturity, "Request not matured yet");

        request.fulfilled = true;
        emit RequestFulfilled(requestId);
    }

    /*
     * @dev Withdraws a request, refunding the staked tokens and ETH.
     * @param requestId The ID of the request to withdraw.
     */
    function withdrawRequest(bytes32 requestId) public {
        Request storage request = requests[requestId];
        require(request.requester == msg.sender, "Not the requester");
        require(!request.fulfilled, "Already fulfilled");

        uint256 ethBounty = request.ethBounty;
        uint256 NativeTknBounty = request.NativeTknBounty;

        request.ethBounty = 0;
        request.NativeTknBounty = 0;
        request.fulfilled = true;

        payable(msg.sender).transfer(ethBounty);
        _mint(msg.sender, NativeTknBounty);
        emit RequestDeactivated(requestId);
    }
}
