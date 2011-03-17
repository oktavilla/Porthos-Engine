# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "porthos"
  s.summary = "Insert Porthos summary."
  s.description = "Insert Porthos description."
  s.files = Dir["{app,public,lib,config}/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile", "README.rdoc"]
  s.version = "0.0.1"
end
