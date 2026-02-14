# === CONFIG ===
TOP_MODULE = cpu_tb
OUTPUT     = cpu.out
VCD        = wave.vcd
FILELIST   = files.f

IVERILOG   = iverilog
VVP        = vvp
GTKWAVE    = gtkwave
IV_FLAGS   = -g2012 -Wall

# === DEFAULT TARGET ===
all: run

# compile
$(OUTPUT): $(FILELIST)
	$(IVERILOG) $(IV_FLAGS) -f $(FILELIST) -s $(TOP_MODULE) -o $(OUTPUT)

# run sim
run: $(OUTPUT)
	$(VVP) $(OUTPUT)

# view waveform
wave: run
	$(GTKWAVE) $(VCD)

# clean
clean:
	rm -f $(OUTPUT) $(VCD)
