TOP := Blinker

all: $(TOP).bin

$(TOP).bin: $(TOP).asc
	icepack $< $@

$(TOP).asc: $(TOP).json $(TOP).pcf 
	nextpnr-ice40 --up5k --package sg48 --pcf $(TOP).pcf --asc $@ --json $<

$(TOP).json: src/$(TOP).hs
	cabal build $<
	cabal run clash --write-ghc-environment-files=always -- $(TOP) --verilog
	yosys -q -p "synth_ice40 -top $(TOP) -json $@ -abc2" verilog/$(TOP)/$(TOP)/*.v

prog: $(TOP).bin
	iceprog $<

build: src/$(TOP).hs
	cabal build $<

clean:
	rm -rf verilog/
	rm -f $(TOP).json
	rm -f $(TOP).asc
	rm -f $(TOP).bin
	find . -type f -name '*~' -delete
	rm -f *.hi
	rm -f *.o

clean-all:
	$(MAKE) clean
	cabal clean

.PHONY: all clean clean-all prog build
