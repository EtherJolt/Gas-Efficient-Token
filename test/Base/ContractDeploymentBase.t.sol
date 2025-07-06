// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

/// HELPERS
import { BaseTestEnvironment } from 'test/Base/BaseTestEnvironment.t.sol';
import { ERC20Permit } from "@/core/ModERC20Permit.sol";
import { OpenZepERC20Permit } from '@/core/OpenZeppelinERC20Permit.sol';
import { FiatTokenV2_2 } from '@/core/USDC/FiatTokenV2_2.sol';

/// CONTRACTS TO DEPLOY IN TEST ENVIRONMENT
contract ContractDeploymentBase is BaseTestEnvironment {

    /// TOKENS
    uint constant _initialSupply = 1_000_000_000_000e18; // 1 tillion token supply

    uint TEST_TOKEN_COUNT = 3;
    address[] internal test_tokens;
    address public constant NATIVE_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // 1
    OpenZepERC20Permit public openZepToken; // 2
    ERC20Permit public gasEfficientToken; // 3
    FiatTokenV2_2 public usdcToken; // 4

    function setUp() public virtual override {
        // setup inherited base environment
        BaseTestEnvironment.setUp();

        /// all Token contracts deployed && owned by Token Owner
        vm.startPrank(TokenOwner);

            /// deposit 10 Eth, giving TokenOwner ETH Balance
            vm.deal(TokenOwner, _initialSupply);

            openZepToken = new OpenZepERC20Permit('USD Coin', 'USDC', _initialSupply);

            gasEfficientToken = new ERC20Permit("Dollar", "D", _initialSupply);

            /**
             * @notice 
             *  initialization not done via constructur implies risk of 
             *      contract initialization being front run
             */
            usdcToken = new FiatTokenV2_2();
            usdcToken.initialize('USD Coin', "USDC", "USD", 6, MasterOwner, MasterOwner, MasterOwner, TokenOwner);
        vm.stopPrank();

        vm.startPrank(MasterOwner);
            usdcToken.configureMinter(MasterOwner, _initialSupply);
            assertTrue(usdcToken.isMinter(MasterOwner));
            usdcToken.mint(TokenOwner, _initialSupply);
        vm.stopPrank();



        emit log_named_address('openZepToken', address(openZepToken));
        emit log_named_address('gasEfficientToken', address(gasEfficientToken));
        emit log_named_address('usdcToken', address(usdcToken));

        test_tokens.push(NATIVE_TOKEN); // 1
        test_tokens.push(address(openZepToken)); // 2
        test_tokens.push(address(gasEfficientToken)); // 3
        test_tokens.push(address(usdcToken)); // 3
    }
}