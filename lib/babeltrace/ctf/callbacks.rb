module Babeltrace
  module CTF

    CBRet = enum :OK, :OK_STOP, :ERROR_STOP, :ERROR_CONTINUE
    class Iter < FFI::ManagedStruct
      layout :dummy, :pointer
    end

    class Dependencies < FFI::Struct
      layout :dummy, :pointer

      def initialize(*args)
        super(CTF.bt_dependencies_create(*args, nil))
      end
    end

    class Event < FFI::Struct
      layout :dummy, :pointer
    end

    attach_function :bt_dependencies_create, [:string, :varargs], Dependencies.by_ref
#    attach_function :bt_dependencies_destroy, [Dependencies], nil

    callback :iter_callback, [Event, :pointer], CBRet
    attach_function :bt_ctf_iter_add_callback, [Iter, Babeltrace.find_type(:intern_str), :pointer, :int, :iter_callback, Dependencies, Dependencies, Dependencies], :int
  end
end
