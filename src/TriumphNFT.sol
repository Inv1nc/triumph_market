// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TriumphNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    string public movieTitle;

    constructor(string memory _movieTitle, string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        movieTitle = _movieTitle;
    }

    function mintNFT(address to, string memory metadataURI) public onlyOwner returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _mint(to, tokenId);
        _setTokenURI(tokenId, metadataURI);
        return tokenId;
    }
}
