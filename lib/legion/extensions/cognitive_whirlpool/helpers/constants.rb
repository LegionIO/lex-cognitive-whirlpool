# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveWhirlpool
      module Helpers
        module Constants
          VORTEX_TYPES = %i[
            analytical
            creative
            emotional
            procedural
            associative
          ].freeze

          MAX_VORTICES = 12

          VELOCITY_DECAY = 0.05

          DEPTH_LABELS = [
            { range: (0.0...0.2),   label: :surface },
            { range: (0.2...0.4),   label: :shallow },
            { range: (0.4...0.6),   label: :mid },
            { range: (0.6...0.8),   label: :deep },
            { range: (0.8..1.0),    label: :insight_core }
          ].freeze

          CAPTURE_DECAY_RATE     = 0.03
          ANGULAR_VELOCITY_MIN   = 0.1
          ANGULAR_VELOCITY_MAX   = 1.0
          DEPTH_MAX              = 1.0
          CAPTURE_RADIUS_MAX     = 1.0
          SPIRAL_RATE_DEFAULT    = 0.08
          DISSIPATION_THRESHOLD  = 0.05
          POWERFUL_VELOCITY      = 0.7
          CALM_VELOCITY          = 0.2
        end
      end
    end
  end
end
