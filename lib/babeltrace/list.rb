module Babeltrace

  class ListHead < FFI::Struct
    layout :next, ListHead.ptr,
           :prev, ListHead.ptr

    def init
      self[:next] = self[:prev] = self
      self
    end

    def add(head)
      head[:next][:prev] = self
      self[:next] = head[:next]
      self[:prev] = head
      head[:next] = self
      self
    end

    def add_tail(head)
      head[:prev][:next] = self
      self[:next] = head
      self[:prev] = head[:prev]
      head[:prev] = self
      self
    end

    def self.del(p, n)
      n[:prev] = p
      n[:next] = n
    end

    def del
      ListHead.del(self[:prev], self[:next])
      self
    end

    def move(list)
      ListHead.del(self[:prev], self[:next])
      self.add(list)
      self
    end

    def replace(n)
      n[:next] = self[:next]
      n[:prev] = self[:prev]
      n[:prev][:next] = n
      n[:next][:prev] = n
      self
    end

    def splice(head)
      if(!empty?)
        self[:next][:prev] = head
        self[:prev][:next] = head[:next]
        head[:next][:prev] = self[:prev]
        head[:next] = self[:next]
      end
    end

    def empty?
      self.to_ptr == self[:next].to_ptr
    end

    def replace_init(n)
      head = self[:next]
      self.del
      n.add_tail(head)
      self.init
    end
  end
end
