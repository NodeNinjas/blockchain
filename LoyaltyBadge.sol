// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract LoyaltyBadge is ERC721 {
    uint256 public nextTokenId;
    address public admin;

    constructor() ERC721('LoyaltyBadge', 'LOY') {
        admin = msg.sender;
    }

    function mint(address to) external {
        _mint(to, nextTokenId);
        nextTokenId++;
    }
}