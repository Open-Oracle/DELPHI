// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Proxy {
    address public admin;
    address public implementation;

    /**
     * @dev Initializes the proxy with the implementation contract address.
     * @param _implementation The address of the implementation contract.
     */
    constructor(address _implementation) {
        admin = msg.sender;
        implementation = _implementation;
    }

    /**
     * @dev Upgrades the implementation contract address.
     * @param newImplementation The address of the new implementation contract.
     */
    function upgrade(address newImplementation) external {
        require(msg.sender == admin, "Only admin can upgrade");
        implementation = newImplementation;
    }

    fallback() external payable {
        address impl = implementation;
        require(impl != address(0), "Implementation contract not set");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    receive() external payable {}
}
