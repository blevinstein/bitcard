class String
  def to_human
    self.split.map(&:capitalize).join(' ')
  end
  def to_form
    self.downcase.split.join('_')
  end
end
