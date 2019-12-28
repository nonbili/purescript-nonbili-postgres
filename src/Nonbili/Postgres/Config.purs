module Nonbili.Postgres.Config where

import Data.Maybe (Maybe(..))

type ConnectionConfig =
  { database :: Maybe String
  , host :: Maybe String
  , port :: Maybe Int
  , user :: Maybe String
  , password :: Maybe String
  , ssl :: Maybe Boolean
  , connectionString :: Maybe String
  }

defaultConnectionConfig :: ConnectionConfig
defaultConnectionConfig =
  { database: Nothing
  , host: Nothing
  , port: Nothing
  , user: Nothing
  , password: Nothing
  , ssl: Nothing
  , connectionString: Nothing
  }

type PoolConfig =
  { connectionTimeoutMillis :: Maybe Int
  , idleTimeoutMillis :: Maybe Int
  , max :: Maybe Int
  }

defaultPoolConfig :: PoolConfig
defaultPoolConfig =
  { connectionTimeoutMillis: Nothing
  , idleTimeoutMillis: Nothing
  , max: Nothing
  }
