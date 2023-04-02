// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract AucEngine {
    address public owner;
    uint constant DURATION = 2 days; // time auction
    uint constant FEE = 10; //10%  commission marketplace

    struct Auction {
        address payable seller;
        uint startingPrice;
        uint finalPrice;
        uint startAt;
        uint endsAt;
        uint discountRate;
        string item;
        bool stopped;
    }

    Auction[] public auctions;

    event AuctionCreated(
        uint index,
        string itemName,
        uint startingPrice,
        uint duration
    );
    event AuctionEnded(uint index, uint finalPrice, address winner);

    constructor() {
        owner = msg.sender;
    }

    function createAuction(
        uint _startingPrice,
        uint _discountRate,
        string memory _item,
        uint _duraction
    ) external {
        uint duraction = _duraction == 0 ? DURATION : _duraction;

        require(
            _startingPrice > _discountRate * duraction,
            "incorrect starting price"
        );

        Auction memory newAuction = Auction({
            seller: payable(msg.sender),
            startingPrice: _startingPrice,
            finalPrice: _startingPrice,
            discountRate: _discountRate,
            startAt: block.timestamp, // now
            endsAt: block.timestamp + duraction,
            item: _item,
            stopped: false
        });

        auctions.push(newAuction);

        emit AuctionCreated(
            auctions.length - 1,
            _item,
            _startingPrice,
            duraction
        );
    }

    function getPriceFor(uint index) public view returns (uint) {
        Auction memory cAuction = auctions[index];
        require(!cAuction.stopped, "stopped");

        uint elapsed = block.timestamp - cAuction.startAt;
        uint discount = cAuction.discountRate * elapsed;
        return cAuction.startingPrice - discount; // actual price , change every second
    }

    function buy(uint index) external payable {
        Auction memory cAuction = auctions[index];
        require(!cAuction.stopped, "stopped");
        require(block.timestamp < cAuction.endsAt, "ended!");

        uint cPrice = getPriceFor(index);
        require(msg.value >= cPrice, "not enough funds!");
        cAuction.stopped = true;
        cAuction.finalPrice = cPrice;

        uint refund = msg.value - cPrice; //if more money came while the transaction was in progress

        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }

        cAuction.seller.transfer(cPrice - ((cPrice * FEE) / 100)); // 500 -((500 *10) / 100) = 500 - 50 = 450
        emit AuctionEnded(index, cPrice, msg.sender);
    }
}
