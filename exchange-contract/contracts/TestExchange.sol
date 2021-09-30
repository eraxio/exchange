// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;

import "./exchange/ExchangeCore.sol";
import "hardhat/console.sol";


/**
  * @title TestExchange
  * @author Joe
  */
contract TestExchange {

    function test(address exchangeCoreAddress, bytes memory callData) public {

        console.log("__abc");
        exchangeCoreAddress.call(callData);
    }

}
