// SPDX-License-Identifier: MIT
// Based on OpenZeppelin Contracts 
pragma solidity ^0.8.28;

import { ERC20 } from "@/core/ModERC20.sol";
import { IERC20Permit, IERC20PermitConfig } from "@/interface/IModERC20Permit.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
contract ERC20Permit is IERC20PermitConfig, IERC20Permit, ERC20 {
    mapping(address => uint256) internal _nonces;

    /// EIP712 DOMAIN SIGNATURE { Unique to Contract }
    bytes32 private immutable _DOMAIN_SIGNATURE;

    /**
     * @dev Sets the values for {name} and {symbol}.
     * Both these values are immutable: they can only be set once during construction.
     * 
     * @dev Initializes the {EIP712} domain separator using the `_name` parameter, and setting `version` to `"1"`.
     * 
     * TODO:: CONSIDER HOW DISTRUBTUION WILL WORK
     *  AIR_DROP OR TOTAL BALANCE TO CONTRACT CREATOR ??
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint initialSupply_
    ) ERC20(name_, symbol_, initialSupply_) {

       _DOMAIN_SIGNATURE = keccak256(
            abi.encode(
                _DOMAIN_TYPE_HASH,
                keccak256(bytes(name_)), // Token Name
                keccak256(bytes(symbol_)), // version
                block.chainid, 
                address(this) 
            )
        );
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        bytes32 domainSignature = _DOMAIN_SIGNATURE;
        assembly {

            if gt(timestamp(), deadline) {
                mstore(0x00, EXPIRED_PERMIT_SELECTOR)
                revert(0x00, 0x04) // Revert with Custom error selector for
            }

            // "_useNonce();"
            // Allocate memory to store the key-value pair for hashing
            mstore(0x40, owner)  // Store the address at free mem pointer 0x40
            mstore(0x60, _nonces.slot)  // Store mapping slot in next 20 bytes 0x40 --> 0x60
            // Compute the correct storage slot for the nonce
            let slot := keccak256(0x40, 0x40)  // Hash (caller . slot) to get actual storage key
            // Load current nonce value
            let nonce := sload(slot)
            // Increment nonce
            sstore(slot, add(nonce, 1))

            mstore(0x40, _PERMIT_TYPEHASH)
            mstore(add(0x40, 0x20), owner)
            mstore(add(0x40, 0x40), spender)
            mstore(add(0x40, 0x60), value)
            mstore(add(0x40, 0x80), nonce)
            mstore(add(0x40, 0xa0), deadline)

            // Calculate structHash
            let structHash := keccak256(0x40, 0xc0) // Hash the full struct
            
            mstore(0x40, hex"19_01") // 2 bytes
            mstore(add(0x40, 0x02), domainSignature) //32 bytes
            mstore(add(0x40, 0x22), structHash) // 32 bytes

            // Calculate typedDataHash and store directly in memory
            mstore(0x40, keccak256(0x40, 0x42)) // Store hash at first 32 bytes of 0x40 [0x00]

            // Store (v, r, s) in memory sequentially
            mstore(add(0x40, 0x20), v)
            mstore(add(0x40, 0x40), r)
            mstore(add(0x40, 0x60), s)
        
            // Perform ecrecover with staticcall
            pop(staticcall(gas(), 0x01, 0x40, 0x80, 0x40, 0x20))
                          // ^     ^     ^     ^    ^    ^
                          // |     |     |     |    |    └── (6) Output size (32 bytes, since ecrecover returns an address)
                          // |     |     |     |    └── (5) Output location (0x00)
                          // |     |     |     └── (4) Input size (0x80 = 128 bytes, as ecrecover takes 128 bytes of input)
                          // |     |     └── (3) Input location (0x40, where hash, v, r, s are stored)
                          // |     └── (2) `ecrecover` precompile address (0x01)
                          // └── (1) Gas provided for the call
            
            // Load the recovered signer
            // && compare with token owner
            let signer := mload(0x40) // Load the recovered signer
            if iszero(eq(signer, owner)) {
                mstore(0x00, INVALID_SIGNATURE_SELECTOR)
                revert(0x00, 0x04) // Revert with Custom error selector for InvalidSignature()
            }
        }

        _approve(owner, spender, value);
    }

    /** @dev Returns an address nonce */
    function nonces(address sender) public view virtual returns (uint256) {
        return _nonces[sender];
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return _DOMAIN_SIGNATURE;
    }
}
