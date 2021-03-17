
import Development.Shake
import Development.Shake.FilePath
import Clash.Main ( defaultMain )

blinkerTop :: String
blinkerTop = "Blinker"

verilog :: FilePath
verilog = "_build/Blinker.topEntity"

main :: IO ()
main = shakeArgs shakeOptions{ shakeFiles = "_build" } $ do

  want ["_build/Blinker.bin"]

  phony "clean" $ do
    putInfo "Cleaning files in _build"
    removeFilesAfter "_build" ["//*"]

  phony "compile" $ need [verilog </> blinkerTop <.> "v"]
  phony "synth"   $ need ["_build/Blinker.json"]
  phony "pnr"     $ need ["_build/Blinker.asc"]
  phony "pack"    $ need ["_build/Blinker.bin"]
  phony "prog"    $ do
    putInfo "Program VELDT"
    need ["_build/Blinker.bin"]
    cmd_ "iceprog" "_build/Blinker.bin"

  -- clash compile
  verilog </> blinkerTop <.> "v" %> \_ -> do
    putInfo "Clash compile Blinker"
    liftIO $ defaultMain ["-fclash-hdldir", "_build", blinkerTop, "--verilog"]

  -- yosys synthesis
  "_build/Blinker.json" %> \out -> do
    putInfo "Synthesizing Blinker"
    need [verilog </> blinkerTop <.> "v"]
    cmd_ "yosys"
         "-q"
         "-p"
         ["synth_ice40 -top " ++ blinkerTop ++ " -json " ++ out ++ " -abc2"]
         [verilog </> "*.v"]

  -- place and route NextPNR
  "_build/Blinker.asc" %> \out -> do
    putInfo "Place and Route Blinker"
    need ["_build/Blinker.json", "Blinker.pcf"]
    cmd_ "nextpnr-ice40"
         "--up5k"
         "--package sg48"
         "--pcf Blinker.pcf"
         "--asc"
         [out]
         "--json _build/Blinker.json"

  -- ice pack
  "_build/Blinker.bin" %> \out -> do
    putInfo "Ice pack Blinker"
    need ["_build/Blinker.asc"]
    cmd_ "icepack" "_build/Blinker.asc" [out]