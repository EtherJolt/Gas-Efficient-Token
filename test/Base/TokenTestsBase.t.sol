// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { ContractDeploymentBase } from "test/Base/ContractDeploymentBase.t.sol";
import { ERC20Permit } from "@/core/ModERC20Permit.sol";
import { IERC20PermitConfig } from "@/interface/IModERC20Permit.sol";
import { OpenZepERC20Permit } from '@/core/OpenZeppelinERC20Permit.sol';

/**
 * THIS LOCAL TESTING UTIL CONTRUCTS TOKEN PERMITS WITHIN FOUNDRY TEST ENVIRIONMENT
 * FOR USE IN TESTING THE TRANSFER PROXY CONTRACT PERMIT PAYMENT ENDPOINT 
 *  
 * TOKEN PERMIT REQUIREMENTS
 *  MUST CREATE TYPEDATA TO BE SIGNED BY A USER
 */
contract TokenTestsBase is ContractDeploymentBase, IERC20PermitConfig {

    // emit log_named_uint("_feeBase", _feeBase);
    uint256 public constant transferAmount = 10e18; /// 100 Token

    struct ERC20TokenPermit {
        address owner;
        address spender;
        uint value;
        uint nonce;
        uint deadline;
    }
    
    function setUp() public virtual override {
        ContractDeploymentBase.setUp();
    }

    function test_Selectors() public pure {

        // Custom Error
        bytes4 expiredPermitSelector = bytes4(keccak256("ExpiredPermit()"));
        assertEq(expiredPermitSelector, bytes4(EXPIRED_PERMIT_SELECTOR));

        // Custom Error
        bytes4 transferFailedSelector = bytes4(keccak256('TransferFailed()'));
        assertEq(transferFailedSelector, bytes4(TRANSFER_FAILED_SELECTOR));

        // Custom Error 
        bytes4 invalidSignatureSelector = bytes4(keccak256('InvalidSignature()'));
        assertEq(invalidSignatureSelector, bytes4(INVALID_SIGNATURE_SELECTOR));

        // _DOMAIN_TYPE_HASH;
        assertEq(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"), 
            0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f
        );

        /// EIP712 PERMIT TYPEHASH SIGNATURE            
        assertEq(
            keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
            0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9
        );
    }
    ///
    /// SIGNATURES
    ///

    // Gas Optimized token ===================================

    function makeErc20Permit(
        address owner,
        address spender,
        uint value,
        ERC20Permit token
    ) public view returns (ERC20TokenPermit memory) { 
        return ERC20TokenPermit({
            owner: owner,
            spender: spender,
            value: value,
            nonce: token.nonces(owner),
            deadline: 1 days
        });
    }

    // computes the hash of the fully encoded EIP-712 message for the domain, which can be used to recover the signer
    function getErc20TypedDataHash(
        ERC20Permit token, 
        ERC20TokenPermit memory _permit
    ) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    getErc20StructHash(_permit)
                )
            );
    }

    //
    // Open Zep token ===================================
    //
    
    function makeOpenZepErc20Permit(
        address owner,
        address spender,
        uint value,
        OpenZepERC20Permit token
    ) public view returns (ERC20TokenPermit memory) { 
        return ERC20TokenPermit({
            owner: owner,
            spender: spender,
            value: value,
            nonce: token.nonces(owner),
            deadline: 1 days
        });
    }

    // // computes the hash of the fully encoded EIP-712 message for the domain, which can be used to recover the signer
    function getErc20TypedDataHash(
        OpenZepERC20Permit token, 
        ERC20TokenPermit memory _permit
    ) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    getErc20StructHash(_permit)
                )
            );
    }

    // computes the hash of a permit
    function getErc20StructHash(
        ERC20TokenPermit memory _permit
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    _PERMIT_TYPEHASH,
                    _permit.owner,
                    _permit.spender,
                    _permit.value,
                    _permit.nonce,
                    _permit.deadline
                )
            );
    }
}