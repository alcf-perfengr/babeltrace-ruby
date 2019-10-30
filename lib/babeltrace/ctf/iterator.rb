module Babeltrace
  module CTF
    class Trace
      def iter_create(begin_pos: nil, end_pos: nil)
        CTF.bt_ctf_iter_create(@context, begin_pos, end_pos)
      end

      def iter_create_intersect
        begin_pos_ptr = FFI::MemoryPointer::new(:pointer)
        end_pos_ptr = FFI::MemoryPointer::new(:pointer)
        iter = CTF.bt_ctf_iter_create_intersect(@context, begin_pos_ptr, end_pos_ptr)
        begin_pos = IterPosManaged::new(begin_pos_ptr.read_pointer)
        end_pos = IterPosManaged::new(end_pos_ptr.read_pointer)
        [iter, begin_pos, end_pos]
      end
    end

    class Iter
      def self.release(ptr)
        CTF.bt_ctf_iter_destroy(ptr)
      end

      def get_iter
        return @iter if @iter
        @iter = CTF.bt_ctf_get_iter(self)
        @iter.child = self
        @iter
      end

      def read_event
        CTF.bt_ctf_iter_read_event(self)
      end

      def read_event_flag
        ptr = FFI::MemoryPointer::new(:int)
        event = CTF.bt_ctf_iter_read_event_flags(self, ptr)
        flags = ptr.read(:int)
        [event, flags]
      end

      def get_lost_events_count
        CTF.bt_ctf_get_lost_events_count(self)
      end

      def next
        get_iter.next
      end

      def get_pos
        get_iter.get_pos
      end

      def set_pos(pos)
        get_iter.set_pos(pos)
      end

      def rewind
        get_iter.rewind
      end

      def create_time_pos(timestamp)
        get_iter.create_time_pos(timestamp)
      end

      def each
        rewind
        if block_given?
          loop do
            e = self.read_event
            break if e.pointer.null?
            yield e
            r = self.next
            break if r != 0
          end
	else
          return to_enum(:each)
        end
      end

    end

    attach_function :bt_ctf_iter_create, [Context, :pointer, :pointer], Iter.by_ref #pointers to IterPos or IterPosManaged
    attach_function :bt_ctf_iter_create_intersect, [Context, :pointer, :pointer], Iter.by_ref
    attach_function :bt_ctf_get_iter, [Iter], Babeltrace::Iter.by_ref
    attach_function :bt_ctf_iter_destroy, [Iter], :void
    attach_function :bt_ctf_iter_read_event, [Iter], Event.by_ref
    attach_function :bt_ctf_iter_read_event_flags, [Iter, :pointer], Event.by_ref
    attach_function :bt_ctf_get_lost_events_count, [Iter], :uint64
  end
end
