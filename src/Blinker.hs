module Blinker where

import Clash.Prelude
import Clash.Annotations.TH
import Ice40.Clock ( Lattice12Mhz, latticeRst )
import Ice40.Rgb   ( rgbPrim )

type Byte = BitVector 8
type Rgb = ("red" ::: Bit, "green" ::: Bit, "blue" ::: Bit)

data Color = Red | Green | Blue
  deriving (NFDataX, Generic, Enum, Eq)

data Blinker = Blinker Color (Byte, Byte, Byte) (Index 24000000)
  deriving (NFDataX, Generic)

drive :: Color -> (Byte, Byte, Byte)
drive Red   = (0xFF, 0,    0)
drive Green = (0,    0xFF, 0)
drive Blue  = (0,    0,    0xFF)

pwm :: Byte -> Byte -> Bit
pwm p = boolToBit . (p <)

blinkerT :: Blinker -> () -> (Blinker, Rgb)
blinkerT (Blinker c (pwmR, pwmG, pwmB) t) () = (s', (pwm pwmR drvR, pwm pwmG drvG, pwm pwmB drvB))
  where
    (drvR, drvG, drvB) = drive c
    s' = Blinker c' (pwmR + 1, pwmG + 1, pwmB + 1) t'
      where
        done = t == maxBound -- 2 seconds
        c' | not done  = c
           | c == Blue = Red
           | otherwise = succ c
        t' | done      = 0
           | otherwise = t + 1

blinkerMealy :: HiddenClockResetEnable dom => Signal dom Rgb
blinkerMealy = mealy blinkerT blinkerInit $ pure ()
  where
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
