[ '../lib', 'lib', '../ext/babeltrace_c/', 'ext/babeltrace_c/' ].each { |d| $:.unshift(d) if File::directory?(d) }
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
#    t = c.add_trace(path: "/home/videau/lttng-traces/my-userspace-opencl-session-20191020-154348/ust/uid/1000/64-bit/")
    p t.get_path
    puts t.get_timestamp_begin.strftime("%Y-%m-%d %H:%M:%S.%9L %z")
    puts t.get_timestamp_end.strftime("%Y-%m-%d %H:%M:%S.%9L %z")
    puts t.get_event_decl_list.collect(&:name)
    it = t.iter_create
    it.each { |ev|
      puts "#{ev.name}: #{ev.timestamp.strftime("%H:%M:%S.%9L")}"
      Babeltrace::CTF::Scope.symbols.each { |sym|
        defi = ev.top_level_scope(sym)
        next unless defi
        puts "\t#{sym}: #{defi.value}"
      }
    }
  end

end
