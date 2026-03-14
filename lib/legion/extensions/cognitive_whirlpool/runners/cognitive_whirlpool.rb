# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveWhirlpool
      module Runners
        module CognitiveWhirlpool
          extend self

          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def create_vortex(vortex_type:, angular_velocity: 0.5, depth: 0.0, capture_radius: 0.5,
                            engine: nil, **)
            eng = engine || default_engine
            vortex = eng.create_vortex(
              vortex_type:      vortex_type,
              angular_velocity: angular_velocity,
              depth:            depth,
              capture_radius:   capture_radius
            )
            Legion::Logging.info "[cognitive_whirlpool] created vortex id=#{vortex.vortex_id} type=#{vortex_type}"
            { success: true, vortex: vortex.to_h }
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_whirlpool] create_vortex failed: #{e.message}"
            { success: false, error: e.message }
          end

          def inject_thought(vortex_id:, content:, domain: :general, distance_from_core: 1.0,
                             engine: nil, **)
            eng = engine || default_engine
            result = eng.inject_thought(
              vortex_id:          vortex_id,
              content:            content,
              domain:             domain,
              distance_from_core: distance_from_core
            )
            Legion::Logging.info "[cognitive_whirlpool] injected thought=#{result[:thought_id]} into vortex=#{vortex_id}"
            result.merge(success: true)
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_whirlpool] inject_thought failed: #{e.message}"
            { success: false, error: e.message }
          end

          def tick_all(spiral_rate: nil, engine: nil, **)
            eng = engine || default_engine
            result = eng.tick_all!(spiral_rate: spiral_rate)
            Legion::Logging.debug "[cognitive_whirlpool] tick: vortices=#{result[:ticked]}"
            result.merge(success: true)
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_whirlpool] tick_all failed: #{e.message}"
            { success: false, error: e.message }
          end

          def dissipate_all(rate: Helpers::Constants::VELOCITY_DECAY, engine: nil, **)
            eng = engine || default_engine
            result = eng.dissipate_all!(rate: rate)
            Legion::Logging.debug "[cognitive_whirlpool] dissipate: removed=#{result[:dissipated]} remaining=#{result[:remaining]}"
            result.merge(success: true)
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_whirlpool] dissipate_all failed: #{e.message}"
            { success: false, error: e.message }
          end

          def vortex_report(engine: nil, **)
            eng = engine || default_engine
            report = eng.vortex_report
            Legion::Logging.debug "[cognitive_whirlpool] report: vortices=#{report[:total_vortices]}"
            report.merge(success: true)
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_whirlpool] vortex_report failed: #{e.message}"
            { success: false, error: e.message }
          end

          def deepest_vortices(limit: 3, engine: nil, **)
            eng = engine || default_engine
            vortices = eng.deepest_vortices(limit: limit)
            Legion::Logging.debug "[cognitive_whirlpool] deepest: count=#{vortices.size}"
            { success: true, vortices: vortices }
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_whirlpool] deepest_vortices failed: #{e.message}"
            { success: false, error: e.message }
          end

          def remove_vortex(vortex_id:, engine: nil, **)
            eng = engine || default_engine
            result = eng.remove_vortex(vortex_id)
            Legion::Logging.debug "[cognitive_whirlpool] removed vortex=#{vortex_id}"
            result.merge(success: true)
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_whirlpool] remove_vortex failed: #{e.message}"
            { success: false, error: e.message }
          end

          def clear_engine(engine: nil, **)
            eng = engine || default_engine
            result = eng.clear
            Legion::Logging.info '[cognitive_whirlpool] engine cleared'
            result.merge(success: true)
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_whirlpool] clear_engine failed: #{e.message}"
            { success: false, error: e.message }
          end

          private

          def default_engine
            @default_engine ||= Helpers::WhirlpoolEngine.new
          end
        end
      end
    end
  end
end
