#!/usr/bin/env ruby2.0

require "./executor.rb"
require "./timeline.rb"
require "./helper.rb"
require "./task.rb"
require "./core.rb"
require "./balancer.rb"

$time = 0
$task_count = ARGV[0].to_i
$cores_size = ARGV[1].to_i
$int_max = 2**64

executor = Executor.new()
executor.init_simple()
executor.start_simple()
executor.print_result_simple()

puts "TOTAL TIME: #{$time}"


