// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {
    IERC721,
    ERC721,
    ERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {IERC721Soulbound} from "./IERC721Soulbound.sol";

abstract contract ERC721Soulbound is ERC721Enumerable, IERC721Soulbound {

    IERC721 public immutable base;
    // tokenId => baseTokenId (a baseTokenId could bind with many tokenIds)
    mapping(uint256 => uint256) public bind;

    constructor(
        address base_,
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {
        base = IERC721(base_);
    }

    function reclaim(address claimant, uint256 tokenId) public virtual override {
        uint256 baseTokenId = bind[tokenId];
        require(
            base.ownerOf(baseTokenId) == claimant,
            "ERC721Soulbound: claimant not owner of baseTokenId"
        );

        _safeTransfer(ownerOf(tokenId), claimant, tokenId, "");
    }

    function _soulbind(
        uint256 baseTokenId,
        address claimant,
        uint256 tokenId
    ) internal virtual {
        require(
            base.ownerOf(baseTokenId) == claimant,
            "ERC721Soulbound: claimant not owner of baseTokenId"
        );
        bind[tokenId] = baseTokenId;
        _safeMint(claimant, tokenId);
    }
    
}