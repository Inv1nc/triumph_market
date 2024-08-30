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
        uint256 theaterId;
        uint256 noOfSeats;
        mapping(uint256 => bool) moviesEnabled; // movieId => isEnabled
        mapping(uint256 => bool) seatsBooked; // seatNumber => isBooked
    }

    mapping(uint256 => Movie) public movies;
    mapping(uint256 => Theater) public theaters;
    uint256 public movieCount;
    uint256 public theaterCount;

    uint256 public immutable theatreSharePrice = 30;
    uint256 public immutable movieSharePrice = 63;
    uint256 public immutable marketplaceFee = 7;

    event MovieCreated(string title, address nftContract);

    // Function to create a new movie and deploy an associated NFT contract
    function createMovie(string memory _title, uint256 _price) public {
        string memory symbol = string(abi.encodePacked(_title, "NFT"));
        MovieNFT movieNFT = new MovieNFT(_price, _title, symbol);

        movies[movieCount] = Movie({title: _title, nftContract: address(movieNFT)});

        emit MovieCreated(_title, address(movieNFT));
        movieCount++;
    }

    // Function for theater owners to register a new theater
    function addTheater(string memory _name, string memory _location, uint256 _noOfSeats) public {
        theaters[theaterCount].name = _name;
        theaters[theaterCount].location = _location;
        theaters[theaterCount].owner = msg.sender;
        theaters[theaterCount].theaterId = theaterCount;
        theaters[theaterCount].noOfSeats = _noOfSeats;
        theaterCount++;
    }

    // Function for theater owners to enable a movie in their theater
    function enableMovieInTheater(uint256 theaterId, uint256 movieId) public {
        require(theaters[theaterId].owner == msg.sender, "Not the theater owner");
        theaters[theaterId].moviesEnabled[movieId] = true;
    }

    // Function for theater owners to enable a movie in their theater
    function disableMovieInTheater(uint256 theaterId, uint256 movieId) public {
        require(theaters[theaterId].owner == msg.sender, "Not the theater owner");
        theaters[theaterId].moviesEnabled[movieId] = false;
    }

    // Function for users to buy a ticket for a specific movie in a specific theater
    function buyTicket(uint256 movieId, uint256 theaterId, uint256 seatNumber, string memory metadataURI)
        public
        payable
    {
        require(theaters[theaterId].moviesEnabled[movieId], "Movie not enabled in this theater");
        require(seatNumber >= 1 && seatNumber <= theaters[theaterId].noOfSeats, "Invalid seat number");
        require(!theaters[theaterId].seatsBooked[seatNumber], "Seat already booked");

        MovieNFT movieNFT = MovieNFT(movies[movieId].nftContract);

        // Ensure that the correct amount is sent with the transaction
        require(msg.value == movieNFT.price, "Incorrect ticket price");

        // Calculate shares
        uint256 theatreShareAmount = (ticketPrice * theatreShare) / 100;
        uint256 movieShareAmount = (ticketPrice * movieShare) / 100;
        uint256 marketplaceFeeAmount = (ticketPrice * marketplaceFee) / 100;

        // Calculate amounts for distribution
        uint256 totalDistribution = theatreShareAmount + movieShareAmount + marketplaceFeeAmount;
        uint256 remainingAmount = ticketPrice - totalDistribution;

        payable(theaters[theaterId].owner).transfer(theatreShareAmount);
        payable(movies[movieId].nftContract).transfer(movieShareAmount);
        payable(owner).transfer(marketplaceFeeAmount);

        // Refund any excess amount to the user
        if (remainingAmount > 0) {
            payable(msg.sender).transfer(remainingAmount);
        }
        theaters[theaterId].seatsBooked[seatNumber] = true;
        movieNFT.mintNFT(msg.sender, metadataURI);
    }

    function watchTheMovie(uint256 movieId, uint256 theaterId) public {}
    // Function to get movie details

    function getMovieDetails(uint256 movieId) public view returns (string memory, address) {
        return (movies[movieId].title, movies[movieId].nftContract);
    }

    // Function to get theater details
    function getTheaterDetails(uint256 theaterId) public view returns (string memory, string memory, address) {
        return (theaters[theaterId].name, theaters[theaterId].location, theaters[theaterId].owner);
    }
    
    // Function to get Available seats
    function getAvailableSeats(uint256 theaterId) public view returns (uint256[] memory) {
        uint256[] memory availableSeats = new uint256[](theaters[theaterId].noOfSeats);
        for (uint256 i = 1; i <= theaters[theaterId].noOfSeats; i++) {
            if (!theaters[theaterId].seatsBooked[i + 1]) availableSeats[i] = i;
        }

        return availableSeats;
    }
}
