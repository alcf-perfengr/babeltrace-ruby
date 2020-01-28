require 'walk'

module Babeltrace

  class Context # < ManagedStruct
    attr_reader :traces
    def initialize(ptr = Babeltrace.bt_context_create)
      super(ptr)
      @traces = []
    end

    def self.release(ptr)
      Babeltrace.bt_context_put(ptr)
    end

    def add_trace(path:, format: "ctf")
      handle_id = Babeltrace.bt_context_add_trace(self, path, format, nil, nil, nil)
      case format
      when "ctf"
        trace = CTF::Trace::new(self, handle_id)
      else
        trace = Trace::new(self, handle_id)
      end
      @traces.push trace
      trace
    end

    def add_traces(path:, format: "ctf")
      traces = []
      Walk.walk(path) do |path, dirs, files|
        trace = add_trace(path: path, format: format) if files.include?("metadata")
        traces.push trace if trace
      end
      traces
    end

    def remove_trace(trace_id)
      Babeltrace.bt_context_remove_trace(self, trace_id)
    end

    def get_timestamp_begin(clock_type = :REAL)
      return nil if traces.empty?
      traces.collect { |t| t.get_timestamp_begin(clock_type) }.min
    end

    def get_timestamp_end(clock_type = :REAL)
      return nil if traces.empty?
      traces.collect { |t| t.get_timestamp_end(clock_type) }.max
    end
  end

  attach_function :bt_context_create, [], Context
  attach_function :bt_context_add_trace, [Context, :string, :string, :packet_seek_callback, :pointer, :pointer], :int
  attach_function :bt_context_remove_trace, [Context, :int], :int
  attach_function :bt_context_get, [Context], :void
  attach_function :bt_context_put, [Context], :void

end
