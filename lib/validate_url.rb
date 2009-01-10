module ValidateUrl
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
  
    def validate_url(*attr_names)
      options = { :with => REGEXP,
                  :message => "is invalid",
                  :check_http => false,
                  :check_http_message => "does not resolve",
                  :on => :save }
      options.merge!(attr_names.pop) if attr_names.last.kind_of?(Hash)
      
      validates_each(attr_names, options) do |record, attr_name, value|
        unless value.to_s =~ options[:with]
          record.errors.add(attr_name, options[:message], :value => value) and false
        end
        # if were checking to see if the page is actually there...
        if options[:check_http]
          begin # check header response
            res = Net::HTTP.get_response(URI.parse("#{value}"))
            # 2xx
            if res.is_a?(Net::HTTPSuccess)
              true
            elsif res.is_a?(Net::HTTPInformation) # 1xx
              record.errors.add(attr_name, options[:check_http_message], :value => value) and false
            elsif res.is_a?(Net::HTTPRedirection) # 3xx
              record.errors.add(attr_name, options[:check_http_message], :value => value) and false
            elsif res.is_a?(Net::HTTPServerError) # 5xx
              record.errors.add(attr_name, options[:check_http_message], :value => value) and false
            else # 4xx
              record.errors.add(attr_name, options[:check_http_message], :value => value) and false
            end
          rescue # Recover on DNS failures..
           record.errors.add(attr_name, options[:check_http_message] + " (DNS failure)", :value => value) and false
          end
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval { include ValidateUrl }
