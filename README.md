# Introduction

The Gas reports below demonstrate the costs of including additional functionality or bloat in a token contract. 

# Gas Reports

## USDC (FiatTokenV2_2)

	Generate Report: forge test --match-path test/Token/USDC.t.sol --gas-report	

	<img src="./images/GasReport_USDC.png" alt="USDC Gas Report" width="200", height="200" />

## Standard Openzeppelin ERC20 Token

	Generate Report: forge test --match-path test/Token/StandardToken.t.sol --gas-report 

	![Standard Gas Report](./images/GasReport_StandardToken.png){width="200", height="200"}

## Gas Efficient ERC20 Token

		Generate Report: forge test --match-path test/Token/GasEfficientToken.t.sol --gas-report 

	![Minimal Token Gas Report](./images/GasReport_GasEfficientToken.png){width="200", height="200"}	
