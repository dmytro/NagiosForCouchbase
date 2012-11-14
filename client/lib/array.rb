class Array
    
  # Calculate sum of array
  def sum
    self.reduce(0,:+)
  end
  
  def avg
    self.sum / self.length
  end

end
