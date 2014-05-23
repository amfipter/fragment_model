#!/usr/bin/env ruby21

require "ai4r"
require "colorize"
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
require "../esoinn_ruby/esoinn.rb"


# $profile.debug_print
# exit
$time = 0
$task_count = ARGV[0].to_i
$cores_count = ARGV[1].to_i
$int_max = 2**64
$debug = nil

$WRITE_PROFILE                  =   true
$READ_PROFILE                   =   true
$DIFFUSION_BALANCE              =   false
$SIMPLE_NEURON_BALANCE          =   true
$NEURON5_BALANCE                =   false
$HYBRID_NEURON_BALANCE			=	false

$TASK_PER_CORE 		        	= 	1
$DISTANCE_KOEF_PER_CORE         = 	10
$DIFFUSION_THRESHOLD 	       	= 	15
$TASK_CAPACITY_PER_CORE       	= 	30
$FEED_REQEST_TIME 		        = 	100
$DIFFUSION_BALANCE_TIME        	= 	100
$NEURON_PERC_BALANCE_TIME     	= 	100
$TRANSFER_PACKAGE_CAPACITY    	= 	1
$LCR_STATUS_REQUEST_TIME      	= 	100
$LLCRR_STATUS_REQUEST_TIME    	=   100
$CORE_TASK_BUFFER 			    =   1
$MIN_TASK_DIFF			       	=  	100
$MAX_TASK_DIFF	            	=   1000

#ESOINN CONFIG
$MAX_INT = 2**64
$MAX_AGE = 100
$N = 0
$K = 0
$lambda = 20
$mark = 0
$c1 = 0.0001
$c2 = 1.0

$feed = nil
$net = nil
$net5 = nil
$hybrid_net = nil

$profile = Profile.new if $READ_PROFILE

if(File.exists?("net_ser"))
  File.open("net_ser") do |file|
    $net = Marshal.load(file)
  end
else
  $net = Ai.create()
  Ai.train($net)
end

$profile.create_answer_s() if $READ_PROFILE

if(File.exists?("net5_ser"))
  File.open("net5_ser") do |file|
    $net5 = Marshal.load(file)
  end
else
  $net5 = Ai.create5()
  Ai.train5($net5, $profile.all_data, $profile.all_answer)
end

if(File.exists?("hybrid_net_ser"))
  File.open("hybrid_net_ser") do |file|
    $hybrid_net = Marshal.load(file)
  end
else
  $hybrid_net = Ai.create_hybrid()
  Ai.train_hybrid($hybrid_net, $profile.all_data, $profile.all_answer_s)
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

File.open("hybrid_net_ser", 'w') do |file|
  Marshal.dump($hybrid_net, file)
end
