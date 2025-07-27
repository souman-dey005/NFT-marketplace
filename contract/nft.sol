// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC721 {
    function transferFrom(address from, address to, uint tokenId) external;
    function getApproved(uint tokenId) external view returns (address);
}

contract MinimalNFTMarketplace {
    struct Listing {
        address seller;
        uint price;
    }

    mapping(address => mapping(uint => Listing)) public listings;

    // Function 1: List an NFT for sale
    function listNFT(address nftContract, uint tokenId, uint price) external {
        require(price > 0, "Price must be above zero");
        IERC721 nft = IERC721(nftContract);
        require(nft.getApproved(tokenId) == address(this), "Marketplace not approved");
        listings[nftContract][tokenId] = Listing(msg.sender, price);
    }

    // Function 2: Buy a listed NFT
    function buyNFT(address nftContract, uint tokenId) external payable {
        Listing memory item = listings[nftContract][tokenId];
        require(item.price > 0, "Item not listed");
        require(msg.value >= item.price, "Insufficient payment");

        delete listings[nftContract][tokenId];
        payable(item.seller).transfer(msg.value);
        IERC721(nftContract).transferFrom(item.seller, msg.sender, tokenId);
    }
}

