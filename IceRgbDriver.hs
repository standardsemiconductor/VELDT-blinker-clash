{-# LANGUAGE CPP           #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds     #-}
module IceRgbDriver (Rgb, iceRgbDriver) where

import Clash.Prelude

#ifdef CABAL
import Clash.Annotations.Primitive
import System.FilePath
import qualified Paths_blinker
import System.IO.Unsafe

{-# ANN iceRgbDriverPrim hasBlackBox #-}
{-# ANN module (Primitive [Verilog] (unsafePerformIO Paths_blinker.getDataDir </> "prim")) #-}
#endif

type Rgb = ("red" ::: Bit, "green" ::: Bit, "blue" ::: Bit)

{-# NOINLINE iceRgbDriverPrim #-}
iceRgbDriverPrim
  :: Signal dom Bit
  -> Signal dom Bit
  -> Signal dom Bit
  -> Signal dom (Bit, Bit, Bit)
iceRgbDriverPrim r g b = bundle (r, g, b)

iceRgbDriver :: Signal dom Rgb -> Signal dom Rgb
iceRgbDriver rgb = let (r, g, b) = unbundle rgb
                    in iceRgbDriverPrim r g b
