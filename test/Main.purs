module Test.Main where

import Prelude
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Unsafe (unsafePerformEffect)
import Web.HTML (window)
import Web.HTML.Window (document)
import Web.HTML.HTMLDocument (toDocument, toParentNode)
import Web.DOM.Document (createElement)
import Web.DOM.Node (appendChild, textContent)
import Web.DOM.ParentNode (querySelector, QuerySelector(..))
import Web.DOM.Element (Element, toNode)
import Data.Maybe (Maybe(..), isJust, maybe)
import Data.Newtype (wrap)
import Data.Map (empty)
import Control.Monad.Maybe.Trans (lift, runMaybeT)
import Snabbdom (VNodeProxy, h, patchInitial, text, toVNodeEventObject, toVNodeHookObjectProxy)
import Test.QuickCheck (Result(..), (===))
import Test.Unit (suite, test)
import Test.Unit.Assert (assert)
import Test.Unit.Main (exit, runTest)
import Test.Unit.QuickCheck (quickCheck)

patchAndGetElement :: VNodeProxy -> Effect (Maybe Element)
patchAndGetElement proxy = do
  wndow <- window
  doc <- document wndow

  let findInDocument queryStr = querySelector (QuerySelector queryStr) $ toParentNode doc

  node <- createElement "div" $ toDocument doc
  runMaybeT do
    body <- wrap $ findInDocument "body"
    _ <- lift $ appendChild (toNode node) (toNode body)
    lift $ patchInitial node proxy
    wrap $ findInDocument "#msg"


main :: Effect Unit
main = do
  runTest do
    suite "Snabbdom" do
          test "DOM patching" do
              let message = "Hello World"
                  vNode = createVNode message
                  eff = patchAndGetElement vNode
              elem <- (liftEffect eff)
              assert "Message should be patched into the DOM" (isJust elem)
              quickCheck (maybe (Failed "failure") (compareTextContent message) elem)
  (exit 0)



compareTextContent :: String -> Element -> Result
compareTextContent message element =
  let node = toNode element
  in unsafePerformEffect (textContent node) === message



createVNode :: String -> VNodeProxy
createVNode message = h "strong#msg" { attrs : empty
  , on : toVNodeEventObject empty
  , hook : toVNodeHookObjectProxy { insert : Nothing, update : Nothing, destroy : Nothing}
  }
  [text message]
