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

    module Internal
      class Declaration # < FFI::Struct
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
          CTF.bt_ctf_get_int_len(self)
        end

        def get_encoding
          CTF.bt_ctf_get_encoding(self)
        end

        def get_array_len
          CTF.bt_ctf_get_array_len(self)
        end
      end
    end
    attach_function :bt_ctf_field_type, [Internal::Declaration], TypeID
    attach_function :bt_ctf_get_int_signedness, [Internal::Declaration], :int
    attach_function :bt_ctf_get_int_base, [Internal::Declaration], :int
    attach_function :bt_ctf_get_int_byte_order, [Internal::Declaration], :int
    attach_function :bt_ctf_get_int_len, [Internal::Declaration], :ssize_t
    attach_function :bt_ctf_get_encoding, [Internal::Declaration], StringEncoding
    attach_function :bt_ctf_get_array_len, [Internal::Declaration], :int

    module Internal
      class FieldDecl < FFI::Struct
        layout :dummy, :pointer

        def get_decl
          decl = CTF.bt_ctf_get_decl_from_field_decl(self)
          CTF::Declaration::create(decl)
        end
        alias decl get_decl

        def get_name
          CTF.bt_ctf_get_decl_field_name(self)
        end
        alias name get_name
      end
    end

    attach_function :bt_ctf_get_decl_from_field_decl, [Internal::FieldDecl], Internal::Declaration.by_ref
    attach_function :bt_ctf_get_decl_field_name, [Internal::FieldDecl], :string

    module Internal
      class Definition # < FFI::Struct
        layout :dummy, :pointer

        def field_name
          CTF.bt_ctf_field_name(self)
        end
        alias name field_name

        def get_decl
          decl = CTF.bt_ctf_get_decl_from_def(self)
          CTF::Declaration.create(decl)
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
          d = CTF.bt_ctf_get_enum_int(self)
          CTF::Definition.create(d)
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
          d = CTF.bt_ctf_get_variant(self)
          CTF::Definition.create(d)
        end

        def get_struct_field_index(i)
          d = CTF.bt_ctf_get_struct_field_index(self, i)
          CTF::Definition.create(d)
        end
      end
    end

    attach_function :bt_ctf_field_name, [Internal::Definition], :string
    attach_function :bt_ctf_get_decl_from_def, [Internal::Definition], Internal::Declaration.by_ref
    attach_function :bt_ctf_get_struct_field_count, [Internal::Definition], :uint64
    attach_function :bt_ctf_get_uint64, [Internal::Definition], :uint64
    attach_function :bt_ctf_get_int64, [Internal::Definition], :int64
    attach_function :bt_ctf_get_enum_int, [Internal::Definition], Internal::Definition.by_ref
    attach_function :bt_ctf_get_enum_str, [Internal::Definition], :string
    attach_function :bt_ctf_get_char_array, [Internal::Definition], :pointer
    attach_function :bt_ctf_get_string, [Internal::Definition], :string
    attach_function :bt_ctf_get_float, [Internal::Definition], :double
    attach_function :bt_ctf_get_variant, [Internal::Definition], Internal::Definition.by_ref
    attach_function :bt_ctf_get_struct_field_index, [Internal::Definition, :uint64], Internal::Definition.by_ref

    module Internal
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
    end

    attach_function :bt_ctf_get_decl_event_name, [Internal::EventDecl], :string
    attach_function :bt_ctf_get_decl_fields, [Internal::EventDecl, Scope,  :pointer, :pointer], :int

    class Trace < Babeltrace::Trace
      def get_event_decl_list
        count = FFI::MemoryPointer::new(:uint)
        list = FFI::MemoryPointer::new(:pointer)
        res = CTF.bt_ctf_get_event_decl_list(@handle_id, @context, list, count)
        count = count.read(:uint)
        list = list.read_pointer.read_array_of_pointer(count)
        list.collect { |p| Internal::EventDecl::new(p) }
      end
    end

    attach_function :bt_ctf_get_event_decl_list, [:int, Context, :pointer, :pointer], :int

    class Event
      def get_context
        c = CTF.bt_ctf_event_get_context(self)
        Babeltrace.bt_context_get(c)
        c
      end
      alias context get_context

      def get_handle_id
        CTF.bt_ctf_event_get_handle_id(self)
      end
      alias handle_id get_handle_id

      def get_top_level_scope(scope)
        d = CTF.bt_ctf_get_top_level_scope(self, scope)
        Definition.create(d)
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
        Time.at(0, CTF.bt_ctf_get_timestamp(self), :nsec)
      end
      alias timestamp get_timestamp

      def get_field_list(scope)
        count = FFI::MemoryPointer::new(:uint)
        list = FFI::MemoryPointer::new(:pointer)
        res = CTF.bt_ctf_get_field_list(self, scope.definition, list, count)
        count = count.read(:uint)
        return [] if count == 0
        list = list.read_pointer.read_array_of_pointer(count)
        list.collect { |p| Internal::Definition::new(p) }.collect { |d| Definition.create(d) }
      end
      alias field_list get_field_list

      def get_field(scope, field)
        d = CTF.bt_ctf_get_field(self, scope.definition, field)
        Definition.create(d)
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
        d = get_field(sc, field)
        Definition.create(d)
      end

      def get_index(field, index)
        d = CTF.bt_ctf_get_index(self, field.definition, index)
        Definition.create(d)
      end
      
    end

    attach_function :bt_ctf_event_get_context, [Event], Context.by_ref
    attach_function :bt_ctf_event_get_handle_id, [Event], :int
    attach_function :bt_ctf_get_top_level_scope, [Event, Scope], Internal::Definition.by_ref
    attach_function :bt_ctf_event_name, [Event], :string
    attach_function :bt_ctf_get_cycles, [Event], :uint64
    attach_function :bt_ctf_get_timestamp, [Event], :uint64
    attach_function :bt_ctf_get_field_list, [Event, Internal::Definition, :pointer, :pointer], :int
    attach_function :bt_ctf_get_field, [Event, Internal::Definition, :string], Internal::Definition.by_ref
    attach_function :bt_ctf_get_index, [Event, Internal::Definition, :uint], Internal::Definition.by_ref
    # Hack
    attach_function :bt_array_index, [Internal::Definition, :uint64], Internal::Definition.by_ref
    attach_function :bt_sequence_len, [Internal::Definition], :uint64
    attach_function :bt_sequence_index, [Internal::Definition, :uint64], Internal::Definition.by_ref

    class Definition
      attr_reader :definition

      def self.create(d)
        return nil if d.pointer.null?
        d.decl.def_class.new(d)
      end

      def initialize(definition)
        @definition = definition
      end

      def name
        @definition.name
      end

      def decl
        @definition.decl
      end
    end

    class StructDef < Definition
      def field_count
        @definition.get_struct_field_count
      end

      def field(i)
        @definition.get_struct_field_index(i)
      end

      def value
        field_count.times.collect { |i|
          f = field(i)
          [f.name, f.value]
        }.to_h
      end
    end

    class IntegerDef < Definition
      def int
        @definition.decl.signed? ? @definition.get_int64 : @definition.get_uint64
      end
      alias value int
    end

    class FloatDef < Definition
      def float
        @definition.get_float
      end
      alias value float
    end

    class EnumDef < Definition
      def int
        IntegerDef::new(@definition.get_enum_int)
      end

      def string
        @definition.get_enum_str
      end
      alias value string
    end

    class StringDef < Definition
      def string
        @definition.get_string
      end
      alias value string
    end

    class UntaggedVariantDef < Definition
      def variant
        @definition.get_variant
      end

      def value
        variant.value
      end
    end

    class VariantDef < Definition
      def variant
        @definition.get_variant
      end

      def value
        variant.value
      end
    end

    class ArrayDef < Definition
      def len
        @definition.decl.len
      end

      def index(i)
        d = CTF.bt_array_index(@definition, i)
        return Definition.create(d)
      end

      def value
        len.times.collect { |i| index(i).value }
      end
    end

    class ArrayTextDef < Definition
      def len
        @definition.decl.array_len
      end

      def value
        @definition.get_char_array.read_bytes(len)
      end
    end

    class SequenceDef < Definition
      def len
        CTF.bt_sequence_len(@definition)
      end

      def index(i)
        d = CTF.bt_sequence_index(@definition, i)
        return Definition.create(d)
      end

      def value
        len.times.collect { |i| index(i).value }
      end
    end

    class SequenceTextDef < Definition
      def len
        CTF.bt_sequence_len(@definition)
      end

      def value
        return [] if len == 0
        @definition.get_char_sequence.read_bytes(len)
      end
    end

    class Declaration
      attr_reader :declaration

      def self.create(decl)
        return nil if decl.pointer.null?
        case decl.field_type
        when :INTEGER
          IntegerDecl::new(decl)
        when :FLOAT
          FloatDecl::new(decl)
        when :ENUM
          EnumDecl::new(decl)
        when :STRING
          StringDecl::new(decl)
        when :STRUCT
          StructDecl::new(decl)
        when :UNTAGGED_VARIANT
          UntaggedVariantDecl::new(decl)
        when :VARIANT
          VariantDecl::new(decl)
        when :ARRAY
          ArrayDecl::new(decl)
        when :SEQUENCE
          SequenceDecl::new(decl)
        else
          raise "Unknow declaration type #{d.decl.field_type}!"
        end
      end

      def initialize(declaration)
        @declaration = declaration
      end

      def field_type
        @declaration.field_type
      end
    end

    class StructDecl < Declaration
      def def_class
        StructDef
      end
    end

    class IntegerDecl < Declaration
      def def_class
        IntegerDef
      end

      def signed?
        @declaration.int_signed?
      end

      def base
        @declaration.get_int_base
      end

      def byte_order
        @declaration.get_int_byte_order
      end

      def len
        @declaration.get_int_len
      end

      def encoding
        @declaration.get_encoding
      end

    end

    class FloatDecl < Declaration
      def def_class
        FloatDef
      end
    end

    class EnumDecl < Declaration
      def def_class
        EnumDef
      end
    end

    class StringDecl < Declaration
      def def_class
        StringDef
      end
    end

    class UntaggedVariantDecl < Declaration
      def def_class
        UntaggedVariantDef
      end
    end

    class VariantDecl < Declaration
      def def_class
        VariantDef
      end
    end

    class ArrayDecl # < Declaration
      def def_class
        e = elem
        if e.kind_of?(IntegerDecl) && e.len == 8 && 
             ( e.encoding == :ASCII || e.encoding == :UTF8 )
          ArrayTextDef
        else
          ArrayDef
        end
      end

      def len
        @declaration.get_array_len
      end
    end

    class SequenceDecl # < Declaration
      def def_class
        e = elem
        if e.kind_of?(IntegerDecl) && e.len == 8 &&
            ( e.encoding == :ASCII || e.encoding == :UTF8 )
          SequenceTextDef
        else
          SequenceDef
        end
      end
    end 

  end
end
