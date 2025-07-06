// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { TokenTestsBase } from "test/Base/TokenTestsBase.t.sol";

/**
 * $forge test --match-path test/Token/USDC.t.sol --gas-report
 */
contract StandardTokenTests is TokenTestsBase {
    
    function setUp() public virtual override {
        TokenTestsBase.setUp();
    }

    function test_token_config() public view {
        assertEq(usdcToken.name(), 'USD Coin');
        assertEq(usdcToken.symbol(), 'USDC');
        assertEq(usdcToken.decimals(), 6);
        assertEq(usdcToken.totalSupply(), _initialSupply); // 1 tillion token supply
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
        
        uint TokenOwnerInitBalance = usdcToken.balanceOf(TokenOwner);
        /** Alice has no balance */
        assertEq(usdcToken.balanceOf(Alice), 0);
        /** TokenOwner has sufficient balance */
        assertTrue(TokenOwnerInitBalance > transferAmount);

        /**
         * BUILD TOKEN PERMIT
         **/

        /// build permit for token to be used in paymet [USDC]
        ERC20TokenPermit memory tokenPermit = makeErc20Permit(
            TokenOwner, 
            Alice, /// Alice receives tokens
            transferAmount,
            usdcToken.nonces(TokenOwner)
        );

        /// prepare message && sign message with tokenOwner
        bytes32 digest = getErc20TypedDataHash(usdcToken.DOMAIN_SEPARATOR(), tokenPermit);

        /// token permit must be signed by token owner
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(TokenOwnerKey, digest);

        /** 
         * transfer event 
         * @notice txn origin must be TokenOwner to make valid signature in contract
         */
         /// internally uses address of msg.sender when verifying permit signature 
        vm.prank(Bob); // Permit caller can be any address
        usdcToken.permit( 
            TokenOwner,
            Alice, 
            transferAmount,
            tokenPermit.deadline,
            v, 
            r, 
            s
        );
        
        /// TokenOwner Allowance for Alice to transfer transferAmount
        assertEq(usdcToken.allowance(TokenOwner, Alice), transferAmount);
    }

    function test_balanceOf() public view {
        assertEq(usdcToken.balanceOf(TokenOwner), _initialSupply);
    }

    function test_transfer() public {
        vm.prank(TokenOwner);
        usdcToken.transfer(Alice, transferAmount);

        assertEq(usdcToken.balanceOf(TokenOwner), _initialSupply - transferAmount);
        assertEq(usdcToken.balanceOf(Alice), transferAmount);
    }

    function test_approve() public {
        vm.prank(TokenOwner);
        usdcToken.approve(Alice, transferAmount);

        assertEq(usdcToken.allowance(TokenOwner, Alice), transferAmount);
    }

    function test_transferFrom() public {
        vm.prank(TokenOwner);
        usdcToken.approve(Alice, transferAmount);

        vm.prank(Alice);
        usdcToken.transferFrom(TokenOwner, Alice, transferAmount);

        assertEq(usdcToken.balanceOf(TokenOwner), _initialSupply - transferAmount);
        assertEq(usdcToken.balanceOf(Alice), transferAmount);        
    }

}