class MarshalSerializer

  def initialize
    @filename = 'tmp/marshal.dump'
  end

  def write
    buf = []
    yield buf
    File.open(@filename, 'wb+') do |io|
      io << Marshal.dump(buf)
    end
  end

  def read(&block)
    Marshal.load(File.read(@filename)).each(&block)
  end

end
