class Array
  
  # Do nothing, just return array back
  def none
    self
  end
  
  # Calculate sum of array
  def sum
    self.inject(0,:+)
  end
  
  def avg
    self.sum / self.length
  end

end
