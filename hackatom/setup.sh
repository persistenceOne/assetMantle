#make all

rm -rf ~/.AssetMantle/Node
rm -rf ~/.AssetMantle/Client

mkdir ~/.AssetMantle/Node
mkdir ~/.AssetMantle/Client

assetNode init --chain-id hackatom-chain hackatom
# assetClient keys add validator --keyring-backend test
assetClient keys add validator --recover --keyring-backend test <<y
wage thunder live sense resemble foil apple course spin horse glass mansion midnight laundry acoustic rhythm loan scale talent push green direct brick please
y
assetNode add-genesis-account validator 100000000000000stake  --keyring-backend test
assetNode gentx --name validator --amount 1000000000stake --keyring-backend test
assetNode collect-gentxs
