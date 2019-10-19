require 'ffi'

module Babeltrace
  extend FFI::Library
  ffi_lib "babeltrace"
end

require_relative 'babeltrace/types'
require_relative 'babeltrace/list'
require_relative 'babeltrace/clock_type'
require_relative 'babeltrace/format'
require_relative 'babeltrace/context'
require_relative 'babeltrace/iterator'
require_relative 'babeltrace/trace_handle'
