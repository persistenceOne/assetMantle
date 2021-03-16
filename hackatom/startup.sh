assetNode start --log_level "debug" >~/.AssetMantle/Node/log &
sleep 10
assetClient rest-server --chain-id test $1 $2 >~/.AssetMantle/Client/log &

tail -f ~/.AssetMantle/Node/log ~/.AssetMantle/Client/log
