module RSqoot
  module Helper

    def self.included(base)
      [ 'deals',
        'deal',
        'categories',
        'providers',
        'merchant',
        'commissions',
        'clicks' ].each do |name|
        attr_reader ('rsqoot_' + name).to_sym
        attr_accessor (name + '_options').to_sym
        base.send :define_method, (name + '_not_latest?').to_sym do |opt|
          result = method(name + '_options').call == opt ? false : true
          method(name + '_options=').call opt if result
          result
        end
      end

      [ 'categories',
        'providers' ].each do |name|
        base.send :define_method, ('query_' + name).to_sym do |q|
          queries = q.downcase.scan(/[A-Za-z]+|\d+/)
          if queries.present?
            queries.map do |q|
              instance_variable_get('@rsqoot_'+name).dup.keep_if do |c|
                c.slug =~ Regexp.new(q)
              end
            end.flatten.compact.uniq
          end
        end
        base.class_eval { private ('query_' + name).to_sym }
      end
    end

    def updated_by(options = {})
      @expired_in = options[:expired_in] if options[:expired_in].present?
      time = Time.now.to_i / expired_in.to_i
      options.merge!({expired_in: time})
    end

  end
end