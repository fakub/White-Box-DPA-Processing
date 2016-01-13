require "open3"
require "fileutils"
require "yaml"
require "set"

Dir["./tools/*.rb"].each{|file| require file }

GS = YAML.load(File.read("glob_settings.yaml"))
