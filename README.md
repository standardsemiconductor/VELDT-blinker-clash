[![Haskell CI](https://github.com/standardsemiconductor/VELDT-blinker-clash/actions/workflows/haskell.yml/badge.svg)](https://github.com/standardsemiconductor/VELDT-blinker-clash/actions/workflows/haskell.yml)

# VELDT-blinker-clash
VELDT blinker example with Clash

## Demo
![](blinker.gif)

## Prerequisites
1. Install & Setup [Clash](https://github.com/standardsemiconductor/VELDT-info#clash)
2. Install & Setup [Project IceStorm](https://github.com/standardsemiconductor/VELDT-info#project-icestorm)
3. Clone this repo:
   ```console
   foo@bar:~$ git clone https://github.com/standardsemiconductor/VELDT-blinker-clash.git
   foo@bar:~$ cd VELDT-blinker-clash
   foo@bar:~/VELDT-blinker-clash$ cabal build
   ```
## Usage
Plug VELDT into computer USB port, make sure switches are set to ON and FLASH. Verify PWR LED illuminated red. To program the VELDT and run the blinker example:
```console
foo@bar:~/VELDT-blinker-clash$ cabal run blinker -- prog
```

Other commands:
* `cabal run blinker -- compile` to compile source to Verilog
* `cabal run blinker -- synth` to synthesize with Yosys
* `cabal run blinker -- pnr` to place and route with NextPNR
* `cabal run blinker -- pack` to pack with `icepack`
* `cabal run blinker` will also pack the source into a bitstream
* `cabal run blinker -- clean` to clean the build directory `_build`
* `cabal run clashi` to start an interactive Clash repl

[`shake/Shake.hs`](shake/Shake.hs) is responsible for compiling the source with Clash and running the Icestorm flow.
## Info
VELDT avaliable now on [standardsemiconductor.com](https://www.standardsemiconductor.com)

More information about the board can be found in the [VELDT-info](https://github.com/standardsemiconductor/VELDT-info#veldt-info) repo

Follow Standard Semiconductor on [LinkedIn](https://www.linkedin.com/company/standard-semiconductor/)
