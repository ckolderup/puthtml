class Hash
  # def symbolize_keys!
  #   each do |k,v| 
  #     sym = k.respond_to?(:to_sym) ? k.to_sym : k 
  #     self[sym] = Hash === v ? v.symbolize_keys! : v 
  #     delete(k) unless k == sym
  #   end
  #   self
  # end

  def all_blank?
    values.reject{ |v| v.blank? }.empty?
  end
  
  alias_method :blank?, :all_blank?
end
