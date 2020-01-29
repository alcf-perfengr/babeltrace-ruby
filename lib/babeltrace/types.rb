module Babeltrace

  TYPES = [[:int, :intern_str]]
  TYPES.each { |orig, add|
    typedef orig, add
  }

  attach_function :bt_array_index, [Definition, :uint64], :pointer #Returns a definition
  attach_function :bt_sequence_len, [Definition], :uint64
  attach_function :bt_sequence_index, [Definition, :uint64], :pointer #Returns a definition
  class Definition #< FFI::Struct
    def array_index(i)
      d = Babeltrace.bt_array_index(self, i)
      return nil if d.null?
      self.class.new(d)
    end

    def sequence_len
      Babeltrace.bt_sequence_len(self)
    end

    def sequence_index(i)
      d = Babeltrace.bt_sequence_index(self, i)
      return nil if d.null?
      self.class.new(d)
    end
  end

end
