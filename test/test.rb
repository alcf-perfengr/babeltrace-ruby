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
    traces = c.add_traces(path: "./trace-lud/")
    p traces
    puts c.get_timestamp_begin.strftime("%Y-%m-%d %H:%M:%S.%9L %z")
    puts c.get_timestamp_end.strftime("%Y-%m-%d %H:%M:%S.%9L %z")
    event_names = {}
    traces.each { |t|
      event_names[t.handle_id] = t.get_event_decl_list.collect(&:name)
    }
    it = c.iter_create
    it.each { |ev|
      #puts "#{ev.name}: #{ev.timestamp.strftime("%H:%M:%S.%9L")}"
      puts "#{event_names[ev.handle_id][ev.id]}: #{ev.timestamp.strftime("%H:%M:%S.%9L")}"
#      Babeltrace::CTF::Scope.symbols.each { |sym|
      [:EVENT_FIELDS].each { |sym|
        defi = ev.top_level_scope(sym)
        next unless defi
        puts "\t#{sym}: #{defi.value}"
      }
    }
  end

end
