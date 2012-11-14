class Object
  # Do nothing, just return object back. This is used in
  # ::Wizcorp::Nagios::Checks#rag, to send 'none' function.
  def none
    self
  end
end

class Array
    
  # Calculate sum of array
  def sum
    self.reduce(0,:+)
  end
  
  def avg
    self.sum / self.length
  end

end

class String
  

  # Small sextension for String class to be able create classes from
  # strings configured in the environment.yml file.
  #
  # Take '::' separated string and make class of it.
  def to_class
    self.split('::').inject(Kernel) {
      |scope, const_name| scope.const_get(const_name)
    }
  end
end
