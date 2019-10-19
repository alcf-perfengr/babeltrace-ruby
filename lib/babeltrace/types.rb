module Babeltrace

  TYPES = [[:int, :intern_str]]
  TYPES.each { |orig, add|
    typedef orig, add
  }

end
