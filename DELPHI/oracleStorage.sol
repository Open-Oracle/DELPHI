// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../ERC20/Initializable.sol";

/*
 * @title OracleStorage
 * @dev This contract defines the basic storage and events for the token and requests.
 * @note storage allows for use of proxy-upgradable contracts
 */
abstract contract oracleStorage is Initializable {
    uint128 public nonce;            // Nonce for generating unique request IDs

    address public admin;            // Admin address
    bool public mintingEnabled;      // Flag to enable/disable minting

    // Variables for handling rewards
    uint256 public reward;               // Reward amount for fulfilling requests
    uint256 public nextHalvingPoint;     // Last point where rewards were halved

    // Structs to store data for different types of requests
    struct RNGRequestData {
        uint64 blockNumber;              // Block number at which RNG is determined
    }

    struct MessageRequestData {
        bytes32 hashedAnswer;            // Hashed answer for verification
    }

    struct KeeperRequestData {
        address targetAddress;           // Address to call
        bytes callData;                  // Data to be sent to the target address
    }

    struct OracleRequestData {
        bytes data;                      // Data for oracle request
        address designatedFulfiller;     // Address designated to fulfill the request
        bool isOpenToAny;                // Whether the request is open to any fulfiller
        bool verified;                   // Whether the request has been verified
    }

    struct OracleFulfillment {
        address fulfiller;               // Address of the fulfiller
        bytes data;                      // Data fulfilled
        bool verified;                   // Whether the fulfillment has been verified
    }

    struct Request {
        address requester;               // Address of the requester
        uint128 ethBounty;               // Amount of ETH staked
        uint128 NativeTknBounty;         // Amount of tokens staked
        bool fulfilled;                  // Whether the request has been fulfilled
        uint8 requestType;               // Type of request (0: RNG, 1: Message, 2: Keeper, 3: Oracle)
        bytes data;                      // Encoded data specific to the request type
        uint16 tax;                      // Tax percentage (100 = 1%)
        address taxRecipient;            // Address that will receive the tax
        uint256 maturity;                // Timestamp when the request matures
    }

    // Mappings to store requests and fulfillments by request ID
    mapping(bytes32 => Request) public requests;
    mapping(bytes32 => OracleFulfillment[]) public fulfillments;

    // Events for various actions
    event RequestCreated(
        bytes32 indexed requestId,
        address indexed requester,
        uint256 ethBounty,
        uint256 NativeTknBounty,
        uint8 requestType,
        uint16 tax,
        address taxRecipient);
    event RequestFulfilled(bytes32 indexed requestId);
    event RequestDeactivated(bytes32 indexed requestId);
    event OracleRequestVerified(bytes32 indexed requestId, bool correct);
    event MintingToggled(bool enabled);

    // Modifier to restrict function access to admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    /**
     * @dev Initializes the OracleStorage contract.
     * @param _admin The address of the admin.
     * @param _reward The initial reward amount.
     * @param _nextHalvingPoint The initial halving point for rewards.
     */
    function initializeOracleStorage(address _admin, uint256 _reward, uint256 _nextHalvingPoint) internal initializer {
        admin = _admin;
        reward = _reward;
        nextHalvingPoint = _nextHalvingPoint;
    }
}
