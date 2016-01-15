require "open3"
require "fileutils"
require "yaml"
require "set"

Dir["./tools/*.rb"].each{|file| require file }

GS = YAML.load(File.read("glob_settings.yaml"))

ACQ_FILE = "acquire.rb"
MANFLT_FILE = "addr_row_filter.rb"
MANVIEW_FILE = "manual_view.rb"
ATTACK_FILE = "attack_n_mark.rb"
