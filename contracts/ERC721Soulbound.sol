// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {
    IERC721,
    ERC721
} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC721Soulbound} from "./IERC721Soulbound.sol";

abstract contract ERC721Soulbound is ERC721, IERC721Soulbound {
    // base ERC721 contract whose ids bind to this collection
    IERC721 private immutable _soul;
    // tokenId => soulId (a soulId MAY bind with many tokenIds)
    mapping(uint256 => uint256) private _boundTo;

    constructor(
        address soul_,
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {
        _soul = IERC721(soul_);
    }

    function reclaim(address claimant, uint256 tokenId) public virtual override {
        require(canReclaim(claimant, tokenId), "ERC721Soulbound: claimant cannot reclaim");
        emit Reclaim(tokenId, _boundTo[tokenId], claimant);
        
        _safeTransfer(ownerOf(tokenId), claimant, tokenId, "");
    }

    function soul() public virtual override view returns (address) {
        return address(_soul);
    }

    function soulOwner(uint256 tokenId) public virtual override view returns (address) {
        return _soul.ownerOf(_boundTo[tokenId]);
    }

    function boundTo(uint256 tokenId) public virtual override view returns (uint256) {
        return _boundTo[tokenId];
    }

    function canReclaim(
        address claimant,
        uint256 tokenId
    ) public virtual override view returns (bool) {
        address soulOwner_ = soulOwner(tokenId);
        return (soulOwner_ != ownerOf(tokenId)) && (soulOwner_ == claimant);
    }

    function _soulbind(
        uint256 soulId,
        address claimant,
        uint256 tokenId
    ) internal virtual {
        require(
            _soul.ownerOf(soulId) == claimant,
            "ERC721Soulbound: claimant not owner of soulId"
        );
        emit Soulbind(tokenId, soulId, claimant);
        _boundTo[tokenId] = soulId;

        _safeMint(claimant, tokenId);
    }
    
}