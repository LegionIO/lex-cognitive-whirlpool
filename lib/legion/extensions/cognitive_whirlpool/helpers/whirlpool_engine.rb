# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveWhirlpool
      module Helpers
        class WhirlpoolEngine
          attr_reader :vortices

          def initialize
            @vortices = []
          end

          def create_vortex(vortex_type:, angular_velocity: 0.5, depth: 0.0, capture_radius: 0.5)
            raise ArgumentError, "MAX_VORTICES (#{Constants::MAX_VORTICES}) reached" if @vortices.size >= Constants::MAX_VORTICES

            vortex = Vortex.new(
              vortex_type:      vortex_type,
              angular_velocity: angular_velocity,
              depth:            depth,
              capture_radius:   capture_radius
            )
            @vortices << vortex
            vortex
          end

          def inject_thought(vortex_id:, content:, domain: :general, distance_from_core: 1.0)
            vortex = find_vortex(vortex_id)
            raise ArgumentError, "vortex not found: #{vortex_id}" unless vortex

            thought = CapturedThought.new(
              content:            content,
              domain:             domain,
              distance_from_core: distance_from_core
            )
            vortex.capture!(thought)
            { vortex_id: vortex_id, thought_id: thought.thought_id, domain: domain }
          end

          def tick_all!(spiral_rate: nil)
            results = @vortices.map do |v|
              v.tick!(spiral_rate: spiral_rate)
              { vortex_id: v.vortex_id, depth: v.depth.round(10), active_thoughts: v.active_thoughts.size }
            end
            { ticked: @vortices.size, results: results }
          end

          def dissipate_all!(rate: Constants::VELOCITY_DECAY)
            before = @vortices.size
            @vortices.each { |v| v.dissipate!(rate: rate) }
            @vortices.reject!(&:dissipated?)
            { dissipated: before - @vortices.size, remaining: @vortices.size }
          end

          def deepest_vortices(limit: 3)
            @vortices.sort_by { |v| -v.depth }.first(limit).map(&:to_h)
          end

          def vortex_report
            {
              total_vortices:   @vortices.size,
              powerful_count:   @vortices.count(&:powerful?),
              calm_count:       @vortices.count(&:calm?),
              total_thoughts:   @vortices.sum { |v| v.captured_thoughts.size },
              core_thoughts:    @vortices.sum { |v| v.thoughts_at_core.size },
              deepest_vortices: deepest_vortices
            }
          end

          def find_vortex(vortex_id)
            @vortices.find { |v| v.vortex_id == vortex_id }
          end

          def remove_vortex(vortex_id)
            before = @vortices.size
            @vortices.reject! { |v| v.vortex_id == vortex_id }
            { removed: before - @vortices.size }
          end

          def clear
            @vortices = []
            { cleared: true }
          end
        end
      end
    end
  end
end
