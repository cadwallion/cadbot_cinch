module Extensions
  def self.camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
    if first_letter_in_uppercase
      lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    else
      lower_case_and_underscored_word.to_s[0].chr.downcase + camelize(lower_case_and_underscored_word)[1..-1]
    end
  end

  def self.constantize(camel_cased_word)
    names = camel_cased_word.split('::')
    names.shift if names.empty? || names.first.empty?

    constant = Object
    names.each do |name|
      constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
    end
    constant
  end
end

class String
  def camelize(first_letter = :upper)
    Extensions.camelize(self, first_letter)
  end
  
  def constantize
    Extensions.constantize(self)
  end
end

module Cinch
  class Bot
    def database
      if @database.nil?
        raise "Cannot access database, configuration not loaded."
      else
        @database
      end
    end
  end
end

class Hash
  def symbolize_keys
     dup.symbolize_keys!
   end

   # Destructively convert all keys to symbols, as long as they respond
   # to +to_sym+.
   def symbolize_keys!
     keys.each do |key|
       self[(key.to_sym rescue key) || key] = delete(key)
     end
     self
   end
end