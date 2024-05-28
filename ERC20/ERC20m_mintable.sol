
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./ERC20.sol";

contract ERC20m is ERC20 {
    uint256 public maxSupply;

    event Burn(address indexed from, uint256 value);
    event Mint(address indexed to, uint256 value);

    constructor(string memory name_, string memory symbol_, uint256 decimals_, uint256 initialSupply, uint256 maxSupply_)
        ERC20(name_, symbol_, decimals_, initialSupply) 
    {
        maxSupply = maxSupply_;
    }

    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "Invalid address");
        require(_totalSupply + amount <= maxSupply, "Minting exceeds max supply");

        balanceOf[to] += amount;
        _totalSupply += amount;
        emit Mint(to, amount);
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        require(balanceOf[from] >= amount, "Insufficient balance to burn");

        balanceOf[from] -= amount;
        _totalSupply -= amount;
        emit Burn(from, amount);
        emit Transfer(from, address(0), amount);
    }
}
