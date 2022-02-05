// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {
    IERC721,
    ERC721,
    ERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {IERC721Soulbound} from "./IERC721Soulbound.sol";

abstract contract ERC721Soulbound is ERC721Enumerable, IERC721Soulbound {

    IERC721 public immutable bonded;
    mapping(uint256 => uint256) public bondedTo; // tokenId => bondedTokenId

    constructor(
        address bonded_,
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {
        bonded = IERC721(bonded_);
    }

    function reclaim(address claimant, uint256 tokenId) public virtual override {
        uint256 bondedTokenId = bondedTo[tokenId];
        require(
            bonded.ownerOf(bondedTokenId) == claimant,
            "ERC721Soulbound: claimant not owner of bondedTokenId"
        );

        _safeTransfer(ownerOf(tokenId), claimant, tokenId, "");
    }

    function _soulbond(
        uint256 bondedTokenId,
        address claimant,
        uint256 tokenId
    ) internal virtual {
        require(
            bonded.ownerOf(bondedTokenId) == claimant,
            "ERC721Soulbound: claimant not owner of bondedTokenId"
        );
        bondedTo[tokenId] = bondedTokenId;
        _safeMint(claimant, tokenId);
    }
    
}