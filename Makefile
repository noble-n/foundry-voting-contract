-include .env

.PHONY: all test deploy

build :; forge build

test :; forge test

install :; forge install cyfrin/foundry-devops@0.2.2 && forge install foundry-rs/forge-std@v1.8.2

deploy-sepolia : 
	@forge script script/DeployVoting.s.sol:DeployVoting --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvv


deploy-tenderly : 
	@forge script script/DeployVoting.s.sol:DeployVoting --rpc-url $(TENDERLY_RPC_URL) --private-key $(PRIVATE_KEY) --sender $(SENDER_ADDRESS) --broadcast -vvvv