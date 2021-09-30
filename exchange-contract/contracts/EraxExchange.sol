// SPDX-License-Identifier: MIT
/*

  << Project Erax Exchange >>

*/

pragma solidity ^0.7.4;

import "./exchange/Exchange.sol";

/**
 * @title EraxExchange
 * @author Project Erax Developers
 */
contract EraxExchange is Exchange {

    string public constant name = "Erax";

    string public constant version = "1.0.0";

    string public constant codename = "Init";

    /**
     * @dev Initialize a EraxExchange instance
     * @param registryAddress Address of the registry instance which this Exchange instance will use
     */
    constructor (ProxyRegistry registryAddress, TokenTransferProxy tokenTransferProxyAddress) {
        registry = registryAddress;
        tokenTransferProxy = tokenTransferProxyAddress;
    }

}
