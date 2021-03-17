module Blinker where

import Clash.Prelude
import Clash.Annotations.TH
import Control.Monad.State
import Data.Tuple
import Ice40.Clock ( Lattice12Mhz, latticeRst )
import Ice40.Rgb   ( rgbPrim )

type Byte = BitVector 8
type Rgb = ("red" ::: Bit, "green" ::: Bit, "blue" ::: Bit)

data Color = Red | Green | Blue
  deriving (NFDataX, Generic, Enum)

data Blinker = Blinker Color (Byte, Byte, Byte) (Index 24000000)
  deriving (NFDataX, Generic)

drive :: Color -> (Byte, Byte, Byte)
drive Red   = (0xFF, 0,    0)
drive Green = (0,    0xFF, 0)
drive Blue  = (0,    0,    0xFF)

pwm :: Byte -> Byte -> Bit
pwm p = boolToBit . (p <)

blinker :: State Blinker Rgb
blinker = do
  Blinker c (pwmRed, pwmGreen, pwmBlue) t <- get
  let (drvRed, drvGreen, drvBlue) = drive c
      done = t == maxBound -- 2 seconds
      t' = if done
        then 0
        else t + 1
      c' = nextColor done c
  put $ Blinker c' (pwmRed + 1, pwmGreen + 1, pwmBlue + 1) t'
  return (pwm pwmRed drvRed, pwm pwmGreen drvGreen, pwm pwmBlue drvBlue)
  where
    nextColor True  Blue = Red
    nextColor True  c    = succ c
    nextColor False c    = c

blinkerMealy :: HiddenClockResetEnable dom => Signal dom Rgb
blinkerMealy = mealy (runBlinker blinker) blinkerInit $ pure ()
  where
    runBlinker m s _ = swap $ runState m s
    blinkerInit = Blinker Red (0, 0, 0) 0

-- RGB driver primtive wrapper
rgb :: Signal dom Rgb -> Signal dom Rgb
rgb input = let (r, g, b) = unbundle input
            in rgbPrim "0b0" "0b111111" "0b111111" "0b111111" 1 1 r g b

{-# NOINLINE topEntity #-}
topEntity
  :: "clk" ::: Clock Lattice12Mhz
  -> "led" ::: Signal Lattice12Mhz Rgb
topEntity clk = rgb $ withClockResetEnable clk latticeRst enableGen blinkerMealy
makeTopEntityWithName 'topEntity "Blinker"    
