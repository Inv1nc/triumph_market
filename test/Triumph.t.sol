// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/TriumphMarketPlace.sol";
import "../src/TriumphNFT.sol";

contract TriumphMarketPlaceTest is Test {
    TriumphMarketPlace public marketplace;
    address public owner = address(0xABCD);
    address public theaterOwner = address(0x1234);
    address public user = address(0x5678);

    function setUp() public {
        // Deploy the TriumphMarketPlace contract
        vm.prank(owner);
        marketplace = new TriumphMarketPlace();
    }

    function testCreateMovie() public {
        // Set up a test to create a movie
        vm.prank(owner); // Sets the next call to be made by `owner`
        string memory movieTitle = "Test Movie";
        uint256 moviePrice = 1 ether;

        marketplace.createMovie(movieTitle, moviePrice);

        // Retrieve the movie details and assert correctness
        (string memory title, address nftContract) = marketplace.getMovieDetails(0);
        assertEq(title, movieTitle, "Movie title should match");
        assertTrue(nftContract != address(0), "NFT contract address should be set");
    }

    function testAddTheater() public {
        // Test adding a theater
        vm.prank(theaterOwner);
        string memory theaterName = "Test Theater";
        string memory location = "Test Location";
        uint256 noOfSeats = 100;

        marketplace.addTheater(theaterName, location, noOfSeats);

        // Retrieve the theater details and assert correctness
        (string memory name, string memory loc, address owner) = marketplace.getTheaterDetails(0);
        assertEq(name, theaterName, "Theater name should match");
        assertEq(loc, location, "Location should match");
        assertEq(owner, theaterOwner, "Theater owner should match");
    }

    function testEnableMovieInTheater() public {
        // Create movie
        vm.prank(owner);
        string memory movieTitle = "Test Movie";
        uint256 moviePrice = 1 ether;
        marketplace.createMovie(movieTitle, moviePrice);

        // Add theater
        vm.prank(theaterOwner);
        string memory theaterName = "Test Theater";
        string memory location = "Test Location";
        uint256 noOfSeats = 100;
        marketplace.addTheater(theaterName, location, noOfSeats);

        // Enable movie in theater
        uint256 theaterId = 0;
        uint256 movieId = 0;
        uint256 theatreChargeOfMovie = 0.5 ether;

        vm.prank(theaterOwner);
        marketplace.enableMovieInTheater(theaterId, movieId, theatreChargeOfMovie);

        // Assert the movie is enabled in the theater
        uint256 charge = marketplace.getTheaterCharges(theaterId, movieId);
        assertEq(charge, theatreChargeOfMovie, "Theatre charge should match the set value");
    }

    function testDisableMovieInTheater() public {
        // Create movie
        vm.prank(owner);
        string memory movieTitle = "Test Movie";
        uint256 moviePrice = 1 ether;
        marketplace.createMovie(movieTitle, moviePrice);

        // Add theater
        vm.prank(theaterOwner);
        string memory theaterName = "Test Theater";
        string memory location = "Test Location";
        uint256 noOfSeats = 100;
        marketplace.addTheater(theaterName, location, noOfSeats);

        // Enable movie in theater
        uint256 theaterId = 0;
        uint256 movieId = 0;
        uint256 theatreChargeOfMovie = 0.5 ether;

        vm.prank(theaterOwner);
        marketplace.enableMovieInTheater(theaterId, movieId, theatreChargeOfMovie);

        // Disable movie in theater
        vm.prank(theaterOwner);
        marketplace.disableMovieInTheater(theaterId, movieId);

        // Assert the movie is disabled in the theater
        uint256 charge = marketplace.getTheaterCharges(theaterId, movieId);

        assertEq(charge, 0, "Theatre charge should be 0 after disabling");
    }

    function testBuyTicket() public {
        // Create movie
        vm.prank(owner);
        string memory movieTitle = "Test Movie";
        uint256 moviePrice = 1 ether;
        marketplace.createMovie(movieTitle, moviePrice);

        // Add theater
        vm.prank(theaterOwner);
        string memory theaterName = "Test Theater";
        string memory location = "Test Location";
        uint256 noOfSeats = 100;
        marketplace.addTheater(theaterName, location, noOfSeats);

        // Enable movie in theater
        uint256 theaterId = 0;
        uint256 movieId = 0;
        uint256 theatreChargeOfMovie = 0.5 ether;

        vm.prank(theaterOwner);
        marketplace.enableMovieInTheater(theaterId, movieId, theatreChargeOfMovie);

        // Buy ticket
        uint256 seatNumber = 1;
        string memory metadataURI = "https://example.com/nft/metadata";
        uint256 ticketPrice = moviePrice + theatreChargeOfMovie;
        uint256 marketplaceFee = (ticketPrice * marketplace.marketplaceFeePercentage()) / 100;
        uint256 totalCost = ticketPrice + marketplaceFee;

        vm.prank(user);
        vm.deal(user, totalCost); // Provide user with the necessary funds
        marketplace.buyTicket{value: totalCost}(movieId, theaterId, seatNumber, metadataURI);

        // Assert the seat is booked
        bool isBooked = marketplace.isSeatAvailable(theaterId, seatNumber);
        assertTrue(isBooked, "Seat should be booked after purchasing ticket");
    }

    function testGetAvailableSeats() public {
        // Create movie
        vm.prank(owner);
        string memory movieTitle = "Test Movie";
        uint256 moviePrice = 1 ether;
        marketplace.createMovie(movieTitle, moviePrice);

        // Add theater
        vm.prank(theaterOwner);
        string memory theaterName = "Test Theater";
        string memory location = "Test Location";
        uint256 noOfSeats = 5;
        marketplace.addTheater(theaterName, location, noOfSeats);

        // Enable movie in theater
        uint256 theaterId = 0;
        uint256 movieId = 0;
        uint256 theatreChargeOfMovie = 0.5 ether;

        vm.prank(theaterOwner);
        marketplace.enableMovieInTheater(theaterId, movieId, theatreChargeOfMovie);

        // Buy a ticket to book a seat
        uint256 seatNumber = 1;
        string memory metadataURI = "https://example.com/nft/metadata";
        uint256 ticketPrice = moviePrice + theatreChargeOfMovie;
        uint256 marketplaceFee = (ticketPrice * marketplace.marketplaceFeePercentage()) / 100;
        uint256 totalCost = ticketPrice + marketplaceFee;

        vm.prank(user);
        vm.deal(user, totalCost); // Provide user with the necessary funds
        marketplace.buyTicket{value: totalCost}(movieId, theaterId, seatNumber, metadataURI);

        // Retrieve available seats
        uint256[] memory availableSeats = marketplace.getAvailableSeats(theaterId);

        // Assert the available seats are correct (all seats except the booked one)
        assertEq(availableSeats[0], 0, "Seat 1 should not be available");
        assertEq(availableSeats[1], 2, "Seat 2 should be available");
        assertEq(availableSeats[2], 3, "Seat 3 should be available");
        assertEq(availableSeats[3], 4, "Seat 4 should be available");
        assertEq(availableSeats[4], 5, "Seat 5 should be available");
    }
}
