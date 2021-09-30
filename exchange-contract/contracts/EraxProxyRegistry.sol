// SPDX-License-Identifier: MIT
/*

  << Project Erax Proxy Registry >>

*/

pragma solidity ^0.7.4;

import "./registry/ProxyRegistry.sol";
import "./registry/AuthenticatedProxy.sol";

/**
 * @title EraxProxyRegistry
 * @author Project Erax Developers
 */
contract EraxProxyRegistry is ProxyRegistry {

    string public constant name = "Project Erax Proxy Registry";

    /* Whether the initial auth address has been set. */
    bool public initialAddressSet = false;

    constructor ()
        public
    {
        delegateProxyImplementation = address(new AuthenticatedProxy());
    }

    /** 
     * Grant authentication to the initial Exchange protocol contract
     *
     * @dev No delay, can only be called once - after that the standard registry process with a delay must be used
     * @param authAddress Address of the contract to grant authentication
     */
    function grantInitialAuthentication (address authAddress)
        onlyOwner
        public
    {
        require(!initialAddressSet,"1");
        initialAddressSet = true;
        contracts[authAddress] = true;
    }

}
