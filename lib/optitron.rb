class Optitron
  autoload :Dsl,       'optitron/dsl'
  autoload :ClassDsl,  'optitron/class_dsl'
  autoload :Tokenizer, 'optitron/tokenizer'
  autoload :Parser,    'optitron/parser'
  autoload :Response,  'optitron/response'
  autoload :Option,    'optitron/option'
  autoload :Help,      'optitron/help'
  autoload :CLI,       'optitron/cli'

  InvalidParser = Class.new(RuntimeError)

  attr_reader :parser

  def initialize(&blk)
    @parser = Parser.new
    Dsl.new(@parser, &blk) if blk
  end

  def parse(args)
    @parser.parse(args)
  end

  def self.transform(args = ARGV, &blk)
    Optitron.new(&blk).parse(args)
  end

  def help
    @parser.help
  end
end