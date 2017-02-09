module Snabbdom where

import Control.Monad.Eff (Eff)
import DOM.Node.Types (Element)
import Data.Maybe (Maybe(..))
import Data.StrMap (StrMap)
import Data.Unit (Unit)

newtype VNodeProxy e = VNodeProxy
  { sel :: String
  , data :: VNodeData e
  , children :: Array (VNodeProxy e)
  , elm :: Element
  }

type VNodeData e =
  { attrs :: StrMap String
  , on :: VNodeEventObject e
  , hook :: VNodeHookObjectProxy e
  }

foreign import data VNodeEventObject :: # ! -> *

foreign import toVNodeEventObject :: forall a e. StrMap (a -> Eff e Unit) -> VNodeEventObject e

type VNodeHookObject e =
  { insert :: Maybe (VNodeProxy e -> Eff e Unit)
  , destroy :: Maybe (VNodeProxy e -> Eff e Unit)
  , update :: Maybe (VNodeProxy e -> VNodeProxy e -> Eff e Unit)
  }

foreign import getElementImpl :: forall a e. VNodeProxy e -> (a -> Maybe a) -> Maybe a -> Maybe Element

getElement :: forall e. VNodeProxy e -> Maybe Element
getElement proxy = getElementImpl proxy Just Nothing

foreign import data VNodeHookObjectProxy :: # ! -> *

foreign import toVNodeHookObjectProxy :: forall e. VNodeHookObject e -> VNodeHookObjectProxy e

foreign import patch :: forall e. VNodeProxy e -> VNodeProxy e -> Eff e Unit

foreign import patchInitial :: forall e. Element -> VNodeProxy e -> Eff e Unit

foreign import patchInitialSelector :: forall e. String -> VNodeProxy e -> Eff e Unit

foreign import text :: forall e. String -> VNodeProxy (|e)

foreign import h :: forall e. String -> VNodeData e -> Array (VNodeProxy e) -> VNodeProxy e
