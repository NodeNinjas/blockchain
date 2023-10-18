// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract TrustworthyBadge is ERC721 {
    uint256 public nextTokenId;
    address public admin;

    constructor() ERC721('TrustworthyBadge', 'TRU') {
        admin = msg.sender;
    }

    function mint(address to) external {
        require(msg.sender == admin, "only admin can mint");
        _mint(to, nextTokenId);
        nextTokenId++;
    }
}