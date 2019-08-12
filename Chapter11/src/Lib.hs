{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}

module Lib where

import Data.Kind (Type)
import Data.Proxy
import Fcf
import GHC.TypeLits hiding (type (+))
import Unsafe.Coerce

data OpenSum (f :: k -> Type) (ts :: [k]) where
  UnsafeOpenSum :: Int -> f t -> OpenSum f ts

-- ts ~ '[ Int, Bool, String], t is extistentially an Int, Bool, or String but
-- we don't know which one
--
-- OpenSum ((->) String) '[Int, Bool] is capable of storing String -> Int
-- and String -> Bool
--
-- The Int is used to "remember" the type t had. e.g. If the Int is 2 and
-- ts ~ '[A, B, C, D] then t has type C.

-- FindElem is an alias for a first class type family,
-- "first class" means the type family is just a type
-- Remember =<< operates like function application
-- findIndex :: (a -> Bool) -> [a] -> Maybe Int
-- TyEq is partially applied to key, i.e. (key==)
-- Stuck behaves like a compile time undefined or "bottom" kind
-- because the compiler can't reduce the type family further
-- it will simply give up
type FindElem (key :: k) (ts :: [k]) =
  FromMaybe Stuck =<< FindIndex (TyEq key) ts

-- This type alias is used to help GHC realize
-- the result of FindElem is a Natural Number
type Member t ts = KnownNat (Eval (FindElem t ts))

findElem :: forall t ts. Member t ts => Int
findElem = fromIntegral . natVal $ Proxy @(Eval (FindElem t ts))
