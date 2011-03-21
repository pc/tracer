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
      impl = "#{meth}_#{key}".to_sym
      cls.send(:alias_method, impl, meth)
      cls.send(:define_method, meth) do |*args, &blk|
        pref = ' ' * (level * 2)
        puts "#{pref}#{is_class ? "#{self}<Class>" : self.class.name}.#{meth}(#{args.map(&:inspect).join(', ')})"
        level += 1
        ret = self.send(impl, *args, &blk)
        puts "#{pref}=> #{ret.inspect}"
        level -= 1
        ret
      end
    end
  end
end
