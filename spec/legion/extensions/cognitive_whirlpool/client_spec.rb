# frozen_string_literal: true

require 'legion/extensions/cognitive_whirlpool/client'

RSpec.describe Legion::Extensions::CognitiveWhirlpool::Client do
  subject(:client) { described_class.new }

  it 'exposes an engine' do
    expect(client.engine).to be_a(Legion::Extensions::CognitiveWhirlpool::Helpers::WhirlpoolEngine)
  end

  describe 'full spiral workflow' do
    it 'creates a vortex, injects thought, ticks, and reaches insight core' do
      create_result = client.create_vortex(vortex_type: :analytical, angular_velocity: 1.0)
      expect(create_result[:success]).to be true
      vid = create_result[:vortex][:vortex_id]

      inject_result = client.inject_thought(vortex_id: vid, content: 'a profound idea', domain: :analytical)
      expect(inject_result[:success]).to be true

      20.times { client.tick_all(spiral_rate: 0.3) }

      vortex = client.engine.find_vortex(vid)
      expect(vortex.thoughts_at_core).not_to be_empty
    end
  end

  describe 'dissipation workflow' do
    it 'removes fully dissipated vortices' do
      v = client.create_vortex(vortex_type: :emotional, angular_velocity: 0.1)
      vid = v[:vortex][:vortex_id]
      50.times { client.dissipate_all(rate: 0.3) }
      expect(client.engine.find_vortex(vid)).to be_nil
    end
  end

  describe 'report integration' do
    before do
      client.create_vortex(vortex_type: :analytical, angular_velocity: 0.9, depth: 0.8)
      client.create_vortex(vortex_type: :creative, angular_velocity: 0.1, depth: 0.2)
    end

    it 'counts powerful and calm vortices correctly' do
      report = client.vortex_report
      expect(report[:powerful_count]).to eq(1)
      expect(report[:calm_count]).to eq(1)
    end

    it 'deepest_vortices returns highest depth first' do
      result = client.deepest_vortices(limit: 2)
      depths = result[:vortices].map { |v| v[:depth] }
      expect(depths.first).to be >= depths.last
    end
  end

  describe 'clear_engine' do
    it 'leaves engine empty' do
      client.create_vortex(vortex_type: :associative)
      client.clear_engine
      expect(client.engine.vortices).to be_empty
    end
  end
end
