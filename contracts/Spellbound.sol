// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {
    ERC721,
    ERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {ERC721Soulbound} from "./ERC721Soulbound.sol";
import {Base64} from "./Base64.sol";

contract Spellbound is
    ERC721Soulbound,
    ERC721Enumerable,
    ERC721Burnable
{
    address private constant _COVEN = 0x5180db8F5c931aaE63c74266b211F580155ecac8;
    string private constant _SYMBOL = "SPELLBOUND";
    string private constant _NAME = "Spells soulbound to Crypto Coven witches";
    uint256 public constant PRICE = 1;

    mapping(uint256 => bytes) public spell;

    constructor() ERC721Soulbound(_COVEN, _NAME, _SYMBOL) {} // solhint-disable-line no-empty-blocks

    function mint(uint256 witchId, string[3] memory spellLines) external payable {
        require(msg.value == PRICE, "Spellbound: you must burn one wei for spell to be binding");

        // enforce custom rule: one bound nft per base nft
        require(
            keccak256(spell[witchId]) == keccak256(""),
            "Spellbound: a witch can only be bound to one spell"
        );

        // check length of lines
        for (uint256 i = 0; i < 3; i++) {
            require(bytes(spellLines[i]).length <= 42, "Spellbound: spell line exceeds max length");
        }
        spell[witchId] = abi.encode(spellLines[0], spellLines[1], spellLines[2]);

        _soulbind(witchId, msg.sender, totalSupply() + 1);
    }

    function burn(uint256 tokenId) public virtual override {
        require(soulOwner(tokenId) == msg.sender, "Spellbound: only soulOwner can release spell");
        ERC721Burnable.burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        uint256 witchId = boundTo(tokenId);
        (string memory line1, string memory line2, string memory line3) =
            abi.decode(spell[witchId], (string, string, string));
        
        string[10] memory parts;
        // solhint-disable max-line-length, quotes
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: courier; font-size: 11px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">SPELL #';
        parts[1] = _uint2str(tokenId);
        parts[2] = " SOULBOUND TO WITCH #";
        parts[3] = _uint2str(boundTo(tokenId));
        parts[4] = '</text><text x="10" y="60" class="base">';
        parts[5] = line1;
        parts[6] = '</text><text x="10" y="80" class="base">';
        parts[7] = line2;
        parts[8] = '</text><text x="10" y="100" class="base">';
        parts[9] = line3;
        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
        output = string(abi.encodePacked(output, parts[9]));
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Spell #', _uint2str(tokenId), '", "description": "Spells soulbound to Crypto Coven witches", "image": "data:image/svg+xml;base64,', output, '"}'))));

        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, ERC721) returns (bool) {
        return ERC721Enumerable.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721Enumerable, ERC721) {
        ERC721Enumerable._beforeTokenTransfer(from, to, tokenId);
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