# frozen_string_literal: true

require 'legion/extensions/cognitive_whirlpool/client'

RSpec.describe Legion::Extensions::CognitiveWhirlpool::Runners::CognitiveWhirlpool do
  let(:engine) { Legion::Extensions::CognitiveWhirlpool::Helpers::WhirlpoolEngine.new }
  let(:client) { Legion::Extensions::CognitiveWhirlpool::Client.new }

  describe '#create_vortex' do
    it 'returns success: true with vortex hash' do
      result = client.create_vortex(vortex_type: :analytical)
      expect(result[:success]).to be true
      expect(result[:vortex]).to be_a(Hash)
      expect(result[:vortex][:vortex_type]).to eq(:analytical)
    end

    it 'returns success: false for invalid vortex_type' do
      result = client.create_vortex(vortex_type: :bogus)
      expect(result[:success]).to be false
      expect(result[:error]).to be_a(String)
    end

    it 'creates multiple vortices' do
      client.create_vortex(vortex_type: :analytical)
      client.create_vortex(vortex_type: :creative)
      report = client.vortex_report
      expect(report[:total_vortices]).to eq(2)
    end

    it 'passes angular_velocity to vortex' do
      result = client.create_vortex(vortex_type: :analytical, angular_velocity: 0.9)
      expect(result[:vortex][:angular_velocity]).to eq(0.9)
    end

    it 'passes depth to vortex' do
      result = client.create_vortex(vortex_type: :analytical, depth: 0.4)
      expect(result[:vortex][:depth]).to eq(0.4)
    end

    it 'passes capture_radius to vortex' do
      result = client.create_vortex(vortex_type: :analytical, capture_radius: 0.6)
      expect(result[:vortex][:capture_radius]).to eq(0.6)
    end
  end

  describe '#inject_thought' do
    let(:vortex_id) { client.create_vortex(vortex_type: :creative)[:vortex][:vortex_id] }

    it 'returns success: true with thought_id' do
      result = client.inject_thought(vortex_id: vortex_id, content: 'spark')
      expect(result[:success]).to be true
      expect(result[:thought_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'returns success: false for unknown vortex' do
      result = client.inject_thought(vortex_id: 'bad-id', content: 'spark')
      expect(result[:success]).to be false
    end

    it 'accepts domain' do
      result = client.inject_thought(vortex_id: vortex_id, content: 'x', domain: :creative)
      expect(result[:domain]).to eq(:creative)
    end
  end

  describe '#tick_all' do
    before { client.create_vortex(vortex_type: :emotional) }

    it 'returns success: true' do
      result = client.tick_all
      expect(result[:success]).to be true
    end

    it 'reports ticked vortex count' do
      result = client.tick_all
      expect(result[:ticked]).to eq(1)
    end

    it 'accepts spiral_rate' do
      result = client.tick_all(spiral_rate: 0.2)
      expect(result[:success]).to be true
    end
  end

  describe '#dissipate_all' do
    before { client.create_vortex(vortex_type: :associative) }

    it 'returns success: true' do
      result = client.dissipate_all
      expect(result[:success]).to be true
    end

    it 'returns remaining count' do
      result = client.dissipate_all
      expect(result).to have_key(:remaining)
    end

    it 'accepts custom rate' do
      result = client.dissipate_all(rate: 0.1)
      expect(result[:success]).to be true
    end
  end

  describe '#vortex_report' do
    it 'returns success: true' do
      result = client.vortex_report
      expect(result[:success]).to be true
    end

    it 'returns total_vortices' do
      client.create_vortex(vortex_type: :analytical)
      result = client.vortex_report
      expect(result[:total_vortices]).to eq(1)
    end

    it 'includes powerful_count and calm_count' do
      result = client.vortex_report
      expect(result).to have_key(:powerful_count)
      expect(result).to have_key(:calm_count)
    end
  end

  describe '#deepest_vortices' do
    before do
      client.create_vortex(vortex_type: :analytical, depth: 0.8)
      client.create_vortex(vortex_type: :creative, depth: 0.3)
    end

    it 'returns success: true with vortices array' do
      result = client.deepest_vortices
      expect(result[:success]).to be true
      expect(result[:vortices]).to be_an(Array)
    end

    it 'returns deepest first' do
      result = client.deepest_vortices(limit: 2)
      depths = result[:vortices].map { |v| v[:depth] }
      expect(depths.first).to be >= depths.last
    end

    it 'respects limit' do
      result = client.deepest_vortices(limit: 1)
      expect(result[:vortices].size).to eq(1)
    end
  end

  describe '#remove_vortex' do
    let(:vortex_id) { client.create_vortex(vortex_type: :procedural)[:vortex][:vortex_id] }

    it 'removes the vortex' do
      result = client.remove_vortex(vortex_id: vortex_id)
      expect(result[:success]).to be true
      expect(result[:removed]).to eq(1)
    end

    it 'returns 0 for unknown id' do
      result = client.remove_vortex(vortex_id: 'nonexistent')
      expect(result[:removed]).to eq(0)
    end
  end

  describe '#clear_engine' do
    before do
      client.create_vortex(vortex_type: :analytical)
      client.create_vortex(vortex_type: :creative)
    end

    it 'clears all vortices' do
      client.clear_engine
      expect(client.vortex_report[:total_vortices]).to eq(0)
    end

    it 'returns success: true' do
      result = client.clear_engine
      expect(result[:success]).to be true
    end

    it 'returns cleared: true' do
      result = client.clear_engine
      expect(result[:cleared]).to be true
    end
  end

  describe 'runner with injected engine' do
    let(:runner) do
      obj = Object.new
      obj.extend(described_class)
      obj
    end

    it 'creates a vortex via injected engine' do
      result = runner.create_vortex(vortex_type: :creative, engine: engine)
      expect(result[:success]).to be true
      expect(engine.vortices.size).to eq(1)
    end

    it 'injects thought via injected engine' do
      runner.create_vortex(vortex_type: :creative, engine: engine)
      vid = engine.vortices.first.vortex_id
      result = runner.inject_thought(vortex_id: vid, content: 'via engine', engine: engine)
      expect(result[:success]).to be true
    end

    it 'ticks via injected engine' do
      runner.create_vortex(vortex_type: :analytical, engine: engine)
      result = runner.tick_all(engine: engine)
      expect(result[:ticked]).to eq(1)
    end

    it 'dissipates via injected engine' do
      runner.create_vortex(vortex_type: :analytical, engine: engine)
      result = runner.dissipate_all(engine: engine)
      expect(result[:success]).to be true
    end

    it 'reports via injected engine' do
      result = runner.vortex_report(engine: engine)
      expect(result[:success]).to be true
    end

    it 'deepest_vortices via injected engine' do
      result = runner.deepest_vortices(engine: engine)
      expect(result[:success]).to be true
    end
  end
end
