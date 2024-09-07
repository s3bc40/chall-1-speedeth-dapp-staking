# 🚩 Challenge 1: 🔏 Decentralized Staking App

<https://speedrunethereum.com/challenge/decentralized-staking>

Build a Staker.sol contract that collects ETH from numerous addresses using a payable stake() function and keeps track of balances. After some deadline if it has at least some threshold of ETH, it sends it to an ExampleExternalContract and triggers the complete() action sending the full balance. If not enough ETH is collected, allow users to withdraw().

🎛 Building the frontend to display the information and UI is just as important as writing the contract. The goal is to deploy the contract and the app to allow anyone to stake using your app. Use a Stake(address,uint256) event to list all stakes.

🌟 The final deliverable is deploying a Dapp that lets users send ether to a contract and stake if the conditions are met, then yarn vercel your app to a public webserver. 
