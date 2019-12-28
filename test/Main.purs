module Test.Main where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff as Aff
import Effect.Class.Console (logShow)
import Nonbili.Postgres as Pg
import Nonbili.Postgres.Pool as Pool

type Post =
  { id :: Int
  , title :: String
  , private :: Boolean
  -- , created :: Int
  }


main :: Effect Unit
main = do
  pool <- Pg.newPool Pg.defaultConfig
  Aff.launchAff_ do
    Pg.withTransaction pool \client -> do
      Pg.execute client """
        CREATE TEMPORARY TABLE post (
          id int NOT NULL PRIMARY KEY,
          title text NOT NULL,
          private bool NOT NULL,
          created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
        """ unit
      Pg.execute client "INSERT INTO post VALUES ($1, $2, $3)"
        (1 /\ "t1" /\ true)
      (res :: Pg.Result Post) <-
        Pg.query client "select * from post" unit
      logShow res
    Pool.end pool
