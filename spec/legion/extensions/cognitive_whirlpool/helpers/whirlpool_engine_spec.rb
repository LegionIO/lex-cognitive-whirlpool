# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveWhirlpool::Helpers::WhirlpoolEngine do
  let(:engine) { described_class.new }

  describe '#create_vortex' do
    it 'creates a vortex and adds it to the engine' do
      vortex = engine.create_vortex(vortex_type: :analytical)
      expect(engine.vortices.size).to eq(1)
      expect(vortex).to be_a(Legion::Extensions::CognitiveWhirlpool::Helpers::Vortex)
    end

    it 'respects vortex_type' do
      vortex = engine.create_vortex(vortex_type: :creative)
      expect(vortex.vortex_type).to eq(:creative)
    end

    it 'passes angular_velocity' do
      vortex = engine.create_vortex(vortex_type: :analytical, angular_velocity: 0.8)
      expect(vortex.angular_velocity).to eq(0.8)
    end

    it 'passes depth' do
      vortex = engine.create_vortex(vortex_type: :analytical, depth: 0.3)
      expect(vortex.depth).to eq(0.3)
    end

    it 'passes capture_radius' do
      vortex = engine.create_vortex(vortex_type: :analytical, capture_radius: 0.7)
      expect(vortex.capture_radius).to eq(0.7)
    end

    it 'raises ArgumentError at MAX_VORTICES' do
      max = Legion::Extensions::CognitiveWhirlpool::Helpers::Constants::MAX_VORTICES
      max.times { engine.create_vortex(vortex_type: :analytical) }
      expect { engine.create_vortex(vortex_type: :creative) }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError for unknown vortex_type' do
      expect { engine.create_vortex(vortex_type: :unknown) }.to raise_error(ArgumentError)
    end
  end

  describe '#inject_thought' do
    let(:vortex) { engine.create_vortex(vortex_type: :emotional) }

    it 'adds a thought to the specified vortex' do
      engine.inject_thought(vortex_id: vortex.vortex_id, content: 'hello')
      expect(vortex.captured_thoughts.size).to eq(1)
    end

    it 'returns vortex_id and thought_id' do
      result = engine.inject_thought(vortex_id: vortex.vortex_id, content: 'hello')
      expect(result[:vortex_id]).to eq(vortex.vortex_id)
      expect(result[:thought_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'accepts domain and distance_from_core' do
      engine.inject_thought(vortex_id: vortex.vortex_id, content: 'thought', domain: :emotional, distance_from_core: 0.5)
      thought = vortex.captured_thoughts.first
      expect(thought.domain).to eq(:emotional)
      expect(thought.distance_from_core).to eq(0.5)
    end

    it 'raises ArgumentError for unknown vortex_id' do
      expect { engine.inject_thought(vortex_id: 'nonexistent', content: 'x') }.to raise_error(ArgumentError)
    end
  end

  describe '#tick_all!' do
    before do
      v = engine.create_vortex(vortex_type: :analytical)
      engine.inject_thought(vortex_id: v.vortex_id, content: 'thought 1')
    end

    it 'returns ticked count' do
      result = engine.tick_all!
      expect(result[:ticked]).to eq(1)
    end

    it 'includes results per vortex' do
      result = engine.tick_all!
      expect(result[:results]).to be_an(Array)
      expect(result[:results].first).to have_key(:vortex_id)
    end

    it 'spirals thoughts deeper' do
      vortex = engine.vortices.first
      depth_before = vortex.captured_thoughts.first.spiral_depth
      engine.tick_all!
      expect(vortex.captured_thoughts.first.spiral_depth).to be > depth_before
    end

    it 'accepts custom spiral_rate' do
      vortex = engine.vortices.first
      engine.tick_all!(spiral_rate: 0.3)
      expect(vortex.captured_thoughts.first.spiral_depth).to be_within(0.001).of(0.3)
    end
  end

  describe '#dissipate_all!' do
    before do
      engine.create_vortex(vortex_type: :analytical)
      engine.create_vortex(vortex_type: :creative)
    end

    it 'reduces angular_velocity of all vortices' do
      before_velocities = engine.vortices.map(&:angular_velocity)
      engine.dissipate_all!
      after_velocities = engine.vortices.map(&:angular_velocity)
      expect(after_velocities.zip(before_velocities).all? { |a, b| a <= b }).to be true
    end

    it 'removes fully dissipated vortices' do
      v = engine.create_vortex(vortex_type: :emotional, angular_velocity: 0.1)
      50.times { engine.dissipate_all!(rate: 0.3) }
      expect(engine.find_vortex(v.vortex_id)).to be_nil
    end

    it 'returns dissipated and remaining counts' do
      result = engine.dissipate_all!
      expect(result).to have_key(:dissipated)
      expect(result).to have_key(:remaining)
    end
  end

  describe '#deepest_vortices' do
    before do
      engine.create_vortex(vortex_type: :analytical, depth: 0.9)
      engine.create_vortex(vortex_type: :creative, depth: 0.5)
      engine.create_vortex(vortex_type: :emotional, depth: 0.2)
    end

    it 'returns vortices sorted by depth descending' do
      result = engine.deepest_vortices(limit: 3)
      depths = result.map { |v| v[:depth] }
      expect(depths).to eq(depths.sort.reverse)
    end

    it 'respects limit' do
      result = engine.deepest_vortices(limit: 2)
      expect(result.size).to eq(2)
    end

    it 'returns hashes' do
      result = engine.deepest_vortices
      expect(result).to all(be_a(Hash))
    end
  end

  describe '#vortex_report' do
    before do
      v1 = engine.create_vortex(vortex_type: :analytical, angular_velocity: 0.9)
      v2 = engine.create_vortex(vortex_type: :creative, angular_velocity: 0.1)
      engine.inject_thought(vortex_id: v1.vortex_id, content: 'thought A')
      engine.inject_thought(vortex_id: v2.vortex_id, content: 'thought B')
    end

    it 'returns total_vortices' do
      expect(engine.vortex_report[:total_vortices]).to eq(2)
    end

    it 'returns powerful_count' do
      expect(engine.vortex_report[:powerful_count]).to eq(1)
    end

    it 'returns calm_count' do
      expect(engine.vortex_report[:calm_count]).to eq(1)
    end

    it 'returns total_thoughts' do
      expect(engine.vortex_report[:total_thoughts]).to eq(2)
    end

    it 'returns core_thoughts count' do
      expect(engine.vortex_report[:core_thoughts]).to be_a(Integer)
    end

    it 'returns deepest_vortices array' do
      expect(engine.vortex_report[:deepest_vortices]).to be_an(Array)
    end
  end

  describe '#find_vortex' do
    it 'returns the matching vortex' do
      vortex = engine.create_vortex(vortex_type: :analytical)
      expect(engine.find_vortex(vortex.vortex_id)).to eq(vortex)
    end

    it 'returns nil for unknown id' do
      expect(engine.find_vortex('nonexistent')).to be_nil
    end
  end

  describe '#remove_vortex' do
    it 'removes vortex by id' do
      vortex = engine.create_vortex(vortex_type: :analytical)
      engine.remove_vortex(vortex.vortex_id)
      expect(engine.find_vortex(vortex.vortex_id)).to be_nil
    end

    it 'returns removed count' do
      vortex = engine.create_vortex(vortex_type: :analytical)
      result = engine.remove_vortex(vortex.vortex_id)
      expect(result[:removed]).to eq(1)
    end

    it 'returns 0 for unknown id' do
      result = engine.remove_vortex('nonexistent')
      expect(result[:removed]).to eq(0)
    end
  end

  describe '#clear' do
    it 'removes all vortices' do
      engine.create_vortex(vortex_type: :analytical)
      engine.create_vortex(vortex_type: :creative)
      engine.clear
      expect(engine.vortices).to be_empty
    end

    it 'returns cleared: true' do
      result = engine.clear
      expect(result[:cleared]).to be true
    end
  end
end
