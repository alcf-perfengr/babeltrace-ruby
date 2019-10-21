[ '../lib', 'lib' ].each { |d| $:.unshift(d) if File::directory?(d) }
require 'minitest/autorun'
require 'babeltrace'

class BabeltraceTest < Minitest::Test

  def test_context
    c = Babeltrace::Context::new
  end

  def test_ctf
    c = Babeltrace::Context::new
    require 'babeltrace/ctf'
    t = c.add_trace(path: "./trace-lud/ust/uid/1000/64-bit/")
    p t.get_path
    p t.get_timestamp_begin
    p t.get_timestamp_end
    puts t.get_event_decl_list.collect(&:name)
    it = t.iter_create
    it.each { |ev|
      puts "#{ev.name}: #{ev.timestamp}"
      Babeltrace::CTF::Scope.symbols.each { |sym|
        puts "\t#{sym}"
        ev.each_field(sym) { |f|
          d = f.decl
          str = "\t\t#{f.name} #{d.field_type}"
          case d.field_type
          when :INTEGER
            if d.int_signed?
              str << " #{f.get_int64}"
            else
              str << " #{f.get_uint64}"
            end
          when :SEQUENCE
            sz = ev.find_field("_#{f.name}_length", sym).get_uint64
            str << "[#{sz}] {"
            str << sz.times.collect { |i|
              sf = ev.get_index(f, i)
              sf.get_uint64
            }.join(", ")
            str << "}"
          end
          puts str
        }
      }
    }
  end

end
