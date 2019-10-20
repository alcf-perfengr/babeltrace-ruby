module Babeltrace
  module CTF
    extend FFI::Library
    ffi_lib "babeltrace-ctf", "babeltrace-ctf-metadata"
  end
  require_relative 'ctf/callbacks'
  require_relative 'ctf/events'
  require_relative 'ctf/iterator'
end

