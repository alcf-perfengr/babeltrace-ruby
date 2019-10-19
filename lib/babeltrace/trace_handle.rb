module Babeltrace
  class Trace
    attr_reader :context
    attr_reader :handle_id
    def initialize(context, handle_id)
      @context = context
      @handle_id = handle_id
    end

    def get_path
      Babeltrace.bt_trace_handle_get_path(@context, @handle_id)
    end

    def get_timestamp_begin(clock_type = :REAL)
      Babeltrace.bt_trace_handle_get_timestamp_begin(@context, @handle_id, clock_type)
    end

    def get_timestamp_end(clock_type = :REAL)
      Babeltrace.bt_trace_handle_get_timestamp_end(@context, @handle_id, clock_type)
    end
  end

  attach_function :bt_trace_handle_get_path, [Context, :int], :string
  attach_function :bt_trace_handle_get_timestamp_begin, [Context, :int, ClockType], :uint64
  attach_function :bt_trace_handle_get_timestamp_end, [Context, :int, ClockType], :uint64
end
