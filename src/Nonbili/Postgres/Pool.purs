-- | Bindings to [pg.Pool](https://node-postgres.com/api/pool).

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
import Nonbili.Postgres.Config (Config)

-- | `pg.Pool` object.
data Pool

-- | Pooled client boject.
data Client

foreign import newPool_ :: Json -> Effect Pool

-- | Create a new pool with configuration.
newPool :: Config -> Effect Pool
newPool = newPool_ <<< encodeJson

foreign import connect_ :: Pool -> Effect (Promise Client)

-- | Acquire a client from the pool. Remember to release the client after,
-- | otherwise pool clients will be exhausted quickly. It's recommend to use
-- | `withTransaction`, which handles releasing client for you.
connect :: Pool -> Aff Client
connect = Promise.toAffE <<< connect_

foreign import end_ :: Pool -> Effect (Promise Unit)

-- | Disconnect all active clients. Useful at the end of a script to exit the
-- | process.
end :: Pool -> Aff Unit
end = Promise.toAffE <<< end_

foreign import release_ :: Client -> Effect Unit

-- | Release a client. When using `withTransaction`, no need to release
-- | manually.
release :: Client -> Aff Unit
release = liftEffect <<< release_

-- | Acquire a client from the pool, then run queries as a transaction.
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

-- | Same as `query`, but ignore all return values.
execute
  :: forall p
   . ToQueryParams p
  => Client -> String -> p -> Aff Unit
execute client qs params = do
  void $ Promise.toAffE $ query_ client qs (toQueryParams params)

-- | - `rows` - `decodeJson` is used to get `a`
-- | - `rowCount` - number of rows processed by the last command
-- | See https://node-postgres.com/api/result.
type Result a = Either String
  { rows :: Array a
  , rowCount :: Int
  }

-- | `pg` will construct SQL from provided query string and params. Check
-- | `ToQueryParams` for supported params.
query
  :: forall p a
   . ToQueryParams p
  => DecodeJson a
  => Client -> String -> p -> Aff (Result a)
query client qs params = do
  res <- Promise.toAffE $ query_ client qs (toQueryParams params)
  pure $ decodeJson res
