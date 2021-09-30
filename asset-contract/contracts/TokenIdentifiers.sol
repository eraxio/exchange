// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;


import "@0xsequence/erc-1155/contracts/utils/SafeMath.sol";


/*
  DESIGN NOTES:
  Token ids are a concatenation of:
 * creator: hex address of the creator of the token. 160 bits
 * index: Index for this token (the regular ID), up to 2^56 - 1. 56 bits
 * supply: Supply cap for this token, up to 2^40 - 1 (1 trillion).  40 bits

*/
/**
 * @title TokenIdentifiers
 * support for authentication and metadata for token ids
 */
library TokenIdentifiers {

    //0x840529241a57c36c27aa31b3d910756f213a49040003e8000000000011000001
    //uint8 constant ADDRESS_BITS = 160;
    //uint8 constant ORIGINATOR_SHARE_BITS = 24;
    //uint8 constant INDEX_BITS = 48;
    uint8 constant SUPPLY_BITS = 24;

    uint256 constant SUPPLY_MASK = (uint256(1) << SUPPLY_BITS) - 1;

    function tokenMaxSupply(uint256 _id) internal pure returns (uint256) {
        return _id & SUPPLY_MASK;
    }

    function tokenCreator(uint256 _id) internal pure returns (address) {
        return address(_id >> 96);
    }

}
