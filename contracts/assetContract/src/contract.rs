#![allow(non_snake_case)]

use serde::{Deserialize, Serialize};
use thiserror::Error;
use cosmwasm_std::{
    attr, to_vec, from_slice, Addr, CosmosMsg, Deps, DepsMut, Env, MessageInfo, Response, Storage, StdError,
};
use cosmwasm_storage::{singleton, singleton_read, ReadonlySingleton, Singleton};
use schemars::JsonSchema;

pub static CONFIG_KEY: &[u8] = b"config";

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct State {
    pub arbiter: Addr,
    pub recipient: Addr,
    pub source: Addr,
}


#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct InstantiateMsg {
    pub arbiter: String,
    pub recipient: String,
}

/// MigrateMsg allows a priviledged contract administrator to run
/// a migration on the contract. In this (demo) case it is just migrating
/// from one hackatom code to the same code, but taking advantage of the
/// migration step to set a new validator.
///
/// Note that the contract doesn't enforce permissions here, this is done
/// by blockchain logic (in the future by blockchain governance)
#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub struct MigrateMsg {
    pub arbiter: String,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
#[serde(rename_all = "snake_case")]
pub enum QueryMsg {}


// failure modes to help test wasmd, based on this comment
// https://github.com/cosmwasm/wasmd/issues/8#issuecomment-576146751
#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
#[serde(rename_all = "snake_case")]
pub enum ExecuteMsg {
    AssetMint { properties: String },
}

#[derive(Error, Debug)]
pub enum ContractError {
    #[error("{0}")]
    Std(#[from] StdError),

    #[error("Unauthorized")]
    Unauthorized {},

}

pub fn config(storage: &mut dyn Storage) -> Singleton<State> {
    singleton(storage, CONFIG_KEY)
}

pub fn config_read(storage: &dyn Storage) -> ReadonlySingleton<State> {
    singleton_read(storage, CONFIG_KEY)
}

pub fn instantiate(
    deps: DepsMut,
    _env: Env,
    info: MessageInfo,
    msg: InstantiateMsg,
) -> Result<Response, ContractError> {
    deps.api.debug("here we go 🚀");

    deps.storage.set(
        CONFIG_KEY,
        &to_vec(&State {
            arbiter: deps.api.addr_validate(&msg.arbiter)?,
            recipient: deps.api.addr_validate(&msg.recipient)?,
            source: info.sender,
        })?,
    );

    // This adds some unrelated event attribute for testing purposes
    let mut resp = Response::new();
    resp.add_attribute("Let the", "hacking begin");
    Ok(resp)
}


pub fn migrate(
    deps: DepsMut,
    env: Env,
    msg: MigrateMsg,
) -> Result<Response, ContractError> {
    let data = deps
        .storage
        .get(CONFIG_KEY)
        .ok_or_else(|| StdError::not_found("State"))?;
    let mut config: State = from_slice(&data)?;
    config.arbiter = deps.api.addr_validate(&msg.arbiter)?;
    deps.storage.set(CONFIG_KEY, &to_vec(&config)?);

    Ok(Response::default())

}

pub fn query(
    deps: Deps,
    env: Env,
    msg: QueryMsg,
) -> Result<Response, ContractError> {
    match msg {}
}

pub fn execute(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    msg: ExecuteMsg,
) -> Result<Response<PersistenceSDK>, ContractError> {
    match msg {
        ExecuteMsg::AssetMint { properties } => do_asset_mint(deps, env, properties, info),
    }
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
#[serde(rename_all = "snake_case")]
pub struct AssetMintRaw {
    from: String,
    chainID: String,
    maintainersID: String,
    classificationID: String,
    asset_properties: String,
    lock: i64,
    burn: i64,
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
#[serde(rename_all = "snake_case")]
pub struct PersistenceSDK {
    msgtype: String,
    raw: AssetMintRaw,
}

// {"mint":{"msgtype":"assets/mint","raw":""}}
// this is a helper to be able to return these as CosmosMsg easier
impl From<PersistenceSDK> for CosmosMsg<PersistenceSDK> {
    fn from(p : PersistenceSDK) -> CosmosMsg<PersistenceSDK> {
        CosmosMsg::Custom(p)
    }
}

fn do_asset_mint(
    deps: DepsMut,
    env: Env,
    properties: String,
    info: MessageInfo,
) -> Result<Response<PersistenceSDK>, ContractError> {
    let state = config_read(deps.storage).load()?;
        if info.sender == state.arbiter {
            let from_addr = deps.api.addr_validate(&env.contract.address.to_string())?;
    
            // can add all the parameters as input params
            let mintMsg = AssetMintRaw {
                from: deps.api.addr_validate(&info.sender.to_string())?.to_string(),
                chainID: "".to_owned(),
                maintainersID: "".to_owned(),
                classificationID: "".to_owned(),
                asset_properties: properties,
                lock: -1,
                burn: -1,
            };
    
            let res = Response {
                submessages: vec![],
                messages: vec![PersistenceSDK {
                    msgtype: "assets/mint".to_string(),
                    raw: mintMsg,
                }
                .into()],
                attributes: vec![attr("action", "asset_mint"), attr("destination", &from_addr)],
                data: None,
            };
            Ok(res)
        } else {
            Err(ContractError::Unauthorized {})
        }
    
}
