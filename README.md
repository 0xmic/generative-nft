# Dapp Punks
This project demonstrates a basic generative NFT contract. The development lifecycle is as follows:
1. Generate Images
2. Generate Metadata
3. Upload to IPFS
4. Create NFT Smart Contract
5. Link Smart Contract to IPFS Metadata
6. Users Mint NFTs

## Stack
Technologies Used:
* JavaScript
* React
* Solidity
* Bootstrap

Libraries Used:
* [React-Bootstrap](https://react-bootstrap.github.io/)

Testing Libraries:
* [React Testing Library](https://testing-library.com/docs/react-testing-library/intro/)
* [Jest](https://jestjs.io/)
* [Chai](https://www.chaijs.com/)

Dev Tools:
* [Hardhat](https://hardhat.org/)
* [dotenv](https://www.npmjs.com/package/dotenv)

## Local Testing
To test the Crowdsale locally, run the following:
```shell
npx hardhat node

npx hardhat --network localhost scripts/1_deploy.js

npx hardhat --network localhost scripts/2_seed.js

npm run start
```

![NFT](./NFT.png)