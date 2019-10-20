[ '../lib', 'lib' ].each { |d| $:.unshift(d) if File::directory?(d) }
require 'minitest/autorun'
require 'babeltrace'

class BabeltraceTest < Minitest::Test

  def test_context
    c = Babeltrace::Context::new(Babeltrace.bt_context_create)
  end

  def test_ctf
    c = Babeltrace::Context::new(Babeltrace.bt_context_create)
    require 'babeltrace/ctf'
    t = c.add_trace(path: "./trace-lud/ust/uid/1000/64-bit/")
    p t.get_path
    p t.get_timestamp_begin
    p t.get_timestamp_end
    puts t.get_event_decl_list.collect(&:name)
    it = t.iter_create
    while (n = it.read_event.name)
      p n
      it.next
    end
  end

end
