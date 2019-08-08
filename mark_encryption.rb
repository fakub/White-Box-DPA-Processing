#!/usr/bin/env ruby

require "./tools/all.rb"

# print help
$stderr.puts("
Usage:
    $ ./#{File.basename(__FILE__)} <name> <attack_name> [-1 0 0b00000001 0]

where
            -1 ... number of traces, -1 ~ all
             0 ... key byte, from range 0..15
    0b00000001 ... successful target
             0 ... target bit (if applicable)

") or exit if ARGV[0].nil?

# load settings
settings = load_settings(ARGV[0])

# read arguments
arg_attn = ARGV[1]
arg_ntr = ARGV[2]
arg_byte = ARGV[3]
arg_target = ARGV[4]
arg_tbit = ARGV[5]
# set number of traces
n_traces = set_n_traces(arg_ntr,settings)
# set attacked key byte
attack_byte = set_attack_byte(arg_byte)
# set attack target
target = arg_target.nil? ? "0b00000001" : arg_target
# set target bit
tbit = (0..7).include?(arg_tbit.to_i) ? arg_tbit.to_i : 0

# load results
filename = "#{settings.attack_dir}/#{arg_attn}/#{n_traces}_#{attack_byte}_#{target}.yaml"
raise "
Results do not exist for
    attack_name = '#{arg_attn}',
       n_traces = #{n_traces},
           byte = #{attack_byte},
         target = #{target}." unless File.exists? filename
position = YAML.load(File.read filename)[tbit].first[2]

# emphasize
addr_beg = settings[:addr_beg]
addr_div = settings[:addr_div]
row_div = settings[:row_div]

emphed = "#{settings.traces_dir}/emph_#{n_traces}_#{attack_byte}_#{target}.png"
FileUtils.cp settings.png_preview, emphed
mask = mask_from_file(settings.range_filter_file) if settings.attack_range_flt

position /= 8
if settings.attack_range_flt
    cnt = 0
    mask.each.with_index do |tf,i|
        next unless tf
        (cnt = i and break) if cnt == position
        cnt += 1
    end
    position = cnt
end

addrrow = [IO.readlines(settings.txt_trace)[position].split[1].hex, position]

apixel = (addrrow[0] - addr_beg) / addr_div
rpixel = position / row_div

emph_in_image(apixel, rpixel, 120, emphed)

# next steps
puts "
See
    '#{emphed}'
 – this is probably where #{attack_byte}. key byte leaks using #{n_traces} traces and #{target} as target."

tell_filter_ranges(settings)
puts