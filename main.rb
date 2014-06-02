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

#PROFILE CONFIG
$WRITE_PROFILE                  =   false
$READ_PROFILE                   =   true

#BALANCE CONFIG
$DIFFUSION_BALANCE              =   false
$SIMPLE_NEURON_BALANCE          =   false
$NEURON5_BALANCE                =   false
$HYBRID_NEURON_BALANCE          =   false
$ESOINN_PREDICTION_BALANCE      =   false
$SOM_PREDICTION_BALANCE         =   false
$PERC_PREDICTION_BALANCE        =   false
$HYBRID_PREDICTION_BALANCE      =   true

#HYBRID_PREDICTION CONFIG
$HYBRID_PREDICTION_PERC         =   false
$HYBRID_PREDICTION_ESOINN       =   false
$HYBRID_PREDICTION_SOM          =   false

#CORE CONFIG
$TASK_PER_CORE                  =    1
$DISTANCE_KOEF_PER_CORE         =    10
$DIFFUSION_THRESHOLD            =    5
$TASK_CAPACITY_PER_CORE         =    30
$FEED_REQEST_TIME               =    1250#10
$DIFFUSION_BALANCE_TIME         =    1250#4000
$NEURON_PERC_BALANCE_TIME       =    1250#4000
$TRANSFER_PACKAGE_CAPACITY      =    2
$LCR_STATUS_REQUEST_TIME        =    1250#10
$LLCRR_STATUS_REQUEST_TIME      =    1250#10
$CORE_TASK_BUFFER               =    1
$MIN_TASK_DIFF                  =    10000
$MAX_TASK_DIFF                  =    50000

#PROFILE PARSE CONFIG
$VECTOR_SEQ_SIZE = 5

#ESOINN CONFIG
$MAX_INT = 2**64
$MAX_AGE = 100
$N = 0
$K = 0
$lambda = 50
$mark = 0
$c1 = 0.001
$c2 = 1.0

#SOM CONFIG
$NUM_OF_NODES = 5
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

# Ai.train_esoinn_seq(Ai.create_esoinn_seq(), $profile.all_data_seq_s)
# exit

$net = Util.serialization_load($SIMPLE_PERC_SER_NAME)
$net5 = Util.serialization_load($TEST_PERC_SER_NAME)
$hybrid_net = Util.serialization_load($HYBRID_ESOINN_NET_SER_NAME)
$esoinn_prediction_net = Util.serialization_load($ESOINN_PREDICTION_NET_SER_NAME)
$som_prediction_net = Util.serialization_load($SOM_PREDICTION_NET_SER_NAME)
$perc_prediction_net = Util.serialization_load($PERC_PREDICTION_NET_SER_NAME)

Util.net_init_simple_perc()

$profile.create_answer_s() if $READ_PROFILE

Util.net_init()

executor = nil
Signal.trap("TSTP") do
  executor.print_result_simple
end


executor = Executor.new($cores_count, $task_count)
executor.start
# executor.init_simple()
# executor.start_simple()
executor.print_result_simple()

puts "TOTAL TIME: #{$time}"
puts $esoinn_prediction_net.i1
puts $esoinn_prediction_net.i2

Util.serialization_save($net, $SIMPLE_PERC_SER_NAME)
Util.serialization_save($net5, $TEST_PERC_SER_NAME)
Util.serialization_save($hybrid_net, $HYBRID_ESOINN_NET_SER_NAME)
Util.serialization_save($esoinn_prediction_net, $ESOINN_PREDICTION_NET_SER_NAME)
Util.serialization_save($som_prediction_net, $SOM_PREDICTION_NET_SER_NAME)
Util.serialization_save($perc_prediction_net, $PERC_PREDICTION_NET_SER_NAME)
