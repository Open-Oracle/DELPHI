// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../requestManager.sol";
import "../../interfaces/IOracleCallback.sol";

/*
 * @title oracleRequest
 * @dev This contract extends the RequestManager contract and manages oracle requests.
 */
abstract contract oracleRequest is requestManager {
    event OracleRequestCreated(
        bytes32 indexed requestId,
        address indexed requester,
        uint256 ethBounty,
        uint256 NativeTknBounty,
        address designatedFulfiller,
        bool isOpenToAny);
    event OracleRequestFulfilled(bytes32 indexed requestId, bytes32 indexed fulfillmentId, bool correct);

    /*
     * @dev Creates a new oracle request.
     * @param data The data for the oracle request.
     * @param designatedFulfiller The address designated to fulfill the request.
     * @param isOpenToAny Whether the request is open to any fulfiller.
     * @param nativeTokenBounty The amount of tokens staked for the request.
     * @param tax The tax percentage for the request (100 = 1%).
     * @param taxRecipient The address that will receive the tax.
     * @param maturity The timestamp when the request matures.
     * @return bytes32 The ID of the newly created oracle request.
     */
    function createOracleRequest(
        bytes memory data,
        address designatedFulfiller,
        bool isOpenToAny,
        uint128 nativeTokenBounty,
        uint16 tax,
        address taxRecipient,
        uint256 maturity)
        public payable virtual returns (bytes32) {
            OracleRequestData memory oracleData = OracleRequestData({
                data: data,
                designatedFulfiller: designatedFulfiller,
                isOpenToAny: isOpenToAny,
                verified: false
            });
            bytes32 requestId = createRequest(nativeTokenBounty, 3, abi.encode(oracleData), tax, taxRecipient, maturity);
            emit OracleRequestCreated(requestId, msg.sender, msg.value, nativeTokenBounty, designatedFulfiller, isOpenToAny);
            return requestId;
    }

    /*
     * @dev Fulfills an existing oracle request.
     * @param requestId The ID of the oracle request to fulfill.
     * @param data The data for fulfilling the oracle request.
     */
    function fulfillOracleRequest(bytes32 requestId, bytes memory data) public virtual {
        Request storage request = requests[requestId];
        require(block.timestamp >= request.maturity, "Request not matured yet");

        OracleRequestData memory oracleData = abi.decode(request.data, (OracleRequestData));

        bytes32 fulfillmentId = keccak256(abi.encodePacked(requestId, msg.sender, block.timestamp, nonce));
        fulfillments[requestId].push(OracleFulfillment({
            fulfiller: msg.sender,
            data: data,
            verified: false
        }));

        if (!oracleData.isOpenToAny) {
            require(msg.sender == oracleData.designatedFulfiller, "Only designated fulfiller can fulfill this request");
            fulfillRequest(requestId);
            emit OracleRequestFulfilled(requestId, fulfillmentId, true);
            IOracleCallback(request.requester).onOracleVerified(requestId, true);
        }
    }

    /*
     * @dev Verifies an existing oracle request fulfillment.
     * @param requestId The ID of the oracle request.
     * @param fulfillmentId The ID of the fulfillment to verify.
     * @param correct Indicates whether the fulfillment is correct.
     */
    function verifyOracleRequest(bytes32 requestId, bytes32 fulfillmentId, bool correct) public virtual {
        Request storage request = requests[requestId];
        require(block.timestamp >= request.maturity, "Request not matured yet");

        OracleRequestData memory oracleData = abi.decode(request.data, (OracleRequestData));

        require(oracleData.isOpenToAny, "Verification not needed for designated fulfiller");

        OracleFulfillment[] storage requestOracleFulfillments = fulfillments[requestId];
        bool found = false;

        for (uint256 i = 0; i < requestOracleFulfillments.length; i++) {
            if (keccak256(abi.encodePacked(requestOracleFulfillments[i].fulfiller, requestOracleFulfillments[i].data)) == fulfillmentId) {
                require(msg.sender == request.requester || msg.sender == requestOracleFulfillments[i].fulfiller, 
                    "Only requester or fulfiller can verify"
                );
                requestOracleFulfillments[i].verified = true;
                found = true;
                break;
            }
        }

        require(found, "OracleFulfillment not found");

        fulfillRequest(requestId);
        request.fulfilled = true;

        emit OracleRequestFulfilled(requestId, fulfillmentId, correct);
        IOracleCallback(request.requester).onOracleVerified(requestId, correct);
    }
}
