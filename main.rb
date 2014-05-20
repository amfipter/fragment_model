#!/usr/bin/env ruby2.0

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
$cores_size = ARGV[1].to_i
$int_max = 2**64
$TASK_PER_CORE = 1
$DISTANCE_KOEF_PER_CORE 1
$DIFFUSION_THRESHOLD 10
$TASK_CAPACITY_PER_CORE 15
$FEED_REQEST_TIME 100
$DIFFUSION_BALANCE_TIME 100
$NEURON_PERC_BALANCE_TIME 500
$feed = nil

executor = Executor.new()
executor.init_simple()
executor.start_simple()
executor.print_result_simple()

puts "TOTAL TIME: #{$time}"
