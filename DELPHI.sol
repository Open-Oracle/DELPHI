// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./DELPHI/requestBundler.sol";

/**
 * @title DELPHI
 * @dev This contract combines all request types (RNG, Message, Keeper, Oracle) and manages the Oracle of Delphi token. 
 * It inherits from RNGRequest, MessageRequest, KeeperRequest, and OracleRequest contracts, which in turn 
 * inherit from RequestManager and ERC20p, ensuring comprehensive functionality for token management and 
 * request handling.
 */
contract DELPHI is requestBundler {

    /**
     * @dev Initializes the DELPHI contract with token details and initial reward values.
     * It sets the token name, symbol, decimals, and maximum supply, and initializes the reward values.
     * @param name_ The name of the token.
     * @param symbol_ The symbol of the token.
     * @param decimals_ The number of decimals for the token.
     * @param supply_ The initial supply of the token.
     * @param maxSupply_ The maximum supply of the token.
     */
    function initialize(
        string memory name_, 
        string memory symbol_, 
        uint8 decimals_, 
        uint256 supply_, 
        uint256 maxSupply_,
        uint256 reward_,
        uint256 halvingPoint_
    ) initializer public {
        ERC20mi.initialize(name_, symbol_, decimals_, supply_, maxSupply_);
        oracleStorage.initializeOracleStorage(msg.sender, reward_, halvingPoint_);
    }


    /**
     * @dev Function to toggle minting by the admin.
     */
    function toggleMinting() public onlyAdmin {
        mintingEnabled = !mintingEnabled;
        emit MintingToggled(mintingEnabled);
    }

    /**
     * @dev Creates a new RNG request.
     * @param blocksFromNow The number of blocks from the current block to determine the RNG.
     * @param nativeTokenBounty The amount of tokens staked for the request.
     * @param tax The tax percentage for the request (100 = 1%).
     * @param taxRecipient The address that will receive the tax.
     * @param maturity The timestamp when the request matures.
     * @return bytes32 The ID of the newly created RNG request.
     */
    function createRNGRequest(
        uint256 blocksFromNow, 
        uint128 nativeTokenBounty, 
        uint16 tax, 
        address taxRecipient, 
        uint128 maturity
    ) 
        public 
        payable 
        override 
        returns (bytes32) 
    {
        return RNGrequest.createRNGRequest(blocksFromNow, nativeTokenBounty, tax, taxRecipient, maturity);
    }

    /**
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
        uint256 maturity
    ) 
        public 
        payable 
        override 
        returns (bytes32) 
    {
        return messageRequest.createMessageRequest(hashedAnswer, nativeTokenBounty, tax, taxRecipient, maturity);
    }

    /**
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
        uint256 maturity
    ) 
        public 
        payable 
        override 
        returns (bytes32) 
    {
        return keeperRequest.createKeeperRequest(targetAddress, callData, nativeTokenBounty, tax, taxRecipient, maturity);
    }

    /**
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
        uint256 maturity
    ) 
        public 
        payable 
        override 
        returns (bytes32) 
    {
        return oracleRequest.createOracleRequest(
            data, designatedFulfiller, isOpenToAny, nativeTokenBounty, tax, taxRecipient, maturity
        );
    }

    /**
     * @dev Fulfills an existing RNG request.
     * @param requestId The ID of the RNG request to fulfill.
     * This function calls the parent contract's fulfillRNGRequest method and then distributes the reward.
     */
    function fulfillRNGRequest(bytes32 requestId) public override {
        RNGrequest.fulfillRNGRequest(requestId);
        distributeReward(requestId, msg.sender);
    }

    /**
     * @dev Fulfills an existing message request.
     * @param requestId The ID of the message request to fulfill.
     * @param answer The answer to verify against the hashed answer.
     * This function calls the parent contract's fulfillMessageRequest method and then distributes the reward.
     */
    function fulfillMessageRequest(bytes32 requestId, string memory answer) public override {
        messageRequest.fulfillMessageRequest(requestId, answer);
        distributeReward(requestId, msg.sender);
    }

    /**
     * @dev Executes an existing keeper request.
     * @param requestId The ID of the keeper request to execute.
     * This function calls the parent contract's executeKeeperRequest method and then distributes the reward.
     */
    function executeKeeperRequest(bytes32 requestId) public override {
        keeperRequest.executeKeeperRequest(requestId);
        distributeReward(requestId, msg.sender);
    }

    /**
     * @dev Fulfills an existing oracle request.
     * @param requestId The ID of the oracle request to fulfill.
     * @param data The data for fulfilling the oracle request.
     * This function calls the parent contract's fulfillOracleRequest method. 
     * If the request is fulfilled, it then distributes the reward.
     */
    function fulfillOracleRequest(bytes32 requestId, bytes memory data) public override {
        oracleRequest.fulfillOracleRequest(requestId, data);
        if (!requests[requestId].fulfilled) {return;}
        distributeReward(requestId, msg.sender);
    }

    /**
     * @dev Verifies an existing oracle request fulfillment.
     * @param requestId The ID of the oracle request.
     * @param fulfillmentId The ID of the fulfillment to verify.
     * @param correct Indicates whether the fulfillment is correct.
     * This function calls the parent contract's verifyOracleRequest method and then distributes the reward.
     */
    function verifyOracleRequest(bytes32 requestId, bytes32 fulfillmentId, bool correct) public override {
        oracleRequest.verifyOracleRequest(requestId, fulfillmentId, correct);
        distributeReward(requestId, msg.sender);
    }

    /**
     * @dev Internal function to distribute rewards after fulfilling a request.
     * @param requestId The ID of the fulfilled request.
     * @param rewardRecipient The address to receive the reward.
     * This function distributes the reward, handling tax deductions and minting the appropriate 
     * amounts of tokens to the requester, reward recipient, and tax recipient.
     */
    function distributeReward(bytes32 requestId, address rewardRecipient) internal {
        Request storage request = requests[requestId];

        // Calculate tax amount and net reward
        uint256 taxAmount = (reward * request.tax) / 10000;
        uint256 netReward = reward - taxAmount;
        uint256 halfReward = netReward / 2;

        // Calculate token and ETH tax amounts
        uint256 nativeTokenBounty = (request.NativeTknBounty * request.tax) / 10000;
        uint256 ethTaxAmount = (request.ethBounty * request.tax) / 10000;

        if (mintingEnabled) {
            // Mint tokens and transfer ETH to the tax recipient
            _mint(request.taxRecipient, taxAmount);
            _mint(request.taxRecipient, nativeTokenBounty);
            _mint(request.requester, halfReward);
            _mint(rewardRecipient, halfReward + request.NativeTknBounty - nativeTokenBounty);
        }
      
        // Transfer ETH to the tax and reward recipient 
        payable(request.taxRecipient).transfer(ethTaxAmount);
        payable(rewardRecipient).transfer(request.ethBounty - ethTaxAmount);
    }

    function halving() public {
        uint256 currentSupply = totalSupply();
        while (currentSupply >= nextHalvingPoint) {
            reward = reward / 2;
            nextHalvingPoint = nextHalvingPoint * 2;
        }
    }
}
