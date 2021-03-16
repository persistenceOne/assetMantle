# HackAtom IBC & NFT Kitty Tasks

This directory contains scripts which solves IBC & NFT Kitty tasks from [2021. Cosmos hackaton](https://ru.hackatom.org/en).

## Tasks

- [x]  1. Import interNFT modules to your application/fork the assest mantle project.
- [x]  2. Defina a nub identity and link keys to it.
- [x]  3. Use the identity to define an assest classification.
- [x]  4. Delegate maintenance of a subset of the new assest classification's propertieis to one or more new identities.
- [x]  5. Issue an asset.
- [ ]  6. Refunge the asset.
- [ ]  7. Transfer assest.
- [x]  8. Wrap a token into an NFT.
- [ ]  9. Define an order type to exchanage your class of NFT against a token.
- [ ] 10. Create a sell NFT order.
- [ ] 11. Execute the order.
- [x] 12. Burn the NFT.

### Bonus (No Code)

- Create your NFT market place on demo.internft.org
- Create interesting/innovative NFT marketplace on the dApp
- Sell NFTs on the marketplace

### Docs & resources

- [Modules](http://github.com/persistenceOne/persistenceSdk)
- [Applications](https://github.com/persistenceOne/assetMantle)
- [Interchain working group](https://internft.org/)
- [Resources](http://demo.internft.org/)

## Preconditions

In order to run these scripts `assetMantle` and `assetClient` need to be built and installed on the $PATH.

## Scripts

- **setup.sh** - script that prepares nft chain (generates genesis file, create accounts, keys,...)
- **startup.sh** - script that runs asset mantle node and rest client
- **nft-transactions.sh** - the main script for tasks, it runs various commands to achieve requirement for each of the above tasks
- **shutdown.sh** - terminates asset mantle node and client
