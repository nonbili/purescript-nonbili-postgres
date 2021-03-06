module Nonbili.Postgres.Class where

import Prelude

import Data.Argonaut.Core (Json)
import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Data.Array ((:))
import Data.Tuple (Tuple(..))

-- | Query params can be:
-- |
-- | - `unit` - no param
-- | - `Array a` - an array of params with the same type
-- | - `Tuple a b` - an array of params with different types
-- |
-- | All params are serialized to `Json` when sending through FFI.
class ToQueryParams a where
  toQueryParams :: a -> Array Json

instance toQueryParamsUnit :: ToQueryParams Unit where
    toQueryParams = const []

instance toQueryParamsArray
  :: EncodeJson a => ToQueryParams (Array a) where
    toQueryParams xs = map encodeJson xs

instance toQueryParamsNestedTuple
  :: (EncodeJson a, ToQueryParams (Tuple b nested))
  => ToQueryParams (Tuple a (Tuple b nested)) where
    toQueryParams (Tuple a nested) = encodeJson a : toQueryParams nested
else instance toQueryParamsTuple
  :: (EncodeJson a, EncodeJson b) => ToQueryParams (Tuple a b) where
    toQueryParams (Tuple a b) = [encodeJson a, encodeJson b]
