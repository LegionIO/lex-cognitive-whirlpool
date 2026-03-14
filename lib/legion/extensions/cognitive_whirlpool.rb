# frozen_string_literal: true

require 'securerandom'

require_relative 'cognitive_whirlpool/version'
require_relative 'cognitive_whirlpool/helpers/constants'
require_relative 'cognitive_whirlpool/helpers/captured_thought'
require_relative 'cognitive_whirlpool/helpers/vortex'
require_relative 'cognitive_whirlpool/helpers/whirlpool_engine'
require_relative 'cognitive_whirlpool/runners/cognitive_whirlpool'
require_relative 'cognitive_whirlpool/client'

module Legion
  module Extensions
    module CognitiveWhirlpool
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
