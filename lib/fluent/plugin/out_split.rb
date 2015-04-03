
module Fluent
  class SplitOutput < Output
    Fluent::Plugin.register_output('split', self)

    config_param :tag, :string
    config_param :format, :string, :default => '^(?<key>[^=]+?)=(?<value>.*)$'
    config_param :separator, :string, :default => '\s+'
    config_param :key_name, :string
    config_param :out_key, :string, :default => nil
    config_param :reserve_msg, :bool, :default => nil
    config_param :prefix, :string, :default => nil

    def configure(conf)
      super

      @format_regex = Regexp.new(@format)
      unless @format_regex.names.include?("key") and @format_regex.names.include?("value")
          raise ConfigError, "split: format must have named_captures of key and value"
      end

      @sep_regex = Regexp.new(@separator)
      if (!prefix.nil? && prefix.is_a?(String))
        @store_fun = method(:store_with_prefix)
      else
        @store_fun = method(:store)
      end
    end

    def emit(tag, es, chain)
      es.each do |time, record|
        msg = record[@key_name]
        record.delete(@key_name) unless @reserve_msg
        data = split_message(msg)
        if @out_key.nil?
          record.merge!(data)
        else
          record[@out_key] = data
        end
        Engine.emit(@tag, time, record)
      end

      chain.next
    end

    private

    def split_message(message)
      return {} unless message.is_a?(String)
      data = {}
      message.split(@sep_regex).each do |e|
        matched = @format_regex.match(e) or next
        @store_fun.call(data, matched['key'], matched['value'])
      end
      data
    end

    def store(data, key, value)
      data.store(key, value)
    end

    def store_with_prefix(data, key, value)
      data.store(@prefix+key, value)
    end

  end
end
