module Main where

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION, throw)
import Data.Maybe (Maybe(..))
import Data.StrMap (empty, singleton)
import Prelude (Unit)
import Snabbdom (VDOM, VNodeProxy, h, patchInitialSelector, text, toVNodeEventObject, toVNodeHookObjectProxy)

main :: forall e. Eff (err:: EXCEPTION, console :: CONSOLE, vdom :: VDOM | e) Unit
main = do
  patchInitialSelector "#app" parent

child :: forall e. VNodeProxy (console :: CONSOLE | e)
child = h "strong" {attrs : empty, on : toVNodeEventObject empty , hook : toVNodeHookObjectProxy
  { insert : Just (\e -> log "Child insert"), update : Nothing, destroy : Nothing} }
  [text "Yay"]


parent :: forall e. VNodeProxy (console :: CONSOLE, err :: EXCEPTION | e)
parent = h "div"
  { on : toVNodeEventObject (singleton "dblclick" (\e -> throw "Click"))
  , attrs : singleton "id"  "hello"
  , hook : toVNodeHookObjectProxy { insert : Nothing, update : Nothing, destroy : Nothing }
  }
  [ text "Hello Snabbdom"
  , child
  ]
