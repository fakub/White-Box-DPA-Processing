require "open3"
require "fileutils"
require "yaml"

Dir["./tools/*.rb"].each{|file| require file }

GS = YAML.load(File.read("glob_settings.yaml"))
