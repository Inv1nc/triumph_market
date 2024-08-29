// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TriumphNFT.sol";

contract MovieFactory {
    struct Movie {
        string title;
        address nftContract;
    }

    struct Theater {
        string name;
        string location;
        address owner;
        mapping(uint256 => bool) moviesEnabled; // movieId => isEnabled
    }

    mapping(uint256 => Movie) public movies;
    mapping(uint256 => Theater) public theaters;
    uint256 public movieCount;
    uint256 public theaterCount;

    event MovieCreated(string title, address nftContract);

    // Function to create a new movie and deploy an associated NFT contract
    function createMovie(string memory _title) public {
        string memory symbol = string(abi.encodePacked(_title, "NFT"));
        MovieNFT movieNFT = new MovieNFT(_title, _title, symbol);

        movies[movieCount] = Movie({
            title: _title,
            nftContract: address(movieNFT)
        });

        emit MovieCreated(_title, address(movieNFT));
        movieCount++;
    }

    // Function for theater owners to register a new theater
    function addTheater(
        string memory _name,
        string memory _location
    ) public {
        theaters[theaterCount].name = _name;
        theaters[theaterCount].location = _location;
        theaters[theaterCount].owner = msg.sender;
        theaterCount++;
    }

    // Function for theater owners to enable a movie in their theater
    function enableMovieInTheater(uint256 theaterId, uint256 movieId) public {
        require(theaters[theaterId].owner == msg.sender, "Not the theater owner");
        theaters[theaterId].moviesEnabled[movieId] = true;
    }

    // Function for users to buy a ticket for a specific movie in a specific theater
    function buyTicket(uint256 movieId, uint256 theaterId, string memory metadataURI) public payable {
        require(theaters[theaterId].moviesEnabled[movieId], "Movie not enabled in this theater");

        MovieNFT movieNFT = MovieNFT(movies[movieId].nftContract);
        movieNFT.mintNFT(msg.sender, metadataURI);
    }

    // Function to get movie details
    function getMovieDetails(uint256 movieId) public view returns (string memory, address) {
        return (movies[movieId].title, movies[movieId].nftContract);
    }

    // Function to get theater details
    function getTheaterDetails(uint256 theaterId) public view returns (string memory, string memory, address) {
        return (theaters[theaterId].name, theaters[theaterId].location, theaters[theaterId].owner);
    }
}
