source ./.script/environment.sh

assetNode start >~/.AssetMantle/Node/log &
sleep 10
assetClient rest-server --chain-id "$AM_CHAIN_ID">~/.AssetMantle/Client/log &
echo "
Node and Client started up. For logs:
tail -f ~/.AssetMantle/Node/log
tail -f ~/.AssetMantle/Client/log
"
