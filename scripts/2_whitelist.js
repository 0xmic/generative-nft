// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require('hardhat')

const config = require('../src/config.json')

async function main() {
  // Fetch accounts from the wallet
  const accounts = await hre.ethers.getSigners()

  // Fetch the network
  const { chainId } = await hre.ethers.provider.getNetwork()
  console.log(`Using chainId: ${chainId}\n`)

  // Fetch the deployed nft
  const nft = await hre.ethers.getContractAt('NFT', config[chainId].nft.address)
  console.log(`NFT contract fetched: ${nft.address}\n`)

  // Set the deployer address
  const deployer = accounts[0]
  console.log(`Deployer address: ${deployer.address}\n`)

  // Array of addresses to be added to the whitelist
  // List addresses as comma separated strings: ['0x000000','0x000000']
  const addressesToWhitelist = [
    deployer.address,
    '0x70997970C51812dc3A010C7d01b50e0d17dc79C8',
    '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC'
  ]

  // Add addresses to the whitelist
  for (const address of addressesToWhitelist) {
    await nft.connect(deployer).whitelistUser(address)
    console.log(`Added address to whitelist: ${address}\n`)
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
