## Todo

-   Include NFTprice and theatreSharePrice `TicketPrice = NFTprice + theatreSharePrice + marketplaceFee`
-   TheatreOwner can set price of `theatreSharePrice`
-   Movimakers can set price of `NFTprice`
-   include Profit sharing among marketpalce, theatreOwner and moviemakers in `buyTicket` function
-   write the fuzzTests
-   Optional: Integrate with BE and FE



---

## Inv1nc Ideology

1. Profit Sharing Among Marketplace, Theater Owner, and Movie Makers
- pros: fair distribution, automation
- cons: higher gas cost, increased complexity

2. Only Paying the Theater Owner (Assuming Movie Makers Are Already Paid)
- pros: simplicity, low gas costs
- cons: assuming movie makers already paid


### More to add

- dynamic seat selection
- dynamic pricing based on seat categories - Seats are priced differently depending on the category
- role based access using `openzeppelin's Access Control`, specific actions can be restricted to certain roles, like adding movies.
- ticket canceling & refund - refund policy (like canceling within a certain time frame & only certain percent will refund)
- Once an NFT ticket is minted, the ticket owner can view it. A QR code can be included to make it easy to scan and verify the ticket during entry at the theater.

**Events**

```
TickedConfirmed(uint256 ticketId, uint256 movieId, uint256 TheatreId);
```

**Functions**

```
function movieClosedInClosedInTheater(uint256 theaterId, uint256 movieId) public {}
```
