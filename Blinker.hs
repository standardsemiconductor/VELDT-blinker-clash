module Blinker where

import Clash.Prelude
import Clash.Annotations.TH
import Control.Monad.State
import Data.Tuple
import Rgb (rgb, Rgb)

type Byte = BitVector 8

data Color = Red | Green | Blue
  deriving (NFDataX, Generic, Enum)

data Blinker = Blinker Color (Byte, Byte, Byte) (Unsigned 26)
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
      done = t == 24000000 -- 2 seconds
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

{-# NOINLINE topEntity #-}
topEntity
  :: "clk" ::: Clock XilinxSystem
  -> "led" ::: Signal XilinxSystem Rgb
topEntity clk = rgb $ withClockResetEnable clk rst enableGen blinkerMealy
  where
    rst = unsafeFromHighPolarity $ pure False
makeTopEntityWithName 'topEntity "Blinker"    
