# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveWhirlpool
      module Helpers
        class Vortex
          attr_reader :vortex_id, :vortex_type, :angular_velocity, :depth, :capture_radius, :captured_thoughts,
                      :created_at

          def initialize(vortex_type:, angular_velocity: 0.5, depth: 0.0, capture_radius: 0.5)
            raise ArgumentError, "unknown vortex_type: #{vortex_type}" unless Constants::VORTEX_TYPES.include?(vortex_type)

            @vortex_id        = SecureRandom.uuid
            @vortex_type      = vortex_type
            @angular_velocity = angular_velocity.clamp(Constants::ANGULAR_VELOCITY_MIN, Constants::ANGULAR_VELOCITY_MAX)
            @depth            = depth.clamp(0.0, Constants::DEPTH_MAX)
            @capture_radius   = capture_radius.clamp(0.0, Constants::CAPTURE_RADIUS_MAX)
            @captured_thoughts = []
            @created_at = Time.now.utc
          end

          def capture!(thought)
            raise ArgumentError, 'thought must be a CapturedThought' unless thought.is_a?(CapturedThought)

            @captured_thoughts << thought
            thought
          end

          def tick!(spiral_rate: nil)
            rate = spiral_rate || (Constants::SPIRAL_RATE_DEFAULT * @angular_velocity)
            @captured_thoughts.each { |t| t.spiral!(rate: rate) }
            @depth = (@depth + (rate * 0.5)).clamp(0.0, Constants::DEPTH_MAX)
            self
          end

          def dissipate!(rate: Constants::VELOCITY_DECAY)
            @angular_velocity = (@angular_velocity - rate).clamp(0.0, Constants::ANGULAR_VELOCITY_MAX)
            @capture_radius   = (@capture_radius - (rate * 0.5)).clamp(0.0, Constants::CAPTURE_RADIUS_MAX)
            self
          end

          def powerful?
            @angular_velocity >= Constants::POWERFUL_VELOCITY
          end

          def calm?
            @angular_velocity <= Constants::CALM_VELOCITY
          end

          def dissipated?
            @angular_velocity <= Constants::DISSIPATION_THRESHOLD
          end

          def thoughts_at_core
            @captured_thoughts.select(&:at_core?)
          end

          def active_thoughts
            @captured_thoughts.reject(&:escaped?)
          end

          def depth_label
            Constants::DEPTH_LABELS.find { |entry| entry[:range].cover?(@depth) }&.fetch(:label, :surface) || :surface
          end

          def to_h
            {
              vortex_id:        @vortex_id,
              vortex_type:      @vortex_type,
              angular_velocity: @angular_velocity.round(10),
              depth:            @depth.round(10),
              capture_radius:   @capture_radius.round(10),
              depth_label:      depth_label,
              powerful:         powerful?,
              calm:             calm?,
              dissipated:       dissipated?,
              thought_count:    @captured_thoughts.size,
              core_count:       thoughts_at_core.size,
              created_at:       @created_at
            }
          end
        end
      end
    end
  end
end
