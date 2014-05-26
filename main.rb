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

# Ai.kohonen_test
# # $profile.debug_print
#  exit
$time = 0
$task_count = ARGV[0].to_i
$cores_count = ARGV[1].to_i
$int_max = 2**64
$debug = nil

$WRITE_PROFILE                  =   false
$READ_PROFILE                   =   true
$DIFFUSION_BALANCE              =   false
$SIMPLE_NEURON_BALANCE          =   false
$NEURON5_BALANCE                =   false
$HYBRID_NEURON_BALANCE          =   true

#CORE CONFIG
$TASK_PER_CORE 		            =    1
$DISTANCE_KOEF_PER_CORE         =    10
$DIFFUSION_THRESHOLD 	       	=    15
$TASK_CAPACITY_PER_CORE       	=    30
$FEED_REQEST_TIME 		        =    100
$DIFFUSION_BALANCE_TIME        	=    100
$NEURON_PERC_BALANCE_TIME     	=    100
$TRANSFER_PACKAGE_CAPACITY    	=    1
$LCR_STATUS_REQUEST_TIME      	=    100
$LLCRR_STATUS_REQUEST_TIME    	=    100
$CORE_TASK_BUFFER 			    =    1
$MIN_TASK_DIFF			        =    100
$MAX_TASK_DIFF	               	=    1000

#PROFILE CONFIG
$VECTOR_SEQ_SIZE = 5

#ESOINN CONFIG
$MAX_INT = 2**64
$MAX_AGE = 100
$N = 0
$K = 0
$lambda = 10
$mark = 0
$c1 = 0.0001
$c2 = 1.0

#SOM CONFIG
$NUM_OF_NODES = 4
$LAYER_NUM_OF_NODES = 25

#MISC CONFIG
$SIMPLE_PERC_SER_NAME = "net_ser"
$TEST_PERC_SER_NAME = "net5_ser"
$HYBRID_ESOINN_NET_SER_NAME = "hybrid_esoinn_ser"
$HYBRID_SOM_NET_SER_NAME = "hybrid_som_ser"
$ESOINN_PREDICTION_NET_SER_NAME = "esoinn_prediction_ser"
$SOM_PREDICTION_NET_SER_NAME = "som_prediction_ser"
$PERC_PREDICTION_NET_SER_NAME = "perc_prediction_ser"

$feed = nil
$net = nil
$net5 = nil
$hybrid_net = nil
$esoinn_prediction_net = nil
$som_prediction_net = nil
$perc_prediction_net = nil 

$profile = Profile.new if $READ_PROFILE

Ai.train_esoinn_seq(Ai.create_esoinn_seq(), $profile.all_data_seq_s)
exit

$net = Util.serialization_load($SIMPLE_PERC_SER_NAME)
$net5 = Util.serialization_load($TEST_PERC_SER_NAME)
$hybrid_net = Util.serialization_load($HYBRID_ESOINN_NET_SER_NAME)

$profile.create_answer_s() if $READ_PROFILE

Util.net_init()


executor = Executor.new($cores_count, $task_count)
executor.start
# executor.init_simple()
# executor.start_simple()
executor.print_result_simple()

puts "TOTAL TIME: #{$time}"

Util.serialization_save($net, $SIMPLE_PERC_SER_NAME)
Util.serialization_save($net5, $TEST_PERC_SER_NAME)
Util.serialization_save($hybrid_net, $HYBRID_ESOINN_NET_SER_NAME)

