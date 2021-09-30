// SPDX-License-Identifier: MIT
/*
  
  Exchange contract. This is an outer contract with public or convenience functions and includes no state-modifying functions.
 
*/

pragma solidity ^0.7.4;

import "./ExchangeCore.sol";

/**
 * @title Exchange
 * @author Project Erax Developers
 */
contract Exchange is ExchangeCore {

    /**
     * @dev Call hashOrder - Solidity ABI encoding limitation workaround, hopefully temporary.
     */
    function hashOrder_(
        address[7] memory addrs,
        uint[10] memory uints,
        FeeMethod feeMethod,
        SaleKindInterface.Side side,
        SaleKindInterface.SaleKind saleKind,
        AuthenticatedProxy.HowToCall howToCall,
        bytes memory callData,
        bytes memory replacementPattern)
    public
    pure
    returns (bytes32)
    {
        return hashOrder(
        Order(addrs[0], addrs[1], addrs[2], uints[0], uints[1], uints[2], uints[3], addrs[3], feeMethod, side, saleKind, addrs[4], howToCall, callData, replacementPattern, addrs[5], uints[9], addrs[6], uints[4], uints[5], uints[6], uints[7], uints[8])
        );
    }


    /**
     * @dev Call validateOrderParameters - Solidity ABI encoding limitation workaround, hopefully temporary.
     */
    function validateOrderParameters_ (
        address[7] memory addrs,
        uint[10] memory uints,
        FeeMethod feeMethod,
        SaleKindInterface.Side side,
        SaleKindInterface.SaleKind saleKind,
        AuthenticatedProxy.HowToCall howToCall,
        bytes memory callData,
        bytes memory replacementPattern)
    view
    public
    returns (bool)
    {
        Order memory order = Order(addrs[0], addrs[1], addrs[2], uints[0], uints[1], uints[2], uints[3], addrs[3], feeMethod, side, saleKind, addrs[4], howToCall, callData, replacementPattern, addrs[5], uints[9], addrs[6], uints[4], uints[5], uints[6], uints[7], uints[8]);
        return validateOrderParameters(
            order
        );
    }


    /**
     * @dev Call cancelOrder - Solidity ABI encoding limitation workaround, hopefully temporary.
     */
    function cancelOrder_(
        address[7] memory addrs,
        uint[10] memory uints,
        FeeMethod feeMethod,
        SaleKindInterface.Side side,
        SaleKindInterface.SaleKind saleKind,
        AuthenticatedProxy.HowToCall howToCall,
        bytes memory callData,
        bytes memory replacementPattern,
        uint8 v,
        bytes32 r,
        bytes32 s)
    public
    {

        return cancelOrder(
        Order(addrs[0], addrs[1], addrs[2], uints[0], uints[1], uints[2], uints[3], addrs[3], feeMethod, side, saleKind, addrs[4], howToCall, callData, replacementPattern, addrs[5], uints[9], addrs[6], uints[4], uints[5], uints[6], uints[7], uints[8]),
    Sig(v, r, s)
        );
    }


    /**
     * @dev Call atomicMatch - Solidity ABI encoding limitation workaround, hopefully temporary.
     */
    function atomicMatch_(
        address[14] memory addrs,
        uint[20] memory uints,
        uint8[8] memory feeMethodsSidesKindsHowToCalls,
        bytes memory calldataBuy,
        bytes memory calldataSell,
        bytes memory replacementPatternBuy,
        bytes memory replacementPatternSell,
        uint8[2] memory vs,
        bytes32[5] memory rssMetadata)
    public
    payable
    {

        return atomicMatch(
            Order(addrs[0], addrs[1], addrs[2], uints[0], uints[1], uints[2], uints[3], addrs[3], FeeMethod(feeMethodsSidesKindsHowToCalls[0]), SaleKindInterface.Side(feeMethodsSidesKindsHowToCalls[1]), SaleKindInterface.SaleKind(feeMethodsSidesKindsHowToCalls[2]), addrs[4], AuthenticatedProxy.HowToCall(feeMethodsSidesKindsHowToCalls[3]), calldataBuy, replacementPatternBuy, addrs[5], uints[9], addrs[6], uints[4], uints[5], uints[6], uints[7], uints[8]),
            Sig(vs[0], rssMetadata[0], rssMetadata[1]),
            Order(addrs[7], addrs[8], addrs[9], uints[10], uints[11], uints[12], uints[13], addrs[10], FeeMethod(feeMethodsSidesKindsHowToCalls[4]), SaleKindInterface.Side(feeMethodsSidesKindsHowToCalls[5]), SaleKindInterface.SaleKind(feeMethodsSidesKindsHowToCalls[6]), addrs[11], AuthenticatedProxy.HowToCall(feeMethodsSidesKindsHowToCalls[7]), calldataSell, replacementPatternSell, addrs[12], uints[19], addrs[13], uints[14], uints[15], uints[16], uints[17], uints[18]),
            Sig(vs[1], rssMetadata[2], rssMetadata[3]),
            rssMetadata[4]
        );
    }

}
