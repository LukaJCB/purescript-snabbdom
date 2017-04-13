module Snabbdom where

import Control.Monad.Eff (Eff, kind Effect)
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
-- | Attrs allows you to set attributes on DOM elements.
-- |
-- | The event listeners module gives powerful capabilities for attaching event listeners.
-- | You can attach a function to an event on a vnode by supplying an object at on with a property corresponding to the name of the event you want to listen to.
-- | The function will be called when the event happens and will be passed the event object that belongs to it.
-- |
-- | Hooks are a way to hook into the lifecycle of DOM nodes.
-- | Snabbdom offers a rich selection of hooks.
-- | Hooks are used both by modules to extend Snabbdom, and in normal code for executing arbitrary code at desired points in the life of a virtual node.
type VNodeData e =
  { attrs :: StrMap String
  , on :: VNodeEventObject e
  , hook :: VNodeHookObjectProxy e
  }

foreign import data VNodeEventObject :: # Effect -> Type

-- | Transform a StrMap representing a VNodeEventObject into its native counter part
foreign import toVNodeEventObject :: forall a e. StrMap (a -> Eff e Unit) -> VNodeEventObject e

-- | The insert hook is invoked once the DOM element for a vnode has been inserted into the document and the rest of the patch cycle is done.
-- | This means that you can do DOM measurements (like using getBoundingClientRect in this hook safely, knowing that no elements will be changed afterwards that could affect the position of the inserted elements.
-- |
-- | The destroy hook is invoked on a virtual node when its DOM element is removed from the DOM or if its parent is being removed from the DOM.
-- |
-- | The update hook is invoked whenever an element is being updated
type VNodeHookObject e =
  { insert :: Maybe (VNodeProxy e -> Eff e Unit)
  , destroy :: Maybe (VNodeProxy e -> Eff e Unit)
  , update :: Maybe (VNodeProxy e -> VNodeProxy e -> Eff e Unit)
  }

foreign import getElementImpl :: forall a e. VNodeProxy e -> (a -> Maybe a) -> Maybe a -> Maybe Element

-- | Safely get the elm from a VNode
getElement :: forall e. VNodeProxy e -> Maybe Element
getElement proxy = getElementImpl proxy Just Nothing

foreign import data VNodeHookObjectProxy :: # Effect -> Type

-- | Transform a VNodeHookObject into its native counter part
foreign import toVNodeHookObjectProxy :: forall e. VNodeHookObject e -> VNodeHookObjectProxy e

foreign import data VDOM :: Effect

-- | The patch function returned by init takes two arguments.
-- | The first is a DOM element or a vnode representing the current view.
-- | The second is a vnode representing the new, updated view.
-- | If a DOM element with a parent is passed, newVnode will be turned into a DOM node, and the passed element will be replaced by the created DOM node.
-- | If an old vnode is passed, Snabbdom will efficiently modify it to match the description in the new vnode.
-- | Any old vnode passed must be the resulting vnode from a previous call to patch.
-- | This is necessary since Snabbdom stores information in the vnode.
-- | This makes it possible to implement a simpler and more performant architecture.
-- | This also avoids the creation of a new old vnode tree.
foreign import patch :: forall e. VNodeProxy e -> VNodeProxy e -> Eff (vdom :: VDOM | e) Unit

-- | Same as patch, but patches an initial DOM Element instead.
foreign import patchInitial :: forall e. Element -> VNodeProxy e -> Eff (vdom :: VDOM | e) Unit

-- | Same as patch initial, but takes a selector instead of a DOM Element.
foreign import patchInitialSelector :: forall e. String -> VNodeProxy e -> Eff (vdom :: VDOM | e) Unit

-- | Turns a String into a VNode
foreign import text :: forall e. String -> VNodeProxy (|e)

-- | It is recommended that you use snabbdom/h to create vnodes.
-- | h accepts a tag/selector as a string, an optional data object and an optional string or array of children.
foreign import h :: forall e. String -> VNodeData e -> Array (VNodeProxy e) -> VNodeProxy e

-- | A hook that updates the value whenever it's attribute gets updated.
foreign import updateValueHook :: forall e. VNodeProxy e -> VNodeProxy e -> Eff e Unit
