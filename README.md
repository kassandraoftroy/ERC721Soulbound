# ERC721Soulbound

Here is a simple ERC721 extension for nfts that want to forever be tied to a base nft collection. For example, maybe you want to give an NFT/rights to a specific crypto punk, in such a way that the owner of said crypto punk will always be able to assert/take ownership of the asset.

Thus, soulbound. [Inspired by Vitalik's article](https://vitalik.ca/general/2022/01/26/soulbound.html)

The only addition to IERC721 interface is a reclaim method:

`function reclaim(address claimant, uint256 tokenId) external;`

There is also an added internal method `_soulbind` which should be used in any minting logic of the top level ERC721 contract, to ensure that all minting adheres to the rules of 'soulbinding'

# test

yarn

yarn compile

yarn test
