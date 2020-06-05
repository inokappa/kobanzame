class Array
  def average
    (self.inject(:+) / self.length).round(3)
  end
end
