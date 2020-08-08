-- https://hackage.haskell.org/package/xmobar
Config {
       font = "xft:terminus:size=10"
       , additionalFonts = [ "xft:FontAwesome:size=10" ]
       , allDesktops = True
       , bgColor = "#002b36"
       , fgColor = "#657b83"
       --, border = BottomB
       --, borderColor = "#268bd2"
       --, borderWidth = 1,
       , position = TopW L 100
       , sepChar = "%"
       , alignSep = "}{"
       , template = "%StdinReader% }{ %multicpu% %thermal0% %memory% %disku% %battery%%dynnetwork%%myping%%mymail%%myalsa% %date% %kbd%"
       , commands = [
                    Run MultiCpu [ "-t", "<fc=#d33682><fn=1>\xf0e4</fn></fc> <total0>%<fc=#586e75>, </fc><total1>%"
                                 , "-L", "10"
                                 , "-H", "50"
                                 , "-l", "#586e75"
                                 , "-n", "#839496"
                                 , "-h", "#d33682"
                                 ] 50

                    --, Run MultiCoreTemp [ "-t", "Temp: <avg>°C | <avgpc>%"
                    --                    , "-L", "60", "-H", "80",
                    --                    , "-l", "green", "-n", "yellow", "-h", "red",
                    --                    , "--"
                    --                    , "--mintemp"
                    --                    , "20"
                    --                    , "--maxtemp"
                    --                    , "100"
                    --                    ] 50

                    --, Run CoreTemp ["-t", "<fc=#cb4b16><fn=1>\xf2c8</fn></fc> <core0>° <code>"
                    --               , "-L", "30"
                    --               , "-H", "75"
                    --               , "-l", "#586e75"
                    --               , "-n", "#839496"
                    --               , "-h", "#dc322f"] 50

                    , Run ThermalZone 0 [ "-t", "<fc=#cb4b16><fn=1>\xf2cb</fn></fc> <temp>°C"
                                        , "-L", "30"
                                        , "-H", "70"
                                        , "-l", "#586e75"
                                        , "-n", "#839496"
                                        , "-h", "#cb4b16"
                                        ] 50

                    , Run Memory [ "-t", "<fc=#6c71c4><fn=1>\xf2db</fn></fc> <usedratio>%"
                                 , "-L", "20"
                                 , "-H", "80"
                                 , "-l", "#586e75"
                                 , "-n", "#839496"
                                 , "-h", "#cb4b16"
                                 ] 50

                    , Run DiskU [("/", "<fc=#b58900><fn=1>\xf0ae</fn></fc> <freep>%")]
                                [ "-L", "20"
                                , "-H", "80"
                                , "-l", "#586e75"
                                , "-n", "#839496"
                                , "-h", "#b58900"
                                ] 50

                    , Run BatteryP [ "BAT0" ]
                                   [ "-t" , "<fc=#859900><fn=1>\xf240</fn></fc> <acstatus>"
                                   , "-L", "20"
                                   , "-H", "80"
                                   , "-l", "#dc322f"
                                   , "-n", "#839496"
                                   , "-h", "#859900"
                                   , "--" -- battery specific options
                                   -- discharging status
                                   , "-o", "<left>% <fc=#93a1a1><timeleft></fc>"
                                   -- AC "on" status
                                   , "-O", "<left>% <fc=#859900>charging</fc>"
                                   -- charged status
                                   , "-i", "<fc=#839496>charged</fc>"
                                   ] 50

                    , Run DynNetwork [ "-t", " <fc=#268bd2><fn=1>\xf078</fn></fc> <rx> <fc=#b58900><fn=1>\xf077</fn></fc> <tx>"
                                     , "-S", "True"
                                     , "-L", "10000"
                                     , "-H", "100000"
                                     , "-l", "#586e75"
                                     , "-n", "#839496"
                                     , "-h", "#859900"
                                     ] 50 -- can be empty

                    , Run Com "/home/qbbr/.xmonad/myping" [] "myping" 50 -- cbe
                    , Run Com "/home/qbbr/.xmonad/mymail" [] "mymail" 100 -- cbe
                    , Run Com "/home/qbbr/.xmonad/myalsa" [] "myalsa" 20

                    , Run Date "<fc=#2aa198><fn=1>\xf017</fn></fc> %d/%m/%Y <fc=#2aa198>%H:%M</fc>" "date" 300
                    --, Run Com "date" ["+[%a] %b %H:%M"] "mydate" 600
                    --, Run DateZone "%a %H:%M:%S" "de_DE.UTF-8" "Europe/Vienna" "viennaTime" 10
                    --, Run DateZone "%H:%M Z" "en_US" "GMT" "utc" 10
                    , Run StdinReader

                    , Run Kbd [ ("ru", "<fc=#eee8d5,#b58900>{ RU }</fc>")
                              , ("us", "<fc=#6c71c4>{ US }</fc>")
                              ]
                    ]
       }
