Dir["./tools/*.rb"].each{|file| require file }

ADDR_LEN = 6   # bytes
N_FOR_FILTER = 32
TRACE_FILENAME = {bin: "trace", txt: "MemoryTracer.out"}
TRACES_DIR = "traces"
VISUAL_DIR = "visual"
NDOTS_DEFAULT = 100