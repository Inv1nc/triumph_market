// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TriumphNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TriumphMarketPlace is Ownable {
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
        mapping(uint256 => uint256) theatreChargeOfMovie; // movieId => isEnabled
        mapping(uint256 => bool) seatsBooked; // seatNumber => isBooked
    }

    mapping(uint256 => Movie) public movies;
    mapping(uint256 => Theater) public theaters;
    uint256 public movieCount;
    uint256 public theaterCount;

    uint256 public immutable theatreShare = 30;
    uint256 public immutable movieShare = 63;
    uint256 public immutable marketplaceFeePercentage = 7;

    event MovieCreated(string title, address nftContract);

    constructor() Ownable(msg.sender) {}
    // Function to create a new movie and deploy an associated NFT contract

    function createMovie(string memory _title, uint256 _price) public {
        string memory symbol = string(abi.encodePacked(_title, "NFT"));
        TriumphNFT movieNFT = new TriumphNFT(_price, _title, symbol);

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
    function enableMovieInTheater(uint256 theaterId, uint256 movieId, uint256 theatreChargeOfMovie) public {
        require(theaters[theaterId].owner == msg.sender, "Not the theater owner");
        theaters[theaterId].theatreChargeOfMovie[movieId] = theatreChargeOfMovie;
    }

    // Function for theater owners to enable a movie in their theater
    function disableMovieInTheater(uint256 theaterId, uint256 movieId) public {
        require(theaters[theaterId].owner == msg.sender, "Not the theater owner");
        theaters[theaterId].theatreChargeOfMovie[movieId] = 0;
    }

    // Function for users to buy a ticket for a specific movie in a specific theater
    function buyTicket(uint256 movieId, uint256 theaterId, uint256 seatNumber, string memory metadataURI)
        public
        payable
    {
        uint256 theaterChargeOfMovie = theaters[theaterId].theatreChargeOfMovie[movieId];
        require(theaterChargeOfMovie != 0, "Movie not enabled in this theater");

        require(seatNumber >= 1 && seatNumber <= theaters[theaterId].noOfSeats, "Invalid seat number");
        require(!theaters[theaterId].seatsBooked[seatNumber], "Seat already booked");

        TriumphNFT movieNFT = TriumphNFT(movies[movieId].nftContract);
        uint256 ticketCharges = movieNFT.price() + theaterChargeOfMovie;
        uint256 marketplaceFeeAmount = (ticketCharges * marketplaceFeePercentage) / 100;
        uint256 ticketPrice = ticketCharges + marketplaceFeeAmount;

        // Ensure that the correct amount is sent with the transaction
        require(msg.value == ticketPrice, "Incorrect ticket price");

        payable(theaters[theaterId].owner).transfer(theaterChargeOfMovie);
        payable(movies[movieId].nftContract).transfer(movieNFT.price());
        payable(owner()).transfer(marketplaceFeeAmount);

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
            if (!theaters[theaterId].seatsBooked[i]) availableSeats[i] = i;
        }

        return availableSeats;
    }

    //Function to get the theater charges of a movie in a theater
    function getTheaterCharges(uint256 theaterId, uint256 movieId) public view returns (uint256) {
        return theaters[theaterId].theatreChargeOfMovie[movieId];
    }

    //Function to check seat availability
    function isSeatAvailable(uint256 theaterId, uint256 seatNumber) public view returns (bool) {
        return !theaters[theaterId].seatsBooked[seatNumber];
    }
}
