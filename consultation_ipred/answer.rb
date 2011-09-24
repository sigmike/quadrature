class Answer < Struct.new(:name, :files, :annexes, :languages)
  def initialize(*args)
    super
    self.annexes ||= []
    self.files ||= []
    self.languages ||= []
  end
end

