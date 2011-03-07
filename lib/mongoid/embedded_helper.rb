require 'mongoid'

module Mongoid
  module EmbeddedHelper
		def self.included(model)
			model.class_eval do
			          
        alias_method :old_parentize, :parentize
        def parentize(object)
          old_parentize object
          send(:after_parentize) if respond_to?(:after_parentize)
          # run_callbacks(:after_parentize)    
        end  
        
      end
    end
       
    def in_collection stack = []
      stack.extend(ArrayExt) if stack.empty?
      if embedded? 
        stack.add_collection_name self
        if _parent.respond_to?(:in_collection)
          _parent.in_collection(stack)
        else
          iterate_collection_stack stack, _parent
        end
      else  
        return self.class if stack.empty?      
        iterate_collection_stack stack
      end
    end
    
    private 
         
    def iterate_collection_stack stack, subject = nil
      collection = subject || self
      stack = stack.reverse
      stack.each do |entry|
        sub_collection = collection.send entry[:collection_name]    
        index = sub_collection.to_a.index(entry[:object]) if entry != stack.last        
        collection = sub_collection[index] if index
        collection = sub_collection  if !index
      end
      collection
    end
    
    module ArrayExt
      def add_collection_name obj
        self << {:collection_name => obj.collection_name, :object => obj}
      end      
    end    
  end
end


