// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";

contract TriumphNFT is ERC721, Ownable {
    string public movieTitle;
    uint256 public price;
    uint256 public tokenIdCounter;

    constructor(uint256 _price, string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
        Ownable(msg.sender)
    {
        movieTitle = _name;
        price = _price;
    }

    function mintNFT(address to, string memory metadataURI) public onlyOwner returns (uint256) {
        uint256 tokenId = tokenIdCounter++;
        _mint(to, tokenId);
        // _setTokenURI(tokenId, metadataURI); added for future change
        return tokenId;
    }
}
