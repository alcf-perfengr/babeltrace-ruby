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
    p t.get_event_decl_list.collect(&:name)
  end

end
