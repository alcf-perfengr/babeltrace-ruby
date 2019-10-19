module Babeltrace

  class Context
    def initialize(ptr = Babeltrace.bt_context_create, retain = true)
      super(ptr)
      Babeltrace.bt_context_get(ptr) if retain
    end

    def self.release(ptr)
      Babeltrace.bt_context_put(ptr)
    end

    def add_trace(path:, format: "ctf")
      handle_id = Babeltrace.bt_context_add_trace(self, path, format, nil, nil, nil)
      case format
      when "ctf"
        return CTF::Trace::new(self, handle_id)
      else
        return Trace::new(self, handle_id)
      end
    end

    def remove_trace(trace_id)
      Babeltrace.bt_context_remove_trace(self, trace_id)
    end
  end

  attach_function :bt_context_create, [], Context
  attach_function :bt_context_add_trace, [Context, :string, :string, :packet_seek_callback, :pointer, :pointer], :int
  attach_function :bt_context_remove_trace, [Context, :int], :int
  attach_function :bt_context_get, [Context], :void
  attach_function :bt_context_put, [Context], :void

end
