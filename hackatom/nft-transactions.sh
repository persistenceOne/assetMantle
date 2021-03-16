#add chain id in config
assetClient config chain-id hackatom-chain

#set env variables
export NONCE="$RANDOM"
export SLEEP=5
export PASSWD="123123123"
export KEYRING="--keyring-backend test"
export MODE="-b sync"

_echo () {
  echo -e "\e[32m >>>> ${1} <<<< \e[0m";  
}

_echo "Create users"
export ACCOUNT_NAME_1=account1$NONCE
export ACCOUNT_NAME_2=account2$NONCE
export ACCOUNT_NAME_3=account3$NONCE
export ACCOUNT_NAME_4=account4$NONCE
assetClient keys add $ACCOUNT_NAME_1 $KEYRING
assetClient keys add $ACCOUNT_NAME_2 $KEYRING
assetClient keys add $ACCOUNT_NAME_3 $KEYRING
assetClient keys add $ACCOUNT_NAME_4 $KEYRING

_echo "Name users with their addresses"
export VALIDATOR=$(assetClient keys show -a validator $KEYRING)
export ACCOUNT_1=$(assetClient keys show -a $ACCOUNT_NAME_1 $KEYRING)
export ACCOUNT_2=$(assetClient keys show -a $ACCOUNT_NAME_2 $KEYRING)
export ACCOUNT_3=$(assetClient keys show -a $ACCOUNT_NAME_3 $KEYRING)
export ACCOUNT_4=$(assetClient keys show -a $ACCOUNT_NAME_4 $KEYRING)

_echo "Load coins in main"
assetClient tx send $VALIDATOR $ACCOUNT_1 10000stake -y $KEYRING $MODE
sleep $SLEEP
_echo "Send coins in users"
assetClient tx send $ACCOUNT_1 $ACCOUNT_3 110stake -y $KEYRING $MODE
sleep $SLEEP
assetClient tx send $ACCOUNT_3 $ACCOUNT_4 10stake -y $KEYRING $MODE
assetClient tx send $ACCOUNT_1 $ACCOUNT_2 100stake -y $KEYRING $MODE
sleep $SLEEP

# _echo "Recursively send coins"
# assetClient tx send $ACCOUNT_1 $ACCOUNT_3 100stake -y $KEYRING $MODE
# assetClient tx send $ACCOUNT_3 $ACCOUNT_2 50stake -y $KEYRING $MODE
# assetClient tx send $ACCOUNT_2 $ACCOUNT_4 5stake -y $KEYRING $MODE
# assetClient tx send $ACCOUNT_4 $ACCOUNT_2 5stake -y $KEYRING $MODE
# sleep $SLEEP

_echo "2. Define a nub identity and link keys to it."
export NUB_ID_1=nubID1$NONCE
export NUB_ID_2=nubID2$NONCE
export NUB_ID_3=nubID3$NONCE
assetClient tx identities nub -y --from $ACCOUNT_1 --nubID $NUB_ID_1 $KEYRING $MODE
assetClient tx identities nub -y --from $ACCOUNT_2 --nubID $NUB_ID_2 $KEYRING $MODE
assetClient tx identities nub -y --from $ACCOUNT_3 --nubID $NUB_ID_3 $KEYRING $MODE
sleep $SLEEP
export ACCOUNT_1_NUB_ID=$(echo $(assetClient q identities identities) | awk -v var="$ACCOUNT_1" '{for(i=1;i<=NF;i++)if($i==var)print $(i-6)"|"$(i-3)}')
export ACCOUNT_2_NUB_ID=$(echo $(assetClient q identities identities) | awk -v var="$ACCOUNT_2" '{for(i=1;i<=NF;i++)if($i==var)print $(i-6)"|"$(i-3)}')
export ACCOUNT_3_NUB_ID=$(echo $(assetClient q identities identities) | awk -v var="$ACCOUNT_3" '{for(i=1;i<=NF;i++)if($i==var)print $(i-6)"|"$(i-3)}')

export IDENTITY_DEFINE_IMMUTABLE_1_ID="identityDefineImmutable1$NONCE"
export IDENTITY_DEFINE_IMMUTABLE_1="$IDENTITY_DEFINE_IMMUTABLE_1_ID:S|"
export IDENTITY_DEFINE_IMMUTABLE_META_1_ID="identityDefineImmutableMeta1$NONCE"
export IDENTITY_DEFINE_IMMUTABLE_META_1="$IDENTITY_DEFINE_IMMUTABLE_META_1_ID:I|identityDefineImmutableMeta1$NONCE"
export IDENTITY_DEFINE_MUTABLE_1_ID="identityDefineMutable1$NONCE"
export IDENTITY_DEFINE_MUTABLE_1="$IDENTITY_DEFINE_MUTABLE_1_ID:D|"
export IDENTITY_DEFINE_MUTABLE_META_1_ID="identityDefineMutableMeta1$NONCE"
export IDENTITY_DEFINE_MUTABLE_META_1="$IDENTITY_DEFINE_MUTABLE_META_1_ID:H|"
assetClient tx identities define -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_NUB_ID \
  --immutableProperties "$IDENTITY_DEFINE_IMMUTABLE_1" \
  --immutableMetaProperties "$IDENTITY_DEFINE_IMMUTABLE_META_1" \
  --mutableProperties "$IDENTITY_DEFINE_MUTABLE_1" \
  --mutableMetaProperties "$IDENTITY_DEFINE_MUTABLE_META_1" $KEYRING $MODE

sleep $SLEEP
_echo "------> ${IDENTITY_DEFINE_IMMUTABLE_META_1_ID}"
_echo "3. Use the identity to define an assest classification."
export IDENTITY_DEFINE_CLASSIFICATION=$(echo $(assetClient q classifications classifications) | awk -v var="$IDENTITY_DEFINE_IMMUTABLE_META_1_ID" '{for(i=1;i<=NF;i++)if($i==var)print $(i-10)"."$(i-7)}')
_echo "------> ${IDENTITY_DEFINE_CLASSIFICATION}"

assetClient tx identities issue -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_NUB_ID --classificationID $IDENTITY_DEFINE_CLASSIFICATION --to $ACCOUNT_1 \
  --immutableProperties "$IDENTITY_DEFINE_IMMUTABLE_1""stringValue" \
  --immutableMetaProperties "$IDENTITY_DEFINE_IMMUTABLE_META_1" \
  --mutableProperties "$IDENTITY_DEFINE_MUTABLE_1""1.01" \
  --mutableMetaProperties "$IDENTITY_DEFINE_MUTABLE_META_1""123" \
  $KEYRING $MODE

sleep $SLEEP
_echo "4. Delegate maintenance of a subset of the new assest classification's propertieis to one or more new identities."
export IDENTITY_ISSUE_ACCOUNT_1=$(echo $(assetClient q identities identities) | awk -v var="$IDENTITY_DEFINE_CLASSIFICATION" '{for(i=1;i<=NF;i++)if($i==var)print $i"|"$(i+3)}')
_echo "--> ${IDENTITY_ISSUE_ACCOUNT_1}"
assetClient tx identities provision -y --from $ACCOUNT_1 --to $ACCOUNT_4 --identityID $IDENTITY_ISSUE_ACCOUNT_1 $KEYRING $MODE
sleep $SLEEP

# _echo "Metas reveal"
# assetClient tx metas reveal -y --from $ACCOUNT_1 --metaFact "S|stringValue$NONCE" $KEYRING
# assetClient tx metas reveal -y --from $ACCOUNT_2 --metaFact "I|identityValue$NONCE" $KEYRING
# assetClient tx metas reveal -y --from $ACCOUNT_3 --metaFact "D|0.101010$NONCE" $KEYRING
# assetClient tx metas reveal -y --from $ACCOUNT_4 --metaFact "H|1$NONCE" $KEYRING
# sleep $SLEEP

_echo "5 Issue an asset"
export ASSET_DEFINE_IMMUTABLE_1_ID="assetDefineImmutable1$NONCE"
export ASSET_DEFINE_IMMUTABLE_1="$ASSET_DEFINE_IMMUTABLE_1_ID:S|"
export ASSET_DEFINE_IMMUTABLE_META_1_ID="assetDefineImmutableMeta1$NONCE"
export ASSET_DEFINE_IMMUTABLE_META_1="$ASSET_DEFINE_IMMUTABLE_META_1_ID:I|assetDefineImmutableMeta1$NONCE"
export ASSET_DEFINE_MUTABLE_1_ID="assetDefineMutable1$NONCE"
export ASSET_DEFINE_MUTABLE_1="$ASSET_DEFINE_MUTABLE_1_ID:D|"
export ASSET_DEFINE_MUTABLE_META_1_ID="assetDefineMutableMeta1$NONCE"
export ASSET_DEFINE_MUTABLE_META_1="$ASSET_DEFINE_MUTABLE_META_1_ID:H|"
assetClient tx assets define -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_NUB_ID \
  --immutableProperties "$ASSET_DEFINE_IMMUTABLE_1" \
  --immutableMetaProperties "$ASSET_DEFINE_IMMUTABLE_META_1" \
  --mutableProperties "$ASSET_DEFINE_MUTABLE_1" \
  --mutableMetaProperties "$ASSET_DEFINE_MUTABLE_META_1" $KEYRING $MODE

# export ASSET_DEFINE_IMMUTABLE_2_ID="assetDefineImmutable2$NONCE"
# export ASSET_DEFINE_IMMUTABLE_2="$ASSET_DEFINE_IMMUTABLE_2_ID:S|"
# export ASSET_DEFINE_IMMUTABLE_META_2_ID="assetDefineImmutableMeta2$NONCE"
# export ASSET_DEFINE_IMMUTABLE_META_2="$ASSET_DEFINE_IMMUTABLE_META_2_ID:I|assetDefineImmutableMeta$NONCE"
# export ASSET_DEFINE_MUTABLE_2_ID="assetDefineMutable2$NONCE"
# export ASSET_DEFINE_MUTABLE_2="$ASSET_DEFINE_MUTABLE_2_ID:D|"
# export ASSET_DEFINE_MUTABLE_META_2_ID="assetDefineMutableMeta2$NONCE"
# export ASSET_DEFINE_MUTABLE_META_2="$ASSET_DEFINE_MUTABLE_META_2_ID:H|"
# assetClient tx assets define -y --from $ACCOUNT_2 --fromID $ACCOUNT_2_NUB_ID \
#   --immutableProperties "$ASSET_DEFINE_IMMUTABLE_2" \
#   --immutableMetaProperties "$ASSET_DEFINE_IMMUTABLE_META_2" \
#   --mutableProperties "$ASSET_DEFINE_MUTABLE_2" \
#   --mutableMetaProperties "$ASSET_DEFINE_MUTABLE_META_2" $KEYRING $MODE

sleep $SLEEP
export ASSET_DEFINE_CLASSIFICATION_1=$(echo $(assetClient q classifications classifications) | awk -v var="$ASSET_DEFINE_IMMUTABLE_META_1_ID" '{for(i=1;i<=NF;i++)if($i==var)print $(i-10)"."$(i-7)}')
assetClient tx assets mint -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_NUB_ID --classificationID $ASSET_DEFINE_CLASSIFICATION_1 --toID $ACCOUNT_1_NUB_ID \
  --immutableProperties "$ASSET_DEFINE_IMMUTABLE_1""stringValue" \
  --immutableMetaProperties "$ASSET_DEFINE_IMMUTABLE_META_1" \
  --mutableProperties "$ASSET_DEFINE_MUTABLE_1""1.01" \
  --mutableMetaProperties "$ASSET_DEFINE_MUTABLE_META_1""123" \
  $KEYRING $MODE

# export ASSET_DEFINE_CLASSIFICATION_2=$(echo $(assetClient q classifications classifications) | awk -v var="$ASSET_DEFINE_IMMUTABLE_META_2_ID" '{for(i=1;i<=NF;i++)if($i==var)print $(i-10)"."$(i-7)}')
# assetClient tx assets mint -y --from $ACCOUNT_2 --fromID $ACCOUNT_2_NUB_ID --classificationID $ASSET_DEFINE_CLASSIFICATION_2 --toID $ACCOUNT_2_NUB_ID \
#   --immutableProperties "$ASSET_DEFINE_IMMUTABLE_2""stringValue" \
#   --immutableMetaProperties "$ASSET_DEFINE_IMMUTABLE_META_2" \
#   --mutableProperties "$ASSET_DEFINE_MUTABLE_2""1.01" \
#   --mutableMetaProperties "$ASSET_DEFINE_MUTABLE_META_2""123" \
#   $KEYRING $MODE

sleep $SLEEP
export ASSET_MINT_1=$(echo $(assetClient q assets assets) | awk -v var="$ASSET_DEFINE_CLASSIFICATION_1" '{for(i=1;i<=NF;i++)if($i==var)print $i"|"$(i+3)}')
# export ASSET_MINT_2=$(echo $(assetClient q assets assets) | awk -v var="$ASSET_DEFINE_CLASSIFICATION_2" '{for(i=1;i<=NF;i++)if($i==var)print $i"|"$(i+3)}')

# assetClient tx assets mutate -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_NUB_ID --assetID $ASSET_MINT_1 \
#   --mutableProperties "$ASSET_DEFINE_MUTABLE_1""1.012" \
#   --mutableMetaProperties "$ASSET_DEFINE_MUTABLE_META_1""1234" $KEYRING $MODE


# _echo "Remint asset2"
# assetClient tx assets mint -y --from $ACCOUNT_2 --fromID $ACCOUNT_2_NUB_ID --classificationID $ASSET_DEFINE_CLASSIFICATION_2 --toID $ACCOUNT_2_NUB_ID \
#   --immutableProperties "$ASSET_DEFINE_IMMUTABLE_2""stringValue" \
#   --immutableMetaProperties "$ASSET_DEFINE_IMMUTABLE_META_2" \
#   --mutableProperties "$ASSET_DEFINE_MUTABLE_2""1.01" \
#   --mutableMetaProperties "$ASSET_DEFINE_MUTABLE_META_2""123" \
#   $KEYRING $MODE
# sleep $SLEEP

_echo "8. Wrap a token into an NFT."
assetClient tx splits wrap -y --coins 20stake --from $ACCOUNT_1 --fromID $ACCOUNT_1_NUB_ID $KEYRING $MODE
assetClient tx splits wrap -y --coins 20stake --from $ACCOUNT_2 --fromID $ACCOUNT_2_NUB_ID $KEYRING $MODE
assetClient tx splits wrap -y --coins 20stake --from $ACCOUNT_3 --fromID $ACCOUNT_3_NUB_ID $KEYRING $MODE
sleep $SLEEP
# assetClient tx splits unwrap -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_NUB_ID --ownableID stake --split 1 $KEYRING $MODE
# assetClient tx splits unwrap -y --from $ACCOUNT_2 --fromID $ACCOUNT_2_NUB_ID --ownableID stake --split 1 $KEYRING $MODE
# assetClient tx splits unwrap -y --from $ACCOUNT_3 --fromID $ACCOUNT_3_NUB_ID --ownableID stake --split 1 $KEYRING $MODE
# sleep $SLEEP
# assetClient tx splits send -y --from $ACCOUNT_3 --fromID $ACCOUNT_3_NUB_ID --toID $ACCOUNT_3_NUB_ID --ownableID stake --split 1 $KEYRING $MODE

_echo "9. Define an order type to exchanage your class of NFT against a token."
export ORDER_MUTABLE_META_TRAITS="takerID:I|,exchangeRate:D|,expiry:H|,makerOwnableSplit:D|"
export ORDER_DEFINE_IMMUTABLE_1_ID="orderDefineImmutable1$NONCE"
export ORDER_DEFINE_IMMUTABLE_1="$ORDER_DEFINE_IMMUTABLE_1_ID:S|"
export ORDER_DEFINE_IMMUTABLE_META_1_ID="orderDefineImmutableMeta1$NONCE"
export ORDER_DEFINE_IMMUTABLE_META_1="$ORDER_DEFINE_IMMUTABLE_META_1_ID:I|orderDefineImmutableMeta1$NONCE"
export ORDER_DEFINE_MUTABLE_1_ID="orderDefineMutable1$NONCE"
export ORDER_DEFINE_MUTABLE_1="$ORDER_DEFINE_MUTABLE_1_ID:D|"
export ORDER_DEFINE_MUTABLE_META_1_ID="orderDefineMutableMeta1$NONCE"
export ORDER_DEFINE_MUTABLE_META_1="$ORDER_DEFINE_MUTABLE_META_1_ID:H|"
assetClient tx orders define -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_NUB_ID \
  --immutableProperties "$ORDER_DEFINE_IMMUTABLE_1" \
  --immutableMetaProperties "$ORDER_DEFINE_IMMUTABLE_META_1" \
  --mutableProperties "$ORDER_DEFINE_MUTABLE_1" \
  --mutableMetaProperties "$ORDER_DEFINE_MUTABLE_META_1"",takerID:I|,exchangeRate:D|,expiry:H|,makerOwnableSplit:D|" $KEYRING $MODE
sleep $SLEEP

# export ORDER_DEFINE_IMMUTABLE_2_ID="orderDefineImmutable2$NONCE"
# export ORDER_DEFINE_IMMUTABLE_2="$ORDER_DEFINE_IMMUTABLE_2_ID:S|"
# export ORDER_DEFINE_IMMUTABLE_META_2_ID="orderDefineImmutableMeta2$NONCE"
# export ORDER_DEFINE_IMMUTABLE_META_2="$ORDER_DEFINE_IMMUTABLE_META_2_ID:I|orderDefineImmutableMeta2$NONCE"
# export ORDER_DEFINE_MUTABLE_2_ID="orderDefineMutable2$NONCE"
# export ORDER_DEFINE_MUTABLE_2="$ORDER_DEFINE_MUTABLE_2_ID:D|"
# export ORDER_DEFINE_MUTABLE_META_2_ID="orderDefineMutableMeta2$NONCE"
# export ORDER_DEFINE_MUTABLE_META_2="$ORDER_DEFINE_MUTABLE_META_2_ID:H|"
# assetClient tx orders define -y --from $ACCOUNT_2 --fromID $ACCOUNT_2_NUB_ID \
#   --immutableProperties "$ORDER_DEFINE_IMMUTABLE_2" \
#   --immutableMetaProperties "$ORDER_DEFINE_IMMUTABLE_META_2" \
#   --mutableProperties "$ORDER_DEFINE_MUTABLE_2" \
#   --mutableMetaProperties "$ORDER_DEFINE_MUTABLE_META_2"",takerID:I|,exchangeRate:D|,expiry:H|,makerOwnableSplit:D|" $KEYRING $MODE
# sleep $SLEEP

_echo "10. Order make take cancel"
export ORDER_DEFINE_CLASSIFICATION_1=$(echo $(assetClient q classifications classifications) | awk -v var="$ORDER_DEFINE_IMMUTABLE_META_1_ID" '{for(i=1;i<=NF;i++)if($i==var)print $(i-10)"."$(i-7)}')
assetClient tx orders make -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_NUB_ID --classificationID $ORDER_DEFINE_CLASSIFICATION_1 --toID $ACCOUNT_1_NUB_ID \
  --makerOwnableID "$ASSET_MINT_1" --makerOwnableSplit "0.000000000000000001" --takerOwnableID stake \
  --immutableProperties "$ORDER_DEFINE_IMMUTABLE_1""stringValue" \
  --immutableMetaProperties "$ORDER_DEFINE_IMMUTABLE_META_1" \
  --mutableProperties "$ORDER_DEFINE_MUTABLE_1""1.01" \
  --mutableMetaProperties "$ORDER_DEFINE_MUTABLE_META_1""123,takerID:I|,exchangeRate:D|1" \
  $KEYRING $MODE

sleep $SLEEP
export ORDER_MAKE_1_ID=$(echo $(assetClient q orders orders) | awk -v var="$ORDER_DEFINE_IMMUTABLE_META_1_ID" '{for(i=1;i<=NF;i++)if($i==var)print $(i-19)"*"$(i-16)"*"$(i-13)"*"$(i-10)"*"$(i-7)}')
assetClient tx orders cancel -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_NUB_ID --orderID "$ORDER_MAKE_1_ID" $KEYRING $MODE
export ORDER_MAKE_2_ID=$(echo $(assetClient q orders orders) | awk -v var="$ORDER_DEFINE_IMMUTABLE_META_2_ID" '{for(i=1;i<=NF;i++)if($i==var)print $(i-19)"*"$(i-16)"*"$(i-13)"*"$(i-10)"*"$(i-7)}')
sleep $SLEEP


_echo "11. Execute the order."
assetClient tx orders take -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_NUB_ID --orderID "$ORDER_MAKE_2_ID" --takerOwnableSplit "0.000000000000000001" $KEYRING $MODE
sleep $SLEEP

_echo "12. Burn asset"
assetClient tx assets burn -y --from $ACCOUNT_2 --fromID $ACCOUNT_2_NUB_ID --assetID $ASSET_MINT_2 $KEYRING $MODE

# Maintainers deputize
