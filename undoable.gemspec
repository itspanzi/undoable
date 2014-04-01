$:.push File.expand_path("../lib", __FILE__)

require "undoable/version"

Gem::Specification.new do |s|
  s.name        = "undoable"
  s.version     = Undoable::VERSION
  s.authors     = ["Pavan Sudarshan"]
  s.email       = ["itspanzi@gmail.com"]
  s.homepage    = "https://github.com/itspanzi/undoable.rb"
  s.summary     = "Lets you generate an undo context json for every controller action which you can later pass back to undo that action"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.0.1"
end
