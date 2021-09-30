// SPDX-License-Identifier: MIT
/*

  Simple contract extension to provide a contract-global reentrancy guard on functions.

*/

pragma solidity ^0.7.4;

/**
 * @title ReentrancyGuarded
 * @author Project Erax Developers
 */
contract ReentrancyGuarded {

    bool reentrancyLock = false;

    /* Prevent a contract function from being reentrant-called. */
    modifier reentrancyGuard {
        if (reentrancyLock) {
            revert();
        }
        reentrancyLock = true;
        _;
        reentrancyLock = false;
    }

}
