class Array
  def average
    (self.inject(:+) / self.length).round(3)
  end
end

class String
  def camelize
    self.split('_').map(&:capitalize).join
  end
end
