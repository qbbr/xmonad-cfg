import System.IO
import System.Exit
-- import System.Taffybar.Hooks.PagerHints (pagerHints)

import qualified Data.List as L

import XMonad
import XMonad.Actions.Navigation2D
import XMonad.Actions.UpdatePointer
import XMonad.Actions.Warp

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.UrgencyHook
import XMonad.Util.NamedWindows

import XMonad.Layout.Gaps
import XMonad.Layout.Fullscreen
import XMonad.Layout.BinarySpacePartition as BSP
import XMonad.Layout.NoBorders
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Spacing
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoFrillsDecoration
import XMonad.Layout.Renamed
import XMonad.Layout.Simplest
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Layout.ZoomRow

import XMonad.Util.Run
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Cursor

import Graphics.X11.ExtraTypes.XF86
import Graphics.X11.Xlib.Extras
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Data.Maybe
import Foreign.C.Types (CLong)

------------------------------------------------------------------------
-- CMDs
--
myTerminal = "uxterm"
myLockscreen = "slock"
myScreenshot = "scrot; notify-send -a 'screenshot' 'taken'"
mySelectScreenshot = "scrot -s"
myLauncher = "dmenu_run"
          ++ " -fn '" ++ myDmenuFont ++ "'"
          ++ " -nb '" ++ base03 ++ "'"
          ++ " -nf '" ++ base0 ++ "'"
          ++ " -sb '" ++ blue ++ "'"
          ++ " -sf '" ++ base2 ++ "'"


------------------------------------------------------------------------
-- Workspaces
--
myWorkspaces :: [String]
myWorkspaces = ["1:term", "2:dev", "3:web", "q:mail", "w:chat", "e:media", "a:", "s:", "d:"]


------------------------------------------------------------------------
-- Colors and borders
--
-- Current window title in xmobar.
xmobarTitleLingth = 50
--xmobarTitleColor  = base1

-- Workspace colors in xmobar.
--xmobarCurrentWorkspaceColor = blue
--xmobarHiddenWorkspaceColor  = base01
--xmobarUrgentWorkspaceColor  = orange

-- Solarized Dark colors
base03  = "#002b36"
base02  = "#073642"
base01  = "#586e75"
base00  = "#657b83"
base0   = "#839496"
base1   = "#93a1a1"
base2   = "#eee8d5"
base3   = "#fdf6e3"
yellow  = "#b58900"
orange  = "#cb4b16"
red     = "#dc322f"
magenta = "#d33682"
violet  = "#6c71c4"
blue    = "#268bd2"
cyan    = "#2aa198"
green   = "#859900"

-- Border
myNormalBorderColor   = base02
myFocusedBorderColor  = blue
--myInactiveBorderColor = base02
myBorderWidth         = 1

-- Sizes
gap          = 0
outerGaps    = 0
topbarHeight = 1

-- Fonts
myFont      = "xft:terminus:size=10"
myDmenuFont = "terminus:size=12"
--myFont2    = "xft:terminus:size=10:hinting=false:antialias=false"
--myBoldFont = "xft:terminus:size=10:bold"


------------------------------------------------------------------------
-- Window rules
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
  [
    className =? "jetbrains-idea"               --> doShift "2:dev"
  , title     =? "win0"                         --> (doCenterFloat <+> doShift "2:dev")
  , title     =? "Java"                         --> doShift "2:dev"
  , className =? "processing-app-Base"          --> doShift "2:dev"
  , className =? "Google-chrome"                --> doShift "3:web"
  , className =? "Chromium"                     --> doShift "3:web"
  , className =? "Firefox-esr"                  --> doShift "3:web"
  , className =? "Firefox"                      --> doShift "3:web"
  , className =? "mutt"                         --> doShift "q:mail"
  , resource  =? "desktop_window"               --> doIgnore
  , className =? "Gpick"                        --> doCenterFloat
  , resource  =? "feh"                          --> doCenterFloat
  , className =? "mpv"                          --> doCenterFloat
  , className =? "Pavucontrol"                  --> doCenterFloat
  , className =? "Lxappearance"                 --> doCenterFloat
  , className =? "TelegramDesktop"              --> doShift "w:chat"
  , className =? "Keepassx"                     --> doShift "d:"
  --, className =? "Xchat"                        --> doShift "w:chat"
  --, className =? "stalonetray"                  --> doIgnore
  , isFullscreen                                --> (doF W.focusDown <+> doFullFloat)
  -- , isFullscreen                             --> doFullFloat
  ] <+> manageMenus <+> manageDialogs


-- Helper to read a property
getProp :: Atom -> Window -> X (Maybe [CLong])
getProp a w = withDisplay $ \dpy -> io $ getWindowProperty32 dpy a w

-- Check window prop
checkAtom :: String -> String -> Query Bool
checkAtom name value = ask >>= \w -> liftX $ do
  a <- getAtom name
  val <- getAtom value
  mbr <- getProp a w
  case mbr of
    Just [r] -> return $ elem (fromIntegral r) [val]
    _ -> return False

checkDialog = checkAtom "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_DIALOG"
checkMenu = checkAtom "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_MENU"
manageMenus = checkMenu --> doFloat
manageDialogs = checkDialog --> doFloat

-- On workspace clicked
clickable :: [(WorkspaceId, Char)] -> WorkspaceId -> String
clickable ws w = fromMaybe w $ (\x -> xmobarAction ("xdotool key alt+" ++ show x) "1" w) <$> lookup w ws


------------------------------------------------------------------------
-- Layouts
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myGaps = gaps [(U, outerGaps), (R, outerGaps), (L, outerGaps), (D, outerGaps)]
addSpace = renamed [CutWordsLeft 2]-- . spacing gap
tab = avoidStruts
  $ renamed [Replace "T"]
  $ addTopBar
  $ myGaps
  $ tabbed shrinkText myTabTheme

layouts = avoidStruts (
            (
              renamed [CutWordsLeft 1]
            $ addTopBar
            $ windowNavigation
            $ renamed [Replace "B"]
            $ addTabs shrinkText myTabTheme
            $ subLayout [] Simplest
            $ myGaps
            $ addSpace (BSP.emptyBSP)
            )
            ||| tab
          )

myLayout = smartBorders
         $ mkToggle (NOBORDERS ?? FULL ?? EOT)
         $ layouts

myNav2DConf = def
  { defaultTiledNavigation    = centerNavigation
  , floatNavigation           = centerNavigation
  , screenNavigation          = lineNavigation
  , layoutNavigation          = [("Full", centerNavigation)
  -- line/center same results   ,("Tabs", lineNavigation)
  --                            ,("Tabs", centerNavigation)
                                ]
  , unmappedWindowRect        = [("Full", singleWindowRect)
  -- works but breaks tab deco  ,("Tabs", singleWindowRect)
  -- doesn't work but deco ok   ,("Tabs", fullScreenRect)
                                ]
  }


-- this is a "fake title" used as a highlight bar in lieu of full borders
-- (I find this a cleaner and less visually intrusive solution)
topBarTheme = def
  {
    fontName              = myFont
  , inactiveBorderColor   = base03
  , inactiveColor         = base03
  , inactiveTextColor     = base03
  , activeBorderColor     = blue
  , activeColor           = blue
  , activeTextColor       = blue
  , urgentBorderColor     = orange
  , urgentColor           = orange
  , urgentTextColor       = base3
  , decoHeight            = topbarHeight
  }

addTopBar =  noFrillsDeco shrinkText topBarTheme

myTabTheme = def
  { fontName              = myFont
  , activeColor           = blue
  , activeBorderColor     = blue
  , activeTextColor       = base2
  , inactiveColor         = base03
  , inactiveBorderColor   = base03
  , inactiveTextColor     = base00
  , urgentBorderColor     = orange
  , urgentColor           = orange
  , urgentTextColor       = base3
  }


------------------------------------------------------------------------
-- Key bindings
--
-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask = mod1Mask

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
  ----------------------------------------------------------------------
  -- Custom key bindings
  --

  [
  -- Lock the screen using command specified by myLockscreen.
    ((modMask, xK_0),
     spawn myLockscreen)

  -- Take a full screenshot using the command specified by myScreenshot.
  , ((modMask .|. controlMask .|. shiftMask, xK_p),
     spawn myScreenshot)

  -- Take a selective screenshot using the command specified by mySelectScreenshot.
  , ((modMask .|. shiftMask, xK_p),
     spawn mySelectScreenshot)

  -- Toggle current focus window to fullscreen
  , ((modMask, xK_f),
     sendMessage $ Toggle FULL)

  -- see /usr/include/X11/XF86keysym.h
  -- Mute volume.
  , ((0, xF86XK_AudioMute),
     spawn "volume-control --dzen --toggle")
  , ((controlMask, 0xffad), -- ctrl+num-
     spawn "volume-control --dzen --toggle")

  -- Decrease volume.
  , ((0, xF86XK_AudioLowerVolume),
     spawn "volume-control --dzen --decrement 5")
  , ((controlMask, 0xffaf), -- ctrl+num/
     spawn "volume-control --dzen --decrement 5")

  -- Increase volume.
  , ((0, xF86XK_AudioRaiseVolume),
     spawn "volume-control --dzen --increment 5")
  , ((controlMask, 0xffaa), -- ctrl+num*
     spawn "volume-control --dzen --increment 5")

  -- Decrement brightness
  , ((0, xF86XK_MonBrightnessDown),
     spawn "backlight-brightness-control --dzen --decrement")

  -- Increase brightness
  , ((0, xF86XK_MonBrightnessUp),
     spawn "backlight-brightness-control --dzen --increment")

  -- Mixer toggle headphone<->front (ctrl+num+)
  , ((controlMask, 0xffab),
     spawn "amixer -c 0 set Headphone toggle && amixer -c 0 set Front toggle")

  -- MPD next (ctrl+num6)
  , ((controlMask, 0xff98),
     spawn "mpc next")

  -- MPD prev (ctrl+num4)
  , ((controlMask, 0xff96),
     spawn "mpc prev")

  -- MPD play/pause (ctrl+num5)
  , ((controlMask, 0xff9d),
     spawn "mpc toggle")

  -- MPD seek+ (ctrl+num9)
  , ((controlMask, 0xff9a),
     spawn "mpc seek +5")

  -- MPD seek- (ctrl+num7)
  , ((controlMask, 0xff95),
     spawn "mpc seek -5")

  -- Audio previous.
  --, ((0, 0x1008FF16),
  --   spawn "")

  -- Play/pause.
  --, ((0, 0x1008FF14),
  --   spawn "")

  -- Audio next.
  --, ((0, 0x1008FF17),
  --   spawn "")

  -- Eject CD tray.
  --, ((0, 0x1008FF2C),
  --   spawn "eject -T")

  --------------------------------------------------------------------
  -- "Standard" xmonad key bindings
  --

  -- Spawn the launcher using command specified by myLauncher.
  , ((modMask, xK_p),
     spawn myLauncher)

  -- Start a terminal. Terminal to start is specified by myTerminal variable.
  , ((modMask .|. shiftMask, xK_Return),
     spawn $ XMonad.terminal conf)

  -- Close focused window.
  , ((modMask .|. shiftMask, xK_c),
     kill)

  -- Cycle through the available layout algorithms.
  , ((modMask, xK_space),
     sendMessage NextLayout)

  --  Reset the layouts on the current workspace to default.
  , ((modMask .|. shiftMask, xK_space),
     setLayout $ XMonad.layoutHook conf)

  -- Resize viewed windows to the correct size.
  , ((modMask, xK_n),
     refresh)

  -- Move focus to the next window.
  , ((modMask, xK_j),
     windows W.focusDown)

  -- Move focus to the previous window.
  , ((modMask, xK_k),
     windows W.focusUp  )

  -- Move focus to the master window.
  , ((modMask, xK_m),
     windows W.focusMaster  )

  -- Swap the focused window and the master window.
  , ((modMask, xK_Return),
     windows W.swapMaster)

  -- Swap the focused window with the next window.
  , ((modMask .|. shiftMask, xK_j),
     windows W.swapDown  )

  -- Swap the focused window with the previous window.
  , ((modMask .|. shiftMask, xK_k),
     windows W.swapUp    )

  -- Shrink the master area.
  , ((modMask, xK_h),
     sendMessage Shrink)

  -- Expand the master area.
  , ((modMask, xK_l),
     sendMessage Expand)

  -- Push window back into tiling.
  , ((modMask, xK_t),
     withFocused $ windows . W.sink)

  -- Increment the number of windows in the master area.
  , ((modMask, xK_comma),
     sendMessage (IncMasterN 1))

  -- Decrement the number of windows in the master area.
  , ((modMask, xK_period),
     sendMessage (IncMasterN (-1)))

  -- Toggle the status bar gap.
  , ((modMask, xK_b),
     sendMessage ToggleStruts)

  -- Quit xmonad.
  , ((modMask .|. controlMask .|. shiftMask, xK_q),
     io (exitWith ExitSuccess))

  -- Restart xmonad.
  , ((modMask .|. controlMask .|. shiftMask, xK_r),
  -- , ((modMask, xK_q), recompile True >> restart "xmonad" True)
     spawn "notify-send -a 'xmonad' ' ' 'recompile && restart' && xmonad --recompile && xmonad --restart")
  --, ((modMask, xK_q),
     --restart "xmonad" True)
  ]

  ++
  -- mod-{1,2,3,q,w,e,a,s,d}, Switch to workspace N
  -- mod-shift-{1,2,3,q,w,e,a,s,d}, Move client to workspace N
  [
    ((m .|. modMask, k), windows $ f i)
    | (i, k) <- zip (XMonad.workspaces conf) [xK_1, xK_2, xK_3, xK_q, xK_w, xK_e, xK_a, xK_s, xK_d]--[xK_1 .. xK_9]
    , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
  ]

  ++
  -- mod-{z,x}, Switch to physical/Xinerama screens 1, 2
  -- mod-shift-{z,x}, Move client to screen 1, 2
  [
    ((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
    | (key, sc) <- zip [xK_z, xK_x] [0..]
    , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
  ]

  ++
  -- Bindings for manage sub tabs in layouts please checkout the link below for reference
  -- https://hackage.haskell.org/package/xmonad-contrib-0.13/docs/XMonad-Layout-SubLayouts.html
  [
    -- Tab current focused window with the window to the left
    ((modMask .|. controlMask, xK_h), sendMessage $ pullGroup L)
    -- Tab current focused window with the window to the right
  , ((modMask .|. controlMask, xK_l), sendMessage $ pullGroup R)
    -- Tab current focused window with the window above
  , ((modMask .|. controlMask, xK_k), sendMessage $ pullGroup U)
    -- Tab current focused window with the window below
  , ((modMask .|. controlMask, xK_j), sendMessage $ pullGroup D)

  -- Tab all windows in the current workspace with current window as the focus
  , ((modMask .|. controlMask, xK_m), withFocused (sendMessage . MergeAll))
  -- Group the current tabbed windows
  , ((modMask .|. controlMask, xK_u), withFocused (sendMessage . UnMerge))

  -- Tab next/prev
  , ((modMask, xK_Tab), onGroup W.focusDown')
  , ((modMask .|. shiftMask, xK_Tab), onGroup W.focusUp')
  ]

  ++
  -- Some bindings for BinarySpacePartition
  -- https://github.com/benweitzman/BinarySpacePartition
  [
    ((modMask .|. controlMask,               xK_Right ), sendMessage $ ExpandTowards R)
  , ((modMask .|. controlMask .|. shiftMask, xK_Right ), sendMessage $ ShrinkFrom R)
  , ((modMask .|. controlMask,               xK_Left  ), sendMessage $ ExpandTowards L)
  , ((modMask .|. controlMask .|. shiftMask, xK_Left  ), sendMessage $ ShrinkFrom L)
  , ((modMask .|. controlMask,               xK_Down  ), sendMessage $ ExpandTowards D)
  , ((modMask .|. controlMask .|. shiftMask, xK_Down  ), sendMessage $ ShrinkFrom D)
  , ((modMask .|. controlMask,               xK_Up    ), sendMessage $ ExpandTowards U)
  , ((modMask .|. controlMask .|. shiftMask, xK_Up    ), sendMessage $ ShrinkFrom U)
  , ((modMask .|. controlMask,               xK_r     ), sendMessage BSP.Rotate)
  , ((modMask .|. controlMask,               xK_s     ), sendMessage BSP.Swap)
  -- , ((modMask,                               xK_n     ), sendMessage BSP.FocusParent)
  -- , ((modMask .|. controlMask,               xK_n     ), sendMessage BSP.SelectNode)
  -- , ((modMask .|. shiftMask,                 xK_n     ), sendMessage BSP.MoveNode)
  ]


------------------------------------------------------------------------
-- Mouse bindings
--
-- Focus rules
-- True if your focus should follow your mouse cursor.
--
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
  [
    -- mod-button1, Set the window to floating mode and move by dragging
    ((modMask, button1),
     (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
  , ((modMask, button2),
     (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
  , ((modMask, button3),
     (\w -> focus w >> mouseResizeWindow w))

  -- you may also bind events to the mouse scroll wheel (button4 and button5)
  ]


------------------------------------------------------------------------
-- Status bars and logging
-- Perform an arbitrary action on each internal state change or X event.
-- See the 'DynamicLog' extension for examples.
--
-- To emulate dwm's status bar
--
-- > logHook = dynamicLogDzen
--


------------------------------------------------------------------------
-- Startup hook
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
  setWMName "LG3D"
  spawn "notify-send -a 'xmonad' ' ' 'started'"
  --spawn     "bash ~/.xmonad/startup.sh"
  --setDefaultCursor xC_left_ptr


------------------------------------------------------------------------
-- Urency notify-send hook
--
data LibNotifyUrgencyHook = LibNotifyUrgencyHook deriving (Read, Show)

instance UrgencyHook LibNotifyUrgencyHook where
  urgencyHook LibNotifyUrgencyHook w = do
    name     <- getName w
    Just idx <- fmap (W.findTag w) $ gets windowset
    --spawn "notify-send test"
    safeSpawn "notify-send" ["-a", "xmonad", "on workspace [" ++ idx ++ "]", show name]


------------------------------------------------------------------------
-- Run xmonad with all the defaults we set up.
--
main = do
  xmproc <- spawnPipe "xmobar ~/.xmonad/xmobarrc.hs"
  -- xmproc <- spawnPipe "taffybar"
  xmonad
    $ docks
    $ withNavigation2DConfig myNav2DConf
    $ additionalNav2DKeys (xK_Up, xK_Left, xK_Down, xK_Right)
                          [
                            (myModMask,               windowGo  )
                          , (myModMask .|. shiftMask, windowSwap)
                          ]
                          False
    $ ewmh
    -- $ withUrgencyHook NoUrgencyHook
    $ withUrgencyHook LibNotifyUrgencyHook
    -- $ pagerHints -- uncomment to use taffybar
    $ def {
      terminal           = myTerminal
    , focusFollowsMouse  = myFocusFollowsMouse
    , borderWidth        = myBorderWidth
    , modMask            = myModMask
    , workspaces         = myWorkspaces
    , normalBorderColor  = myNormalBorderColor
    , focusedBorderColor = myFocusedBorderColor
      -- key bindings
    , keys               = myKeys
    , mouseBindings      = myMouseBindings
      -- hooks, layouts
    , layoutHook         = myLayout
    , logHook            = dynamicLogWithPP (myPP xmproc)
             -- >> updatePointer (x, y) (1, 1)
             -- >> updatePointer (Relative 1 1)
             -- >> updatePointer (0.75, 0.75) (0.75, 0.75)
    --, handleEventHook    = E.fullscreenEventHook
    , handleEventHook    = fullscreenEventHook
    , manageHook         = manageDocks <+> myManageHook
    , startupHook        = myStartupHook
    }
    where
      myPP :: Handle -> PP
      myPP xmproc = def
        {
          ppCurrent = xmobarColor base2 blue . wrap " " " "
        , ppHidden  = xmobarColor base00 base03 . wrap " " " " . clickable (zip myWorkspaces ['1', '2', '3', 'q', 'w', 'e', 'a', 's', 'd'])
        , ppUrgent  = xmobarColor base2 orange . wrap " " " "
        , ppSep     = " "
        , ppWsSep   = ""
        , ppTitle   = xmobarColor base1 "" . shorten xmobarTitleLingth
        , ppLayout  = xmobarColor yellow "" . wrap "<" ">" .
                      (\ x -> pad $ case x of
                        "Full" -> "F"
                        _      -> x
                      )
        , ppOutput  = hPutStrLn xmproc
        }
