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
