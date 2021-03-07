class Space
  attr_accessor :contents, :marker
  def initialize(contents = nil, marker = nil)
    @contents = contents
    @marker = marker
  end
end