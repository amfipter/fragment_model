#!/usr/bin/env ruby21

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


# $profile.debug_print
# exit
$time = 0
$task_count = ARGV[0].to_i
$cores_count = ARGV[1].to_i
$int_max = 2**64
$debug = nil

$WRITE_PROFILE                  =   false
$READ_PROFILE                   =   false
$DIFFUSION_BALANCE              =   true
$SIMPLE_NEURON_BALANCE          =   false
$NEURON5_BALANCE                =   false

$TASK_PER_CORE 			          	= 	1
$DISTANCE_KOEF_PER_CORE 	      = 	10
$DIFFUSION_THRESHOLD 	        	= 	15
$TASK_CAPACITY_PER_CORE       	= 	30
$FEED_REQEST_TIME 		          = 	100
$DIFFUSION_BALANCE_TIME        	= 	100
$NEURON_PERC_BALANCE_TIME     	= 	100
$TRANSFER_PACKAGE_CAPACITY    	= 	1
$LCR_STATUS_REQUEST_TIME      	= 	100
$LLCRR_STATUS_REQUEST_TIME    	=	  100
$CORE_TASK_BUFFER 			        =	  1
$MIN_TASK_DIFF			           	=  	10000
$MAX_TASK_DIFF			           	=	  100000

$feed = nil
$net = nil
$net5 = nil

$profile = Profile.new if $READ_PROFILE
if(File.exists?("net5_ser"))
  File.open("net5_ser") do |file|
    $net5 = Marshal.load(file)
  end
else
  $net5 = Ai.create5()
  Ai.train5($net5, $profile.all_data, $profile.all_answer)
end

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

File.open("net5_ser", 'w') do |file|
  Marshal.dump($net5, file)
end
