#!/usr/bin/env ruby20

require "./executor.rb"
require "./timeline.rb"
require "./helper.rb"
require "./task.rb"
require "./core.rb"
require "./balancer.rb"
require "./feed.rb"
require "./comm.rb"

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
$NEURON_PERC_BALANCE_TIME 	= 	500
$TRANSFER_PACKAGE_CAPACITY 	= 	2
$LCR_STATUS_REQUEST_TIME 	= 	300
$LLCRR_STATUS_REQUEST_TIME 	=	15
$CORE_TASK_BUFFER 			=	1
$MIN_TASK_DIFF				=	100
$MAX_TASK_DIFF				=	1000

$feed = nil

executor = Executor.new($cores_count, $task_count)
executor.start
# executor.init_simple()
# executor.start_simple()
 executor.print_result_simple()

puts "TOTAL TIME: #{$time}"
