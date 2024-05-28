// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Initializable.sol";

contract ERC20mi is Initializable {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 internal _totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed from, uint256 value);
    event Mint(address indexed to, uint256 value);

    uint256 public maxSupply;

    /**
     * @dev Initializes the ERC20 token with the given details and initial supply.
     * @param name_ The name of the token.
     * @param symbol_ The symbol of the token.
     * @param decimals_ The number of decimals for the token.
     * @param supply_ The initial supply of the token.
     * @param maxSupply_ The maximum supply of the token.
     */
    function initialize(
        string memory name_, 
        string memory symbol_, 
        uint256 decimals_, 
        uint256 supply_, 
        uint256 maxSupply_
    ) initializer public {
        _name = name_;
        _symbol = symbol_;
        _decimals = uint8(decimals_);
        _totalSupply = supply_ * 10 ** decimals_;
        balanceOf[msg.sender] = _totalSupply;
        maxSupply = maxSupply_;
    }

    function name() public view returns (string memory) { return _name; }
    function symbol() public view returns (string memory) { return _symbol; }
    function decimals() public view returns (uint8) { return _decimals; }
    function totalSupply() public view returns (uint256) { return _totalSupply; }

    function transfer(address to, uint amount) external {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint amount) external {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Allowance exceeded");
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }

    function approve(address spender, uint amount) external {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(balanceOf[from] >= amount, "Insufficient balance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
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
