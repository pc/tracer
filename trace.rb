class Tracer
  def self.trace_class(cls, *meths)
    cls.class_eval do
      class << self
        Tracer.trace(self)
      end
    end
  end

  def self.trace(cls, *meths)
    level = 0
    is_class = cls.class.is_a?(Class)
    base = is_class ? Object.methods : Object.instance_methods

    m = meths.empty? ? (cls.instance_methods - base) : meths

    m.each do |meth|
      key = String.respond_to?(:random) ? String.random : "#{rand}"
      orig_method = cls.instance_method(meth)
      cls.send(:define_method, meth) do |*args, &blk|
        pref = ' ' * (level * 2)
        puts "#{pref}#{self.is_a?(Class) ? "#{self}<Class>" : self.class.name}.#{meth}(#{args.map(&:inspect).join(', ')})"
        level += 1
        ret = orig_method.bind(self).call(*args, &blk)
        puts "#{pref}=> #{ret.inspect}"
        level -= 1
        ret
      end
    end
  end
end

if $0 == __FILE__
  class Example
    def self.example
      puts "(ran self.example)"
    end

    def example
      puts "(ran example)"
    end

    def nonexample
      puts "(ran nonexample)"
    end
  end
  Tracer.trace_class(Example)
  Tracer.trace(Example, :example)

  Example.example
  ex = Example.new
  ex.example
  ex.nonexample
end
