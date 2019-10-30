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

  class IterPosManaged < FFI::ManagedStruct
    class SeekUnion < FFI::Union
      layout :seek_time, :uint64,
             :restore, SavedPos.ptr
    end
    layout :type, IterPosType,
           :u, SeekUnion

    def self.release(ptr)
      Babeltrace.bt_iter_free_pos(ptr)
    end
  end

  class Iter < FFI::Struct
    layout :dummy, :pointer
    attr_accessor :child

    def next
      Babeltrace.bt_iter_next(self)
    end

    def get_pos
      Babeltrace.bt_iter_get_pos(self)
    end

    def set_pos(pos)
      Babeltrace.bt_iter_set_pos(self, pos)
    end

    def rewind
      pos = IterPos::new
      pos[:type] = :SEEK_BEGIN
      set_pos(pos)
    end

    def create_time_pos(timestamp)
      Babeltrace.bt_iter_create_time_pos(self, timestamp)
    end
  end

  attach_function :bt_iter_next, [Iter], :int
  attach_function :bt_iter_get_pos, [Iter], IterPosManaged.by_ref
  attach_function :bt_iter_free_pos, [IterPosManaged], :void
  attach_function :bt_iter_set_pos, [Iter, :pointer], :int #pointer to IterPos or IterPosManaged
  attach_function :bt_iter_create_time_pos, [Iter, :uint64], IterPosManaged.by_ref
end
