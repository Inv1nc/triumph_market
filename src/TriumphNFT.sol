// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721, ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MovieNFT is ERC721URIStorage, Ownable {
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
        tokenIdCounter++;
        _mint(to, tokenIdCounter);
        _setTokenURI(tokenIdCounter, metadataURI);
        return tokenIdCounter;
    }
}
