# ERC721Soulbound

*EDIT (Oct 2022): This "soulbound" repo is a bit of a misnomer as the concept was less defined (or at least less well understood by me) when the code was written. This repo is an example of binding ERC721s to an already existing ERC721 on the network. If you are looking for SBTs as they are understood today (attestation/credentials that are non-trnasferrable but can potentially be revoked) then you are NOT in the right place. Enjoy :)*

Here is a simple ERC721 extension for nfts that want to forever be tied to a base nft collection. For example, maybe you want to give non-fungible rights or some auxiliary NFT (e.g. an in-game item) to a specific CryptoPunk or ENS domain, in such a way that the owner of said CryptoPunk or ENS name will always be able to assert/take ownership of the asset.

Thus, soulbound. [Inspired by Vitalik's blogpost](https://vitalik.ca/general/2022/01/26/soulbound.html)

The IERC721Soulbound interface extends IERC721 with a few new methods:

```
    function soul() external view returns (address);

    function boundTo(uint256 tokenId) external view returns (uint256);
 
    function soulOwner(uint256 tokenId) external view returns (address);

    function reclaim(address claimant, uint256 tokenId) external;

    function canReclaim(address claimant, uint256 tokenId) external view returns (bool);
```

`soul()` Address of the 'soul' ERC721 collection.

`boundTo(uint256 tokenId)` The tokenId of the soul collection that this token is bound to.

`soulOwner(uint256 tokenId)` The rightful owner of the token which may differ from `ownerOf(tokenId)`. The soulOwner can reclaim the token if they are not currently the holder.

`reclaim(address claimant, uint256 tokenId)` Reclaim tokenId to the soulOwner.

`canReclaim(address claimant, uint256 tokenId)` Check if an address can reclaim a token.

## test
Set up .env file by copying the example and adding your alchemy key:
```
$ cp .env.example .env
```

Install dependencies:
```
yarn
```

Compile:
```
yarn compile
```

Test:
```
yarn test
```
