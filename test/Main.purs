
module Test.Main where

import Prelude

import Data.Either (Either(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Aff as Aff
import Effect.Class.Console (logShow)
import Nonbili.Postgres as Pg
import Nonbili.Postgres.Pool as Pool


type Post =
  { title :: String
  , private :: Boolean
  }

post1 :: Post
post1 =
  { title: "t1"
  , private: true
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
        (1 /\ post1.title /\ post1.private)


      Pg.query client "SELECT * FROM post" unit >>= case _ of
        Left err -> Aff.throwError $ Aff.error err
        Right res -> logShow $ res.rows == [post1]
    Pool.end pool

