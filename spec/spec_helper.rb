$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'fluent/test'

# Disable Test::Unit
Test::Unit::AutoRunner.need_auto_run = false

Fluent::Test.setup
