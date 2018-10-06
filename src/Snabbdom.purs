module Snabbdom where

import Effect (Effect)
import Web.DOM.Element (Element)
import Data.Maybe (Maybe(..))
import Data.Map (Map)
import Data.Unit (Unit)

newtype VNodeProxy = VNodeProxy
  { sel :: String
  , data :: VNodeData
  , children :: Array VNodeProxy
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
type VNodeData =
  { attrs :: Map String String
  , on :: VNodeEventObject
  , hook :: VNodeHookObjectProxy
  }

foreign import data VNodeEventObject :: Type

-- | Transform a Map String representing a VNodeEventObject into its native counter part
foreign import toVNodeEventObject :: forall a. Map String (a -> Effect Unit) -> VNodeEventObject

-- | The insert hook is invoked once the DOM element for a vnode has been inserted into the document and the rest of the patch cycle is done.
-- | This means that you can do DOM measurements (like using getBoundingClientRect in this hook safely, knowing that no elements will be changed afterwards that could affect the position of the inserted elements.
-- |
-- | The destroy hook is invoked on a virtual node when its DOM element is removed from the DOM or if its parent is being removed from the DOM.
-- |
-- | The update hook is invoked whenever an element is being updated
type VNodeHookObject =
  { insert :: Maybe (VNodeProxy -> Effect Unit)
  , destroy :: Maybe (VNodeProxy -> Effect Unit)
  , update :: Maybe (VNodeProxy -> VNodeProxy -> Effect Unit)
  }

foreign import getElementImpl :: forall a. VNodeProxy -> (a -> Maybe a) -> Maybe a -> Maybe Element

-- | Safely get the elm from a VNode
getElement :: VNodeProxy -> Maybe Element
getElement proxy = getElementImpl proxy Just Nothing

foreign import data VNodeHookObjectProxy :: Type

-- | Transform a VNodeHookObject into its native counter part
foreign import toVNodeHookObjectProxy :: VNodeHookObject -> VNodeHookObjectProxy

foreign import data VDOM :: (Type -> Type)

-- | The patch function returned by init takes two arguments.
-- | The first is a DOM element or a vnode representing the current view.
-- | The second is a vnode representing the new, updated view.
-- | If a DOM element with a parent is passed, newVnode will be turned into a DOM node, and the passed element will be replaced by the created DOM node.
-- | If an old vnode is passed, Snabbdom will efficiently modify it to match the description in the new vnode.
-- | Any old vnode passed must be the resulting vnode from a previous call to patch.
-- | This is necessary since Snabbdom stores information in the vnode.
-- | This makes it possible to implement a simpler and more performant architecture.
-- | This also avoids the creation of a new old vnode tree.
foreign import patch :: VNodeProxy -> VNodeProxy -> Effect Unit

-- | Same as patch, but patches an initial DOM Element instead.
foreign import patchInitial :: Element -> VNodeProxy -> Effect Unit

-- | Same as patch initial, but takes a selector instead of a DOM Element.
foreign import patchInitialSelector :: String -> VNodeProxy -> Effect Unit

-- | Turns a String into a VNode
foreign import text :: String -> VNodeProxy

-- | It is recommended that you use snabbdom/h to create vnodes.
-- | h accepts a tag/selector as a string, an optional data object and an optional string or array of children.
foreign import h :: String -> VNodeData -> Array VNodeProxy -> VNodeProxy

-- | A hook that updates the value whenever it's attribute gets updated.
foreign import updateValueHook :: VNodeProxy -> VNodeProxy -> Effect Unit

