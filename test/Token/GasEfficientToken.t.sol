// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { TokenTestsBase } from "test/Base/TokenTestsBase.t.sol";

/**
 * $forge test --match-path test/Token/GasEfficientToken.t.sol --gas-report
 */
contract GasEfficientTokenTests is TokenTestsBase {
    

    function setUp() public virtual override {
        TokenTestsBase.setUp();
    }

    function skip_test_token_config() public view {
        assertEq(gasEfficientToken.name(), 'USD Coin');
        assertEq(gasEfficientToken.symbol(), 'USDC');
        assertEq(gasEfficientToken.decimals(), 6);
        assertEq(gasEfficientToken.totalSupply(), _initialSupply); // 1 tillion token supply
    }

    /**
     * PERMIT TRANSFER TESTS
     * - create token permit
     * - create transfer permit with whitelisted permit issuer 
     * - execute payment
     * 
     * --- this currently only creates valid permits for tokens that implement
     * a permit style equivalent to the standard used in our mock USDC token contract
     * 
     * !!the token permit and transfer permit must have the same timestamp
     */
    function test_transferWithPermit() public {
        
        uint256 transferAmount = 10e18; /// 100 Token
        uint TokenOwnerInitBalance = gasEfficientToken.balanceOf(TokenOwner);
        
        /** Alice has no balance */
        assertEq(gasEfficientToken.balanceOf(Alice), 0);
        
        /** TokenOwner has sufficient balance */
        assertTrue(TokenOwnerInitBalance > transferAmount);

        /**
         * BUILD TOKEN PERMIT
         *  build permit for token to be used in paymet [USDC]
         */
        ERC20TokenPermit memory tokenPermit = makeErc20Permit(
            TokenOwner, 
            Alice, /// Alice receives tokens
            transferAmount,
            gasEfficientToken
        );

        /// prepare message && sign message with tokenOwner
        bytes32 digest = getErc20TypedDataHash(gasEfficientToken, tokenPermit);

        /// token permit must be signed by token owner
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(TokenOwnerKey, digest);

        /** 
         * transfer event 
         * @notice txn origin must be TokenOwner to make valid signature in contract
         */
         /// internally uses address of msg.sender when verifying permit signature 
        // vm.prank(TokenOwner); // Permit caller can be any address
        gasEfficientToken.permit(
            TokenOwner,
            Alice,
            transferAmount,
            tokenPermit.deadline,
            v,
            r,
            s
        );
        
        /// TokenOwner Allowance for Alice to transfer transferAmount
        assertEq(gasEfficientToken.allowance(TokenOwner, Alice), transferAmount);
    }

    function test_balanceOf() public view {
        assertEq(gasEfficientToken.balanceOf(TokenOwner), _initialSupply);
    }

    function test_transfer() public {
        vm.prank(TokenOwner);
        gasEfficientToken.transfer(Alice, transferAmount);

        assertEq(gasEfficientToken.balanceOf(TokenOwner), _initialSupply - transferAmount);
        assertEq(gasEfficientToken.balanceOf(Alice), transferAmount);
    }

    function test_approve() public {
        vm.prank(TokenOwner);
        gasEfficientToken.approve(Alice, transferAmount);

        assertEq(gasEfficientToken.allowance(TokenOwner, Alice), transferAmount);
    }

    function test_transferFrom() public {
        vm.prank(TokenOwner);
        gasEfficientToken.approve(Alice, transferAmount);

        vm.prank(Alice);
        gasEfficientToken.transferFrom(TokenOwner, Alice, transferAmount);

        assertEq(gasEfficientToken.balanceOf(TokenOwner), _initialSupply - transferAmount);
        assertEq(gasEfficientToken.balanceOf(Alice), transferAmount);        
    }

}