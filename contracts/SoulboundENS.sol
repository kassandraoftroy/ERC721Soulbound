// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {ERC721Soulbound} from "./ERC721Soulbound.sol";
import {Base64} from "./Base64.sol";

contract SoulboundENS is ERC721Soulbound {

    address private constant _ENS = 0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85;
    string private constant _SYMBOL = "SOUL";
    string private constant _NAME = "Souls bound to ENS Domains";
    uint256 public constant PRICE = 1;

    mapping(uint256 => bytes) public image;

    constructor() ERC721Soulbound(_ENS, _NAME, _SYMBOL) {} // solhint-disable-line no-empty-blocks

    function soulbind(uint256 ensTokenId, bytes memory yourSoulImage) external payable {
        require(msg.value == PRICE, "SoulboundENS: you must burn one wei to bind your soul");

        require(
            keccak256(image[ensTokenId]) == keccak256(""),
            "SoulboundENS: one soul per ENS"
        );
        require(
            keccak256(yourSoulImage) != keccak256(""),
            "SoulboundENS: soul cannot be empty"
        );
        image[ensTokenId] = yourSoulImage;

        _soulbind(ensTokenId, msg.sender, totalSupply() + 1);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        // solhint-disable-next-line max-line-length, quotes
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Soul #', _uint2str(tokenId), '", "description": "Souls bonded to ENS Domains", "image": "data:image/svg+xml;base64,', Base64.encode(image[bind[tokenId]]), '"}'))));

        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function _uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}