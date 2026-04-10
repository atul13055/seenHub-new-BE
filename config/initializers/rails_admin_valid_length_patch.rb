# Fix RailsAdmin length help when length validator options use Proc/Range
RailsAdmin::Config::Fields::Base.register_instance_option :valid_length do
  raw = abstract_model.model.validators_on(name).detect { |v| v.kind == :length }.try(&:options) || {}

  coerce = lambda do |val|
    if val.is_a?(Range)
      { minimum: val.begin, maximum: val.end }
    else
      val
    end
  end

  out = raw.dup
  [:minimum, :maximum, :is].each do |key|
    val = out[key]
    if val.respond_to?(:call)
      begin
        obj = bindings && bindings[:object]
        val = val.arity == 1 ? val.call(obj) : val.call
      rescue StandardError
        val = nil
      end
    end
    val = coerce.call(val)
    if val.is_a?(Hash)
      out.delete(key)
      out[:minimum] ||= val[:minimum] if val.key?(:minimum)
      out[:maximum] ||= val[:maximum] if val.key?(:maximum)
    else
      out[key] = val
    end
  end

  out
end
