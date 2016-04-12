# the only file required
# requires all the other files
# introduces some global constants
# and more ...

require "open3"
require "fileutils"
require "yaml"
require "set"

Dir["./tools/*.rb"].each{|file| require file }

GS_FILE = "glob_settings.yaml"
	GS_TEMPL_FILE = "glob_settings.yaml.template"
GS = YAML.load(File.read(GS_FILE))

ACQ_FILE = "acquire.rb"
	SETT_TEMPL_FILE = "attack_settings.yaml.template"
MANFLT_FILE = "addr_row_filter.rb"
MANVIEW_FILE = "manual_view.rb"
ATTACK_FILE = "attack.rb"
MARK_ENCR_FILE = "mark_encryption.rb"
RES_PROC_FILE = "results_process.rb"
RES_DISP_FILE = "results_disp.rb"

class Settings
	attr_reader :hash
	
	def initialize(hash)
		@hash = hash
	end
	def reload(hash)
		@hash = hash
	end
	
	def has_key?(key)
		@hash.has_key?(key)
	end
	def [](key)
		$stderr.puts("# Warning: uninitialized key \"#{key.to_s}\" accessed!") unless has_key?(key)
		@hash[key]
	end
	def []=(key, value)
		@hash[key] = value
	end
end
