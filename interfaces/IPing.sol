// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IPing {
    function ping(
        address txOrigin, 
        address msgSender, 
        address tknSender, 
        address tknRecipient, 
        uint256 amount, 
        uint256 netAmount
    ) external;
}
