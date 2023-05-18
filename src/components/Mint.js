import { ethers } from 'ethers'
import { useState } from 'react'
import Form from 'react-bootstrap/Form'
import Button from 'react-bootstrap/Button'
import Spinner from 'react-bootstrap/Spinner'

const Mint = ({ provider, nft, cost, maxMintAmount, setIsLoading }) => {
  const [isWaiting, setIsWaiting] = useState(false)
  const [amount, setAmount] = useState(0)

  const mintHandler = async (e) => {
    e.preventDefault()
    setIsWaiting(true)

    try {
      const signer = await provider.getSigner()
      const totalCost = parseFloat(ethers.utils.formatUnits(cost, 18).toString()) * amount
      const totalCostWei = ethers.utils.parseUnits(totalCost.toString(), 'ether')

      const transaction = await nft.connect(signer).mint(amount, { value: totalCostWei })
      await transaction.wait()
    } catch {
      window.alert('User rejected or transaction reverted')
    }

    setIsLoading(true)
  }

  return (
    <Form onSubmit={mintHandler} style={{ maxWidth: '450px', margin: '50px auto' }}>
      {isWaiting ? (
        <Spinner animation='border' style={{ display: 'block', margin: '0 auto' }} />
      ) : (
        <Form.Group>
          <Form.Control
            type='number'
            placeholder='Enter amount'
            className='my-2'
            min='1'
            max={maxMintAmount}
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
          />
          <Button variant='primary' type='submit' style={{ width: '100%' }}>
            Mint
          </Button>
        </Form.Group>
      )}
    </Form>
  )
}

export default Mint
