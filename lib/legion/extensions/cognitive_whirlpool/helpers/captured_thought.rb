# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveWhirlpool
      module Helpers
        class CapturedThought
          attr_reader :thought_id, :content, :domain, :spiral_depth, :distance_from_core, :captured_at

          ESCAPE_DISTANCE = 1.0
          CORE_DISTANCE   = 0.05

          def initialize(content:, domain: :general, spiral_depth: 0.0, distance_from_core: 1.0)
            @thought_id        = SecureRandom.uuid
            @content           = content
            @domain            = domain
            @spiral_depth      = spiral_depth.clamp(0.0, Constants::DEPTH_MAX)
            @distance_from_core = distance_from_core.clamp(0.0, Constants::CAPTURE_RADIUS_MAX)
            @captured_at       = Time.now.utc
            @escaped           = false
          end

          def spiral!(rate: Constants::SPIRAL_RATE_DEFAULT)
            return if @escaped

            @spiral_depth       = (@spiral_depth + rate).clamp(0.0, Constants::DEPTH_MAX)
            @distance_from_core = (@distance_from_core - rate).clamp(0.0, Constants::CAPTURE_RADIUS_MAX)
          end

          def at_core?
            @distance_from_core <= CORE_DISTANCE
          end

          def escaped?
            @escaped
          end

          def escape!
            @escaped = true
          end

          def depth_label
            Constants::DEPTH_LABELS.find { |entry| entry[:range].cover?(@spiral_depth) }&.fetch(:label, :surface) || :surface
          end

          def to_h
            {
              thought_id:         @thought_id,
              content:            @content,
              domain:             @domain,
              spiral_depth:       @spiral_depth.round(10),
              distance_from_core: @distance_from_core.round(10),
              depth_label:        depth_label,
              at_core:            at_core?,
              escaped:            @escaped,
              captured_at:        @captured_at
            }
          end
        end
      end
    end
  end
end
