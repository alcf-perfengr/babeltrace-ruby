module Babeltrace
  module CTF
    Scope = enum :TRACE_PACKET_HEADER,
                 :STREAM_PACKET_CONTEXT,
                 :STREAM_EVENT_HEADER,
                 :STREAM_EVENT_CONTEXT,
                 :EVENT_CONTEXT,
                 :EVENT_FIELDS
    TypeID = enum :UNKNOWN,
                  :INTEGER,
                  :FLOAT,
                  :ENUM,
                  :STRING,
                  :STRUCT,
                  :UNTAGGED_VARIANT,
                  :VARIANT,
                  :ARRAY,
                  :SEQUENCE,
                  :NR

    StringEncoding = enum :NONE,
                          :UTF8,
                          :ASCII,
                          :UNKNOWN

    class Declaration < FFI::Struct
      layout :dummy, :pointer

      def field_type
        CTF.bt_ctf_field_type(self)
      end

      def get_int_signedness
        CTF.bt_ctf_get_int_signedness(self)
      end

      def int_signed?
        get_int_signedness == 1
      end

      def get_int_base
        CTF.bt_ctf_get_int_base(self)
      end

      def get_int_byte_order
        CTF.bt_ctf_get_int_byte_order(self)
      end

      def get_int_len
        CTF.bt_ctf_int_len(self)
      end

      def get_encoding
        CTF.bt_ctf_get_encoding(self)
      end

      def get_array_len
        CTF.bt_ctf_get_array_len(self)
      end
    end

    attach_function :bt_ctf_field_type, [Declaration], TypeID
    attach_function :bt_ctf_get_int_signedness, [Declaration], :int
    attach_function :bt_ctf_get_int_base, [Declaration], :int
    attach_function :bt_ctf_get_int_byte_order, [Declaration], :int
    attach_function :bt_ctf_get_int_len, [Declaration], :ssize_t
    attach_function :bt_ctf_get_encoding, [Declaration], StringEncoding
    attach_function :bt_ctf_get_array_len, [Declaration], :int

    class FieldDecl < FFI::Struct
      layout :dummy, :pointer

      def get_decl
        CTF.bt_ctf_get_decl_from_field_decl(self)
      end
      alias decl get_decl

      def get_name
        CTF.bt_ctf_get_decl_field_name(self)
      end
      alias name get_name
    end

    attach_function :bt_ctf_get_decl_from_field_decl, [FieldDecl], Declaration.by_ref
    attach_function :bt_ctf_get_decl_field_name, [FieldDecl], :string

    class Definition < FFI::Struct
      layout :dummy, :pointer

      def field_name
        CTF.bt_ctf_field_name(self)
      end
      alias name field_name

      def get_decl
        CTF.bt_ctf_get_decl_from_def(self)
      end
      alias decl get_decl

      def get_struct_field_count
        CTF.bt_ctf_get_struct_field_count(self)
      end
      alias struct_field_count get_struct_field_count

      def get_uint64
        CTF.bt_ctf_get_uint64(self)
      end

      def get_int64
        CTF.bt_ctf_get_int64(self)
      end

      def get_enum_int
        CTF.bt_ctf_get_enum_int(self)
      end

      def get_enum_str
        CTF.bt_ctf_get_enum_str(self)
      end

      def get_char_array
        CTF.bt_ctf_get_char_array(self)
      end

      def get_string
        CTF.bt_ctf_get_string(self)
      end

      def get_float
        CTF.bt_ctf_get_float(self)
      end

      def get_variant
        CTF.bt_ctf_get_variant(self)
      end

      def get_struct_field_index(i)
        CTF.bt_ctf_get_struct_field_index(self, i)
      end
    end

    attach_function :bt_ctf_field_name, [Definition], :string
    attach_function :bt_ctf_get_decl_from_def, [Definition], Declaration.by_ref
    attach_function :bt_ctf_get_struct_field_count, [Definition], :uint64
    attach_function :bt_ctf_get_uint64, [Definition], :uint64
    attach_function :bt_ctf_get_int64, [Definition], :int64
    attach_function :bt_ctf_get_enum_int, [Definition], Definition.by_ref
    attach_function :bt_ctf_get_enum_str, [Definition], :string
    attach_function :bt_ctf_get_char_array, [Definition], :pointer
    attach_function :bt_ctf_get_string, [Definition], :string
    attach_function :bt_ctf_get_float, [Definition], :double
    attach_function :bt_ctf_get_variant, [Definition], Definition.by_ref
    attach_function :bt_ctf_get_struct_field_index, [Definition, :uint64], Definition.by_ref

    class EventDecl < FFI::Struct
      layout :dummy, :pointer

      def get_name
        CTF.bt_ctf_get_decl_event_name(self)
      end
      alias name get_name

      def get_decl_fields(scope)
        count = FFI::MemoryPointer::new(:uint)
        list = FFI::MemoryPointer::new(:pointer)
        res = CTF.bt_ctf_get_decl_fields(self, scope, list, count)
        count = count.read(:uint)
        list = list.read_pointer.read_array_of_pointer(count)
        list.collect { |p| FieldDecl::new(p) }
      end
    end

    attach_function :bt_ctf_get_decl_event_name, [EventDecl], :string
    attach_function :bt_ctf_get_decl_fields, [EventDecl, Scope,  :pointer, :pointer], :int

    class Trace < Babeltrace::Trace
      def get_event_decl_list
        count = FFI::MemoryPointer::new(:uint)
        list = FFI::MemoryPointer::new(:pointer)
        res = CTF.bt_ctf_get_event_decl_list(@handle_id, @context, list, count)
        count = count.read(:uint)
        list = list.read_pointer.read_array_of_pointer(count)
        list.collect { |p| EventDecl::new(p) }
      end
    end

    attach_function :bt_ctf_get_event_decl_list, [:int, Context, :pointer, :pointer], :int

    class Event
      def get_context
        CTF.bt_ctf_event_get_context(self)
      end
      alias context get_context

      def get_handle_id
        CTF.bt_ctf_event_get_handle_id(self)
      end
      alias handle_id get_handle_id

      def get_top_level_scope(scope)
        CTF.bt_ctf_get_top_level_scope(self, scope)
      end
      alias top_level_scope get_top_level_scope

      def event_name
        CTF.bt_ctf_event_name(self)
      end
      alias name event_name

      def get_cycles
        CTF.bt_ctf_get_cycles(self)
      end
      alias cycles get_cycles

      def get_timestamp
        CTF.bt_ctf_get_timestamp(self)
      end
      alias timestamp get_timestamp

      def get_field_list(scope)
        count = FFI::MemoryPointer::new(:uint)
        list = FFI::MemoryPointer::new(:pointer)
        res = CTF.bt_ctf_get_field_list(self, scope, list, count)
        count = count.read(:uint)
        return [] if count == 0
        list = list.read_pointer.read_array_of_pointer(count)
        list.collect { |p| Definition::new(p) }
      end
      alias field_list get_field_list

      def get_field(scope, field)
        CTF.bt_ctf_get_field(self, scope, field)
      end

      def each_field(scope = :EVENT_FIELDS)
        if block_given?
          sc = self.top_level_scope(scope)
          self.field_list(sc).each { |f| yield f }
        else
          return to_enum(:each_field, scope)
        end
      end

      def find_field(field, scope = :EVENT_FIELDS)
        sc = self.top_level_scope(scope)
        r = get_field(sc, field)
        return nil if r.pointer.null?
        r
      end

      def get_index(field, index)
        CTF.bt_ctf_get_index(self, field, index)
      end
      
    end

    attach_function :bt_ctf_event_get_context, [Event], Context.by_ref
    attach_function :bt_ctf_event_get_handle_id, [Event], :int
    attach_function :bt_ctf_get_top_level_scope, [Event, Scope], Definition.by_ref
    attach_function :bt_ctf_event_name, [Event], :string
    attach_function :bt_ctf_get_cycles, [Event], :uint64
    attach_function :bt_ctf_get_timestamp, [Event], :uint64
    attach_function :bt_ctf_get_field_list, [Event, Definition, :pointer, :pointer], :int
    attach_function :bt_ctf_get_field, [Event, Definition, :string], Definition.by_ref
    attach_function :bt_ctf_get_index, [Event, Definition, :uint], Definition.by_ref
  end
end
