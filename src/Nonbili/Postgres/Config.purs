module Nonbili.Postgres.Config where

import Data.Maybe (Maybe(..))

type Config =
  { database :: Maybe String
  , host :: Maybe String
  , port :: Maybe Int
  , user :: Maybe String
  , password :: Maybe String
  , ssl :: Maybe Boolean
  , connectionString :: Maybe String
  -- pool configs
  , connectionTimeoutMillis :: Maybe Int
  , idleTimeoutMillis :: Maybe Int
  , max :: Maybe Int
  }

defaultConfig :: Config
defaultConfig =
  { database: Nothing
  , host: Nothing
  , port: Nothing
  , user: Nothing
  , password: Nothing
  , ssl: Nothing
  , connectionString: Nothing
  , connectionTimeoutMillis: Nothing
  , idleTimeoutMillis: Nothing
  , max: Nothing
  }
