-- | This module is enough for most common cases.
-- | ```purescript
-- | import Nonbili.Postgres as Pg
-- | main = do
-- |   pool <- Pg.newPool Pg.defaultConfig
-- |   Aff.launchAff_ do
-- |     Pg.withTransaction pool \client -> do
-- |       (res :: Pg.Result { title :: String }) <-
-- |         Pg.query client "select * from post" unit
-- |       logShow res
-- | ```

module Nonbili.Postgres
  ( module Nonbili.Postgres.Pool
  , module Nonbili.Postgres.Class
  , module Nonbili.Postgres.Config
  ) where

import Nonbili.Postgres.Class (class ToQueryParams)
import Nonbili.Postgres.Config (Config, defaultConfig)
import Nonbili.Postgres.Pool (Client, Pool, Result, execute, newPool, query, withTransaction)
