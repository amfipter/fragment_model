#!/usr/bin/env ruby20

require "ai4r"
require "./executor.rb"
require "./timeline.rb"
require "./helper.rb"
require "./task.rb"
require "./core.rb"
require "./balancer.rb"
require "./feed.rb"
require "./comm.rb"
require "./ai.rb"
require "./profile.rb"

# $profile = Profile.new
# $profile.debug_print
# exit
$time = 0
$task_count = ARGV[0].to_i
$cores_count = ARGV[1].to_i
$int_max = 2**64
$debug = nil


$TASK_PER_CORE 				= 	1
$DISTANCE_KOEF_PER_CORE 	= 	10
$DIFFUSION_THRESHOLD 		= 	10
$TASK_CAPACITY_PER_CORE 	= 	15
$FEED_REQEST_TIME 			= 	100
$DIFFUSION_BALANCE_TIME 	= 	100
$NEURON_PERC_BALANCE_TIME 	= 	200
$TRANSFER_PACKAGE_CAPACITY 	= 	3
$LCR_STATUS_REQUEST_TIME 	= 	100
$LLCRR_STATUS_REQUEST_TIME 	=	150 
$CORE_TASK_BUFFER 			=	1
$MIN_TASK_DIFF				=	100
$MAX_TASK_DIFF				=	1000

$feed = nil
$net = nil

if(File.exists?("net_ser"))
  File.open("net_ser") do |file|
    $net = Marshal.load(file)
  end
else
  $net = Ai.create()
  Ai.train($net)
end

executor = Executor.new($cores_count, $task_count)
executor.start
# executor.init_simple()
# executor.start_simple()
executor.print_result_simple()

puts "TOTAL TIME: #{$time}"

File.open("net_ser", 'w') do |file|
  Marshal.dump($net, file)
end
