{-# LANGUAGE OverloadedStrings #-}
-- | The controller stuff for the homepage feature.
module BrickApp.ModeAction.Homepage where

import qualified Data.Text                     as T
import qualified Data.Map                      as Map

import Brick.Widgets.Core (txt)
import qualified Brick.Widgets.Dialog          as D

import BrickApp.Types
import BrickApp.Types.Helpers
import Config.Homepage


-- FIXME: rename this function, very misleading
-- FIXME: needs another popup notice that it worked/replace the popup on OK, I guess!
-- | Function for setting current location as the homepage
setHomeDialog :: GopherBrowserState -> IO GopherBrowserState
setHomeDialog gbs =
  let (domain, port, resource, _, displayString) = gbsLocation gbs
      uri = T.unpack $ "gopher://" <> domain <> ":" <> (T.pack $ show port) <> resource
      -- FIXME: maybe should have a helper function since this gets repeated so dang much!
      -- this new gbs below will replace the current home dialog with a success dialog
      choices = [ ("Ok", Ok) ]
      pop = Popup
              { pDialogWidget = D.dialog (Just "Homepage Set!") (Just (0, choices)) 50--wtf what about max width for bug
              , pDialogMap = Map.fromList [("Ok", pure . closePopup)]
              , pDialogBody = txt "Success: Current page set as homepage!"
              }
      newGbs = gbs { gbsPopup = Just pop }
  in  setHomepage uri (fmap T.unpack displayString) >> pure newGbs

-- | The dialog for OK/cancel setting homepage to current
createHomeDialog :: GopherBrowserState -> GopherBrowserState
createHomeDialog gbs =
  let choices = [ ("Ok", Ok), ("Cancel", Cancel) ]
      pop = Popup
              { pDialogWidget = D.dialog (Just "Set Homepage?") (Just (0, choices)) 50--wtf what about max width for bug
              , pDialogMap = Map.fromList [("Ok", setHomeDialog), ("Cancel", pure . closePopup)]
              , pDialogBody = txt "Set current page as homepage?"
              }
  in gbs { gbsPopup = Just pop }