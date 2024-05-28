// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ERC20.sol";
import "./IPing.sol";

contract ERC20pr is ERC20 {
    address public admin;
    mapping(bytes32 => mapping(address => bool)) private roles;
    mapping(bytes32 => address[]) private roleAddresses;

    bytes32 public constant ROUTER = keccak256("ROUTER");
    bytes32 public constant PING = keccak256("PING");

    modifier onlyAdmin {require(msg.sender == admin, "Caller is not the admin");_;}
    
    constructor(
        string memory name_, 
        string memory symbol_, 
        uint256 decimals_, 
        uint256 initialSupply
    ) ERC20(name_, symbol_, decimals_, initialSupply) {
        admin = msg.sender;
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(amount > 0, "Transfer amount must be greater than zero");
        super._transfer(from, to, amount);

        if (roles[ROUTER][from] || roles[ROUTER][to]) {
            for (uint256 i = 0; i < roleAddresses[PING].length; i++) {
                IPing(roleAddresses[PING][i]).ping(tx.origin, msg.sender, from, to, amount, amount);
            }
        }
    }

    function getAddresses(string memory role) public view returns (address[] memory) {
        return roleAddresses[keccak256(abi.encodePacked(role))];
    }

    function setAddresses(address[] memory addresses, string memory role, bool status) external onlyAdmin {
        bytes32 roleHash = keccak256(abi.encodePacked(role));
        for (uint256 i = 0; i < addresses.length; i++) {
            roles[roleHash][addresses[i]] = status;
            if (status) {
                roleAddresses[roleHash].push(addresses[i]);
            } else {
                removeAddressFromList(roleAddresses[roleHash], addresses[i]);
            }
        }
    }

    function removeAddressFromList(address[] storage list, address addr) internal {
        uint256 length = list.length;
        for (uint256 i = 0; i < length; i++) {
            if (list[i] == addr) {
                list[i] = list[length - 1];
                list.pop();
                break;
            }
        }
    }
}
