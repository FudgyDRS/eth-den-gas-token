# Qi Protocol

![alt text](https://github.com/FudgyDRS/eth-den-rgas-token/blob/main/pics/Screenshot%20from%202023-03-05%2000-10-49.png)


### What’s The Problem Qi Protocol Tries to Solve

- **Qi Protocol is an oracleless protocol helps network participants to manage their gas expenditure that fits individual risk appetites**. Ethereum users currently struggle to manage gas prices, which can be volatile and unpredictable. EIP-1559 made gas prices more predictable, yet they still fluctuate heavily over time(see below). This creates challenges for dApp developers and on-chain game developer, who may need to pay for users' gas fees in order to provide a better user experience. Further, miners, MEV searchers, and L2s are all actively looking for solutions that could hedge their gas exposures. Currently, there are few solutions available to help participants hedge their gas exposure.
- **Qi Protocol productizes the concept of gas token to serve void left behind by the OG gas tokens**. The previous iterations of gas token, pioneered by the [GasToken](https://gastoken.io/) and [1inch’s CHI token](https://blog.1inch.io/everything-you-wanted-to-know-about-chi-gastoken-a1ba0ea55bf3), despite popularity among MEV searchers, didn’t achieve mass adoption due to lack of commercial productization. Additionally, due to its implementation, the old gas token [“exacerbates the state size (as state slots are effectively used as a "battery" to save up gas) and inefficiently clogging the blockchain gas usage”](https://github.com/ethereum/pm/issues/255), not to mention that [it could only refund up to a maximum of 50% of the gas used in a transaction](https://ethereum.stackexchange.com/questions/92965/how-are-gas-refunds-payed).
    - As of Mar/2023, the OG gas tokens no longer serve their intended utilities, following the [obsoletion of opcode `SELFDESTRUCT`](https://hackmd.io/@vbuterin/selfdestruct).

![alt text](https://i.imgur.com/lJURP52.png)

From *EIP-1559 In Retrospect* by *Yinhong (William) Zhao, Kartik Nayak*

![alt text](https://github.com/FudgyDRS/eth-den-rgas-token/blob/main/pics/Screenshot%20from%202023-02-24%2002-55-43.png)

Median Gas Price Last 90 Days(Mar/4/2023) from [https://dune.com/kroeger0x/gas-prices](https://dune.com/kroeger0x/gas-prices)

![alt text](https://github.com/FudgyDRS/eth-den-rgas-token/blob/main/pics/Screenshot%20from%202023-03-04%2017-48-18.png)

Median Priority Fee vs. Base Fee from block 16653145 to 16660242(~1 day) from [https://dune.com/msilb7/EIP1559-Base-Fee-x-Tip-by-Block](https://dune.com/msilb7/EIP1559-Base-Fee-x-Tip-by-Block)

### So What is Qi Protocol Exactly?

- In simple terms, Qi Protocol enables users to put in collateral and mint gas tokens(Qi token) to manage gas exposures and hedge positions with derivative positions.
- In ETH-Denver 2023 hackathon, we are only focusing on the first part - building a gas token that tracks the `baseFee`.

### Supported Features
- Qi Token minting/burning
- Constructing synthetic option-like payoff structures by leveraing protocols such like [Panoptics](https://www.panoptic.xyz/), [Voltz](https://www.voltz.xyz/), and Primtive(https://www.primitive.xyz/)
- Gas fee margin trading(see sections Hedging Agents(HA and UniV3 LP Collateralization)


### Use Case

- Gas cost hedging:
    - The most basic use case is HODL gas token if a user expects the gas fee will increase in the future.
    - Ex. at T1, a popular NFT is going to launch, which is going to cause network congestion. Users who wished to mint the NFT, or speculators of gas price, could mint/purchase Qi Token at T0, when the gas price is low, and then sell/burn Qi Token at T0 to pocket the difference.
- On-chain User Tx Gas Subsidy Cost Hedging
    - On-chain [games(i.e. EMETH)](https://hackernoon.com/ethereum-gas-fees-are-there-any-projects-working-to-optimize-eth-gas-fees), [NFTs market place(i.e. Global Rockstar)](https://aws.amazon.com/cn/blogs/database/subsidize-ethereum-blockchain-transaction-costs-for-your-users/), DeFi protocols(i.e. [CowSwap](https://docs.cow.fi/off-chain-services/api/fee-mechanism)) or [L2s(i.e. Immutable X)](https://www.immutable.com/blog/fees-on-immutable-x), subsidize their users’ gas fees to improve UX. Qi Token and synthetic payoff products built on top of Qi Token will be able to better help them hedge the gas cost.
    - Ex. CowSwap guarantees tx execution for its user even if the gas price changes. In other words, CowSwap is exposed to the gas price volatility. To hedge the cost, CowSwap could long put options on [Panoptics](https://www.panoptic.xyz/) to hedge the downside
- [Cross-chain MEV](https://arxiv.org/pdf/2112.01472.pdf) & [Cross-chain Swap Protocols](https://www.squidrouter.com/)
    - Cross-chain transactions by nature are not atomic and require managing balances on two separate chains. Gas fee becomes even harder to manage compared to single chain transactions. Qi Token and synthetic structured products built on top could offer help.
    - Ex. On Axelar, token transfers across chains are charged a fixed network gas fee. If gas prices change and the users overpay, they will be refunded the difference. To create a better UX, protocols such like Squid could help its users to become a Fixed Taker on interest-rate-swap protocols such like [Voltz](https://docs.voltz.xyz/getting-started/protocol-overview) to hedge the varying rate of gas cost at different times
    - Ex. With Qi token as underlying, MEV searchers could leverage novel AMM designs such like [Panoptics](https://www.panoptic.xyz/) and [Primitives Finance](https://www.primitive.xyz/) to construct a payoff structure that could hedge their gas exposure in the destination chain
- AA(Account Abstraction) Wallet Integration
    - Smart contract wallet provides the flexibility of integration and opens up a world of designs for composabilities. Qi Token could be integrated with AA wallets, such like [SoulWallet](https://github.com/proofofsoulprotocol/soul-wallet-contract), to provide a native solution for gas cost hedging.
- Speculation
    - Most of the people in crypto these days are still in for the profit. Due to Qi’s unique design, we will allow users to open long, short, margin long and margin short positions between Qi Token and ETH. (see below for detail)

## How Are We Solving This Problem?

Every index-pegging token should answer two questions: 

1. How to maintain the peg?
2. How to stay solvent? 

### Peg Maintenance

Each Qi Token is pegged a TWAP([Time-Weighted Average Price](https://river.com/learn/terms/t/time-weighted-average-price-twap)) of recent blocks’ `baseFee`. To stay “oracleless”, we would access the `baseFee` from Solidity by calling `block.baseFee`. The exact formula to calculate the price of 1 Qi Token is

```solidity
1 unit of Qi = gas_used * TWAP(baseFee)
```

Why TWAP? There are two reasons for this design choice:

1. Base fees are extremely volatile. Exposing depositing users to extreme volatility require unattainablely high collateralization ratio to avoid cascading liquidations. Additionally, base fee’s erratic price movement also makes arbitrage difficult. Therefore, to smooth out the curve, we adopted the TWAP of base fee as the pegging index. To compensate for the insensitivity, we would provide a tool to calculate the exact amount of gas token one should buy to hedge the transaction cost. (see [Effective GasPrice Prediction for Carrying Out Economical Ethereum Transaction](https://www.semanticscholar.org/paper/Effective-GasPrice-Prediction-for-Carrying-Out-Liu-Wang/811ee56b9c8ae89164ef6f1797dc021f20d57fe0))
2. There is potentially an attack vector that could be carried out by the block builders to manipulate the base fee(see [The manipulation of the basefee in the context of EIP-1559](https://medium.com/nethermind-eth/the-manipulation-of-the-basefee-in-the-context-of-eip-1559-4b082898271c)). By extending the look back period, the cost of manipulation would outweigh the potential profit. In that case, no rational 

**Open Redemption**

Because Qi token is openly traded on the open market, keeping the open market price in sync with the index price is very important. One commonly used technique is arbitrage. It works like this:

> “When market demand pushes the price of USDT against USD to $1.02, the market signals to the arbitrageur to start working. An Arbitrager would send $1.00 USD to Tether Inc. and receives 1 USDT in return. Since the market currently values USDT at $1.02, it buys him $1.02 worth of USD, for an immediate profit of $0.02. The same is true in the other direction when the price of USDT falls to $0.98. Arbitrageurs will buy up USDT for $0.98 USD, send it to Tether Inc. and redeem it for $1.00 in USD, again closing the cycle with a profit.” - Hasu “*Maker Dai: Stable, but not scalable*”
> 

However, for decentralized stablecoins, such like DAI, the close cycle arbitrage does not work. Because

> When market demand pushes the price of DAI to $1.02, you can again take $1.00 USD, buy $1.00 ETH (or any other asset that can be used as collateral) and lock it in a CDP. The problem, however, is that for each $1.00 ETH locked up, Maker will give you less than $1 of Dai. That is due to the requirement for over-collateralization. The current collateralization ratio is 150%, so $1.00 ETH in a CDP can generate up to 0.66 Dai (this ratio could change, but it’s never going to be close to 100%). - Hasu “*Maker Dai: Stable, but not scalable*”
> 

MakderDAO stays pegged mostly because people believe it will stay pegged. For a highly volatile asset like Qi Token, such model won’t work. Therefore, we added a feature, called **open redemption** to facilitate ****arbitrage, which in turn, keep price pegged. Open redemption is the process of exchanging Qi for ETH at index value, as if 1 Qi is exactly worth the index value at the time of redemption. That is, for `x` Qi you get `x * Qi(index)/ETH`  worth of ETH in return. 

Users can redeem Qi for ETH at any time without limitations. However, a redemption fee will be charged on the redeemed amount, and the `redemptionFee` is a floating rate that changes algorithmically according to the peg deviation. The general rule of thumb is, larger the deviation between index price and market price, lower the `redemptionFee`. The `redemptionFee` should be equal or larger to zero at all times. 

For example, when the market price is lower than index price, we would encourage open redemption from the open market to decrease supply by decreasing the `redemptionFee`.

To finish a arbitrage cycle, an arbitrager would buy the Qi Token from open market, and redeem it against someone’s position. The profit formula is `profit = indexPrice - marketPrice - (gasFee + tradingFee + redemptionFee)` . During extreme price deviation, we would subsidize `gasFee` from the treasury. 

For redemption to work, we’ll start with the positions that have the lowest collateralization ratio. The positions who are redeemed against will not incur a net loss, but will have less ETH as collateral. At the same time, those positions collateralization ratio will increase after the redemption. 

**Mint/Burn Fee**

Mint and Burn fees are one-time charges to minting and burning to control the behavior of protocol participants. When the market price is higher than the index price, we would encourage minting and discourage burning to increase the supply. Both Mint and Burn fees are floating rate that are algorithmically determined by the deviation between index price and market price. 

### Solvency Maintenance

Qi Protocol’s solvency maintenance relies on four factors:

1. High collateralization ratio
2. Liquidation Engine
3. Angle Protocol like Hedging Agents
4. UniV3 Liquidity Positions Collateralization

**Collateralization Ratio(CR)**

Due to base fee’s high volatility, we’ll enforce a minimum of 200% CR. This will later be further defined by running dynamic simulations. The CR will have a inverse relationship with the look-back period used when calculating `TWAP(baseFee)` .

**Liquidation Engine**

Liquidation Engine will implement a MakerDAO-like liquidation process, where undercollateralized positions will be auctioned off to a group of willing bidders. The collateral will be transferred to the winning bidder and bids will be burned. 

**Hedging Agents(HA)**

Hedging Agents are agents looking to margin short Qi Token using ETH. It works as follows:

> HA comes in to open a position, they bring a certain amount of collateral (their margin), and choose an amount of the same collateral from the Qi protocol they want to hedge (or cover/back). The contract then stores the index base fee value and timestamp at which they opened a position.
> 
> 
> Hedging Agents are independent from one another, meaning that the actions of one Hedging Agent have no impact on the position of another Hedging Agent.
> 
> Precisely speaking, if a HA enters with an amount `x` of collateral (`x`is the margin) and decides to take on the volatility of an amount `y` of the same collateral (`y` is the amount committed, or the position size) that was brought by users minting Qi Tokens, then the contract stores `x`, `y`, the index price value and the timestamp at which this HA came in.
> 
> At any given point in time, the HA is entitled to get from the protocol:
> 
> `cash_out_amount = x + y * (1 - initial_price/current_price)`
> 

If Qi price decreases against ETH, HA will gain leveraged returns on ETH. However, if Qi’s price increase against ETH significantly, HA’s position will be liquidated. 

Users who mints Qi token will have the option to allow HAs take on their collateral. The benefit of doing so is they will have an extra layer of protection against liquidation. The cost is any upside in the ETH will be captured by HAs. 

This is Angle Protocol’s way to explain how HA could help users absorb collateral volatility 

![alt text](https://github.com/FudgyDRS/eth-den-rgas-token/blob/main/pics/Screenshot%20from%202023-03-05%2002-42-14.png)

![alt text](https://github.com/FudgyDRS/eth-den-rgas-token/blob/main/pics/Screenshot%20from%202023-03-05%2002-42-40.png)

![alt text](https://github.com/FudgyDRS/eth-den-rgas-token/blob/main/pics/Screenshot%20from%202023-03-05%2002-43-15.png)

from [https://docs.angle.money/angle-core-module/hedging-agents](https://docs.angle.money/angle-core-module/hedging-agents)

**Uniswap-V3 Liquidity Positions Collateralization**

Qi Protocol allows users to collateralize in-range Qi/ETH LP positions to mint Qi Token. The collateral base will be calculated based on the number of ETH a user has in the LP position. 

Collateralizing UniV3’s LP position has some interesting benefit to the user. First, it earns trading fees to the user. Secondly, allowing users to collateralize a LP position allows user to leverage long Qi Token. To do so, one could open a LP position in the Qi/ETH pool to mint Qi Token, then use the minted Qi token to open a new LP position. Depending on the CR, one could leverage long Qi Token by doing this multiple cycles. 

To the protocol, it also helps Qi to stay solvent in time of liquidity crunch. Liquidity crunch likely will happen when network participants know in advance that Ethereum is going to become congested. One good example is NFT launches. When Qi Token holders know that the launch will take place soon, they will likely close their positions by burning Qi Token to avoid liquidations. However, users who mints Qi Tokens using UniV3 LP will benefit from events like this, while compensating the liquidity withdrawn by the user who collateralize ETH. This is because concentrated liquidity positions will only contain single asset when the price moves out of range. If the price of Qi Token goes up, moving out of range of a LP’s price range, his position will become 100% ETH. In other words, increasing Qi Token’s price will increase a LP’s CR. Therefore, in events of liquidity crunch, the protocol would incentivise users to collateralize UniV3 LP positions. 

## Legal Status

Qi Token is more likely a derivative contract instead of a security. In the context of cryptocurrency, the Howey Test is often used to determine whether a particular token or digital asset is a security, and therefore subject to securities regulations. The test consists of four prongs:

1. Investment of money: There must be an investment of money.
2. Common enterprise: There must be a common enterprise between the investor and the promoter.
3. Expectation of profit: The investor must have an expectation of profit from the investment.
4. Efforts of others: Any profit must come primarily from the efforts of others.

Qi Token will likely fail the 2nd prong. When applying Howey test to a cryptocurrency, the court will looks at the horizontal and vertical commonality between investor and promoter. Courts have stressed that horizontal commonality requires the expected profits of an investor to be tied to other investors “*by entrepreneurial efforts of a promoter*.” However, the profit of Qi Token is tied to the base fee, which is a indirect result of block production by a network of validators. Therefore, there are no “*entrepreneurial efforts of a promoter”.* Vertical Commonality focuses "on the relationship between the promoter and the body of investors”. But here, there are simply no “promoters”. The profit and loss of Qi Token does not rely on a single key party, but rely on a “sufficiently decentralized” network’s computational capacity. Therefore, Qi Token is not a security. 

## Next Steps

1. Use agent based simulation simulation techniques to engineer the parameters related to liquidation engine, redemption mechanism, HA, and LP collateralization
2. Parallel development of a gas management protocol based on [LedgerHedger](https://eprint.iacr.org/2022/056) 
3. Finish the Qi Protocol’s development
6. Integrating the Qi Token with AMMs such like [Panoptics](https://www.panoptic.xyz/), [Primitive Finance](https://www.primitive.xyz/), and [Voltz](https://www.voltz.xyz/) to construct synthetic options for Qi Token
