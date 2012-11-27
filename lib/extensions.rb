class Object
  # Do nothing, just return object back. This is used in
  # ::Wizcorp::Nagios::Checks#rag, to send 'none' function.
  def none
    self
  end
end

class Array
  # Calculate sum of array
  # @return [Numeric]
  def sum digits=1
    self.reduce(0,:+).round(digits)
  end

  # Average reduce function.
  # @return [Numeric]
  def avg  digits=1
    (self.sum.to_f / self.length).round(digits)
  end

end

class String

  # Small extension for String class to be able create classes from
  # strings configured in the environment.yml file.
  #
  # Take '::' separated string and make class of it.
  def to_class
    self.split('::').inject(Kernel) {
      |scope, const_name| scope.const_get(const_name)
    }
  end
end
