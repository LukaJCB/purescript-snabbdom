module Test.Main where

import Prelude
import Control.Monad.Aff.AVar (AVAR)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Random (RANDOM)
import Control.Monad.Eff.Unsafe (unsafePerformEff)
import DOM (DOM)
import DOM.HTML (window)
import DOM.HTML.Document (body)
import DOM.HTML.Types (htmlDocumentToDocument, htmlElementToNode)
import DOM.HTML.Window (document)
import DOM.Node.Document (createElement)
import DOM.Node.Node (appendChild, textContent)
import DOM.Node.ParentNode (querySelector)
import DOM.Node.Types (Element, documentToParentNode, elementToNode)
import Data.Maybe (Maybe(..), isJust, maybe)
import Data.Nullable (toMaybe)
import Data.StrMap (empty)
import Snabbdom (VDOM, VNodeProxy, h, patchInitial, text, toVNodeEventObject, toVNodeHookObjectProxy)
import Test.QuickCheck (Result(..), (===))
import Test.Unit (suite, test)
import Test.Unit.Assert (assert)
import Test.Unit.Console (TESTOUTPUT)
import Test.Unit.Main (exit, runTest)
import Test.Unit.QuickCheck (quickCheck)
import Unsafe.Coerce (unsafeCoerce)

patchAndGetElement :: forall e. VNodeProxy (dom :: DOM | e) -> Eff (dom:: DOM, vdom :: VDOM | e) (Maybe Element)
patchAndGetElement proxy = do
  wndow <- window
  doc <- document wndow
  node <- createElement "div" (htmlDocumentToDocument doc)
  bdy <- body doc
  appendChild (elementToNode node) (htmlElementToNode (unsafeCoerce bdy))
  patchInitial node proxy
  elem <- (querySelector "#msg" (documentToParentNode (htmlDocumentToDocument doc)))
  pure (toMaybe elem)


main :: Eff (console :: CONSOLE, testOutput :: TESTOUTPUT, avar :: AVAR, dom :: DOM, vdom :: VDOM, random :: RANDOM) Unit
main = do
  runTest do
    suite "Snabbdom" do
          test "DOM patching" do
              let message = "Hello World"
                  vNode = createVNode message
                  eff = patchAndGetElement vNode
              elem <- (liftEff eff)
              assert "Message should be patched into the DOM" (isJust elem)
              quickCheck (maybe (Failed "failure") (compareTextContent message) elem)
  (exit 0)



compareTextContent :: String -> Element -> Result
compareTextContent message element =
  let node = elementToNode element
  in unsafePerformEff (textContent node) === message



createVNode :: forall e. String ->  VNodeProxy (| e)
createVNode message = h "strong#msg" { attrs : empty
  , on : toVNodeEventObject empty
  , hook : toVNodeHookObjectProxy { insert : Nothing, update : Nothing, destroy : Nothing}
  }
  [text message]
