module Babeltrace
  IterPosType = enum :SEEK_TIME, :SEEK_RESTORE, :SEEK_CUR, :SEEK_BEGIN, :SEEK_LAST

  class SavedPos < FFI::Struct
    layout :dummy, :pointer
  end

  class IterPos < FFI::Struct
    class SeekUnion < FFI::Union
      layout :seek_time, :uint64,
             :restore, SavedPos.ptr
    end
    layout :type, IterPosType,
           :u, SeekUnion
  end

  class Iter < FFI::Struct
    layout :dummy, :pointer
  end

  attach_function :bt_iter_next, [Iter], :int
  attach_function :bt_iter_get_pos, [Iter], IterPos
  attach_function :bt_iter_free_pos, [IterPos], :void
  attach_function :bt_iter_set_pos, [Iter, IterPos], :int
  attach_function :bt_iter_create_time_pos, [Iter, :uint64], IterPos
end
