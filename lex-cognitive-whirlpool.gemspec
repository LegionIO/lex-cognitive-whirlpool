# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_whirlpool/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-whirlpool'
  spec.version       = Legion::Extensions::CognitiveWhirlpool::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Cognitive Whirlpool'
  spec.description   = 'Models cognitive vortices that pull thoughts into focused spirals. ' \
                       'Whirlpools have depth, angular velocity, and capture radius. ' \
                       'Thoughts spiral deeper toward insight cores.'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-whirlpool'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-cognitive-whirlpool'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-cognitive-whirlpool'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-cognitive-whirlpool'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-cognitive-whirlpool/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
end
