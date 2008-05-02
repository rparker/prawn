# pdf_object.rb : Handles Ruby to PDF object serialization
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn 
                                             
  module_function
    
  # Serializes Ruby objects to their PDF equivalents.  Most primitive objects
  # will work as expected, but please note that Name objects are represented 
  # by Ruby Symbol objects and Dictionary objects are represented by Ruby hashes
  # (keyed by symbols)   
  #
  #  Examples:
  #
  #     PdfObject(true)      #=> "true"
  #     PdfObject(false)     #=> "false" 
  #     PdfObject(1.2124)    #=> "1.2124"
  #     PdfObject("foo bar") #=> "(foo bar)"  
  #     PdfObject(:Symbol)   #=> "/Symbol"
  #     PdfObject(["foo",:bar, [1,2]]) #=> "[foo /bar [1 2]]"
  # 
  def PdfObject(obj) #:nodoc:
    case(obj)        
    when NilClass   then "null" 
    when TrueClass  then "true"
    when FalseClass then "false"
    when Numeric    then String(obj)
    when Array      then "[" << obj.map { |e| PdfObject(e) }.join(' ') << "]"     
    when String     
      "<" << obj.unpack("H*").first << ">"
    when Symbol                                                         
       if (obj = obj.to_s) =~ /\s/
         raise Prawn::Errors::FailedObjectConversion, 
           "A PDF Name cannot contain whitespace"  
       else
         "/" << obj   
       end 
    when Hash           
      output = "<< "
      obj.each do |k,v|                                                        
        unless String === k || Symbol === k
          raise Prawn::Errors::FailedObjectConversion, 
            "A PDF Dictionary must be keyed by names"
        end                          
        output << PdfObject(k.to_sym) << " " << PdfObject(v) << "\n"
      end   
      output << ">>"  
    when Prawn::Reference
      obj.to_s      
    else
      raise Prawn::Errors::FailedObjectConversion, 
        "This object cannot be serialized to PDF"
    end     
  end   
end