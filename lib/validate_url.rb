module ValidatesUrl
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    IPv4_PART = /\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]/ # 0-255
    REGEXP = %r{
\A
https?:// # http:// or https://
([^\s:@]+:[^\s:@]*@)? # optional username:pw@
( (xn--)?[^\W_]+([-.][^\W_]+)*\.[a-z]{2,6}\.? | # domain (including Punycode/IDN)...
#{IPv4_PART}(\.#{IPv4_PART}){3} ) # or IPv4
(:\d{1,5})? # optional port
([/?]\S*)? # optional /whatever or ?whatever
\Z
}iux
  
    def validates_url(*attr_names)
      options = { :with => REGEXP,
                  :message => "is invalid",
                  :check_http => false,
                  :on => :save }
      options.merge!(attr_names.pop) if attr_names.last.kind_of?(Hash)
      
      validates_each(attr_names, options) do |record, attr_name, value|
        unless value.to_s =~ options[:with]
          record.errors.add(attr_name, options[:message], :value => value) and false
        end
        # if were checking to see if the page is actually there...
        if options[:check_http]
          begin # check header response
            logger.info(value)
            res = Net::HTTP.get_response(URI.parse(value))
            logger.info(value)
            logger.info(res)
            logger.info(res.code.to_s)
            case res.code.to_s
              when "200" then true
            else record.errors.add(attr_name, options[:message], :value => value) and false
            end
          rescue # Recover on DNS failures..
           record.errors.add(attr_name, options[:message] + " (DNS)", :value => value) and false
          end
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval { include ValidatesUrl }
