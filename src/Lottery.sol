// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "forge-std/console.sol";
contract Lottery {

    event Info(address sender,uint256 eth);
    event CurrentBalance(uint256 eth);

    struct Buyer {
        uint16 s_lotteryNumber;
        bool s_winLottery;
        uint256 s_balance;
    }

    mapping(address => Buyer) public buyers;

    address[] buyers_address;
    address prevSender;
    uint16 lotteryNumber;
    uint256 timeStamp;
    bool doneClaim;
    constructor() {
        timeStamp = block.timestamp;
        lotteryNumber = 1234;
        doneClaim = false;
    }

    function test() private  {
        for(uint i=0;i<buyers_address.length;i+=1) {
            emit Info(buyers_address[i],buyers[buyers_address[i]].s_balance);
        }
    }

    function buy(uint16 wn) public payable {
        require(msg.value == 0.1 ether);
        console.log(block.timestamp);
        console.log(timeStamp + 24 hours);

        if(prevSender == msg.sender) {
            require(timeStamp + 24 hours >= block.timestamp);
            if(buyers[msg.sender].s_lotteryNumber == wn ) {
                revert();
            }
        }
        else {
         require(timeStamp + 24 hours > block.timestamp);
        }



        Buyer memory b = Buyer(
                wn,
                false,
                0 ether
            );
            buyers[msg.sender] = b;
            if(buyers_address.length == 0) {
                buyers_address.push(msg.sender);
            }
            else {
                for(uint i=0;i<buyers_address.length;i+=1)
                {
                    if(buyers_address[i] == msg.sender) break;
                }
                buyers_address.push(msg.sender);
            }

        test();
        prevSender = msg.sender;


    }

    // 추첨
    function draw() public  {
        console.log(block.timestamp);
        console.log(timeStamp + 24 hours);
        require(block.timestamp >= timeStamp + 24 hours);
        require(!doneClaim);
        for(uint i=0;i<buyers_address.length;i+=1)
        {
            address i_address = buyers_address[i];
            if(buyers[i_address].s_lotteryNumber == lotteryNumber) {
                
                buyers[i_address].s_balance += 0.1 ether;
                buyers[i_address].s_winLottery = true;
                // console.log(buyers[i_address].s_balance);
                emit Info(i_address,buyers[i_address].s_balance);
            }
        }
    }


    function claim() public payable {
        console.log(block.timestamp);
        console.log(timeStamp);
        require(block.timestamp >= timeStamp + 24 hours);
  
        if(buyers[msg.sender].s_lotteryNumber == lotteryNumber)
        {
            uint256 balance = buyers[msg.sender].s_balance;
            buyers[msg.sender].s_balance=0;
            (bool sent,) = payable(msg.sender).call{value:balance}("");
            require(sent,"Failed to send");
            doneClaim = true;
        }
        // timeStamp = block.timestamp - 24 hours;
        

    }

    function winningNumber() public  returns(uint16) {
        return lotteryNumber;
    }

  receive() external payable {}

}