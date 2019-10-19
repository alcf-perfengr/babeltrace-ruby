module Babeltrace
  class Context < FFI::ManagedStruct
    layout :dummy, :pointer
  end

  class StreamPos < FFI::Struct
    layout :dummy, :pointer
  end

  class MmapStream < FFI::Struct
    layout :fd, :int,
           :list, ListHead,
           :priv, :pointer
  end

  class MmapStreamList < FFI::Struct
    layout :head, ListHead
  end

  class TraceDescriptor < FFI::Struct
    layout :dummy, :pointer
  end

  class TraceHandle < FFI::Struct
    layout :dummy, :pointer
  end

  callback :packet_seek_callback, [StreamPos, :size_t, :int], :void
  callback :open_trace_callback, [:string, :int, :packet_seek_callback, :pointer], TraceDescriptor.by_ref
  callback :open_mmap_trace_callback, [MmapStreamList, :packet_seek_callback, :pointer], TraceDescriptor.by_ref
  callback :close_trace_callback, [TraceDescriptor], :int
  callback :set_context_callback, [TraceDescriptor, Context], :void
  callback :set_handle_callback, [TraceDescriptor, TraceHandle], :void
  callback :timestamp_begin_callback, [TraceDescriptor, TraceHandle, ClockType], :uint64
  callback :timestamp_end_callback, [TraceDescriptor, TraceHandle, ClockType], :uint64
  callback :convert_index_timestamp_callback, [TraceDescriptor], :int

  class Format < FFI::Struct
    layout :name, :intern_str,
           :open_trace, :open_trace_callback,
           :open_mmap_trace, :open_mmap_trace_callback,
           :close_trace, :close_trace_callback,
           :set_context, :set_context_callback,
           :set_handle, :set_handle_callback,
           :timestamp_begin, :timestamp_begin_callback,
           :timestamp_end, :timestamp_end_callback,
           :convert_index_timestamp, :convert_index_timestamp_callback
  end

  attach_function :bt_lookup_format, [:intern_str], Format
  attach_function :bt_fprintf_format_list, [:pointer], :int
  attach_function :bt_register_format, [Format], :int
  attach_function :bt_unregister_format, [Format], :void
end
