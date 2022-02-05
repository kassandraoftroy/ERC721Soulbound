// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IERC721Soulbound is IERC721 {
    function reclaim(address claimant, uint256 tokenId) external;
}