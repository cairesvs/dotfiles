{-# LANGUAGE FlexibleInstances, MultiParamTypeClasses, TypeSynonymInstances #-}

import qualified Codec.Binary.UTF8.String as UTF8
import Data.Monoid

import XMonad
import qualified Data.Map as M
import Data.List
import XMonad.Actions.CycleWS
import XMonad.Layout.NoBorders
import XMonad.Hooks.ManageHelpers
import qualified XMonad.Layout.Fullscreen as FS
import XMonad.Util.Run(spawnPipe)
import XMonad.Hooks.DynamicLog
import System.IO
import Control.Monad
import qualified XMonad.StackSet as W

import XMonad.Hooks.EwmhDesktops (ewmh, fullscreenEventHook)
import XMonad.Hooks.ManageDocks
import XMonad.Config.Desktop
import XMonad.Util.SpawnOnce

-- Make our own Picture-in-Picture mode
import XMonad.Config.Prime (LayoutClass)
import Graphics.X11 (Rectangle(..))

data PiP a = PiP deriving (Show, Read)

mkpip rect@(Rectangle sx sy sw sh) (master:snd:ws) = [small, (master, rect)]
  where small = (snd, (Rectangle px py pw ph))
        px = sx + fromIntegral sw - fromIntegral pw - 32
        py = sy + fromIntegral sh - fromIntegral ph - 32
	pw = sw `div` 4
	ph = sh `div` 4
mkpip rect (master:ws) = [(master, rect)]
mkpip rect [] = []

instance LayoutClass PiP a where
    pureLayout PiP rect stack = mkpip rect ws
      where ws = W.integrate stack

    description _ = "PiP"

myTerminal      = "alacritty"
myFocusFollowsMouse = False
myClickJustFocuses = False

myModMask       = mod4Mask -- or mod4Mask for super
myWorkspaces    = ["web","a","b","c","long","mx","sfx"]

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [ ((0, xK_Print), (spawn "scrot"))
    , ((mod4Mask, xK_a), (spawn myTerminal))
    , ((mod4Mask, xK_b), (spawn "firefox-nightly"))
    , ((mod4Mask, xK_s), (spawn "alacritty -e pulsemixer"))
    , ((mod4Mask, xK_d), (spawn "launcher"))
    , ((mod4Mask, xK_c), (spawn "xterm"))
    , ((mod4Mask, xK_q), (spawn "/usr/bin/bash -c 'notify-send -i time \"Right now, it is\" \"$(date \"+%-I:%M %p, %A %B %d, %Y\")\n$(acpi | sed \"s/Battery 0://\")\"'"))
    , ((mod4Mask .|. shiftMask, xK_l), (spawn "slock"))
    , ((controlMask .|. mod4Mask, xK_Right), nextWS)
    , ((controlMask .|. mod4Mask, xK_Left), prevWS)
    , ((controlMask .|. mod4Mask .|. shiftMask, xK_Right), shiftToNext >> nextWS)
    , ((controlMask .|. mod4Mask .|. shiftMask, xK_Left), shiftToPrev >> prevWS)
    ] 

myLayout = tiled ||| (Mirror tiled) ||| Full ||| PiP
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = toRational (2 / (1 + sqrt 5 :: Double))

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "Gimp"           --> doFloat
    , className =? "transmission-gtk" --> doFloat
    , className =? "mpv" --> doFloat
    , fmap (isInfixOf "Pinentry") className --> doFloat
    , fmap (isInfixOf "MATLAB") className <&&> fmap (not . isInfixOf "MATLAB") (stringProperty "WM_NAME") --> doFloat
    , fmap (isInfixOf "show.py") (stringProperty "WM_NAME") --> doFullFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , className =? "kupfer.py"      --> doIgnore
    , className =? "foobar"      --> doShift "sfx"
    , title =? "foobar"      --> doShift "sfx"
    , fmap (isInfixOf "display") appCommand --> doFloat
    , fmap (isInfixOf "feh") appCommand --> doFloat
    --, (className =? "" <&&> title =? "") --> doShift "sfx" -- Spotify: https://bbs.archlinux.org/viewtopic.php?id=204636
    , (stringProperty "WM_WINDOW_ROLE" =? "GtkFileChooserDialog") --> doFullFloat
    , isFullscreen                  --> doFullFloat
    , FS.fullscreenManageHook
    ]
    where
    appCommand = stringProperty "WM_COMMAND"
    --doShiftAndGo = doF . liftM2 (.) W.greedyView W.shift

myStartupHook = do
  spawnOnce "$HOME/.config/polybar/launch.sh"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.
main = do
    xmonad $ desktopConfig {
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = 0,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        keys               = \c -> myKeys c `M.union` keys XMonad.def c,
        layoutHook         = desktopLayoutModifiers $ noBorders $ myLayout,
        manageHook         = myManageHook <+> manageHook desktopConfig,
        handleEventHook    = fullscreenEventHook <+> handleEventHook desktopConfig,
	startupHook        = myStartupHook <+> startupHook desktopConfig
    }
