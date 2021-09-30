// SPDX-License-Identifier: MIT
/*

  << Test Token (for use with the Test DAO) >>

*/

pragma solidity ^0.7.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
  * @title TestToken
  * @author Project Erax Developers
  */
contract TestToken is ERC20 {

    /**
      * @dev Initialize the test token
      */
    constructor ()
    ERC20("Test Token", "TST")
    {
        _mint(
            msg.sender, 20000000 * (10**uint256(decimals()))
        );
    }

}
