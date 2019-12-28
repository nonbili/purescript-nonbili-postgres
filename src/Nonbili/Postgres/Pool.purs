module Nonbili.Postgres.Pool
  ( Pool
  , Client
  , newPool
  , connect
  , end
  , release
  , withTransaction
  , execute
  , Result
  , query
  ) where

import Prelude

import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (class DecodeJson, decodeJson)
import Data.Argonaut.Encode (encodeJson)
import Data.Either (Either)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff as Aff
import Effect.Class (liftEffect)
import Nonbili.Postgres.Class (class ToQueryParams, toQueryParams)
import Nonbili.Postgres.Config (ConnectionConfig, PoolConfig)

data Pool

data Client

foreign import newPool_ :: Json -> Json -> Effect Pool

newPool :: PoolConfig -> ConnectionConfig -> Effect Pool
newPool poolConfig connConfig =
  newPool_ (encodeJson poolConfig) (encodeJson connConfig)

foreign import connect_ :: Pool -> Effect (Promise Client)

connect :: Pool -> Aff Client
connect = Promise.toAffE <<< connect_

foreign import end_ :: Pool -> Effect (Promise Unit)

end :: Pool -> Aff Unit
end = Promise.toAffE <<< end_

foreign import release_ :: Client -> Effect Unit

release :: Client -> Aff Unit
release = liftEffect <<< release_

withTransaction :: forall a. Pool -> (Client -> Aff a) -> Aff a
withTransaction pool action = do
  client <- connect pool
  Aff.finally (release client) $ (do
    execute client "BEGIN" unit
    res <- action client
    execute client "COMMIT" unit
    pure res
    ) `Aff.catchError` \e -> do
      execute client "ROLLBACK" unit
      Aff.throwError e

foreign import query_ :: Client -> String -> Array Json -> Effect (Promise Json)

execute
  :: forall p
   . ToQueryParams p
  => Client -> String -> p -> Aff Unit
execute client qs params = do
  void $ Promise.toAffE $ query_ client qs (toQueryParams params)

type Result a = Either String
  { rows :: Array a
  , rowCount :: Int
  }

query
  :: forall p a
   . ToQueryParams p
  => DecodeJson a
  => Client -> String -> p -> Aff (Result a)
query client qs params = do
  res <- Promise.toAffE $ query_ client qs (toQueryParams params)
  pure $ decodeJson res
