module Babeltrace
  attach_function :bt_trace_handle_get_path, [Context, :int], :string
  attach_function :bt_trace_handle_get_timestamp_begin, [Context, :int, ClockType], :uint64
  attach_function :bt_trace_handle_get_timestamp_end, [Context, :int, ClockType], :uint64
end
