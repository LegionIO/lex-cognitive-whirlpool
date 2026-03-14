# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveWhirlpool
      class Client
        include Runners::CognitiveWhirlpool

        attr_reader :engine

        def initialize
          @engine = Helpers::WhirlpoolEngine.new
        end

        def create_vortex(vortex_type:, angular_velocity: 0.5, depth: 0.0, capture_radius: 0.5, **)
          super(
            vortex_type:      vortex_type,
            angular_velocity: angular_velocity,
            depth:            depth,
            capture_radius:   capture_radius,
            engine:           @engine
          )
        end

        def inject_thought(vortex_id:, content:, domain: :general, distance_from_core: 1.0, **)
          super(
            vortex_id:          vortex_id,
            content:            content,
            domain:             domain,
            distance_from_core: distance_from_core,
            engine:             @engine
          )
        end

        def tick_all(spiral_rate: nil, **)
          super(spiral_rate: spiral_rate, engine: @engine)
        end

        def dissipate_all(rate: Helpers::Constants::VELOCITY_DECAY, **)
          super(rate: rate, engine: @engine)
        end

        def vortex_report(**)
          super(engine: @engine)
        end

        def deepest_vortices(limit: 3, **)
          super(limit: limit, engine: @engine)
        end

        def remove_vortex(vortex_id:, **)
          super(vortex_id: vortex_id, engine: @engine)
        end

        def clear_engine(**)
          super(engine: @engine)
        end
      end
    end
  end
end
