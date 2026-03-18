# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveWhirlpool::Helpers::Vortex do
  let(:vortex) { described_class.new(vortex_type: :analytical, angular_velocity: 0.5, depth: 0.0, capture_radius: 0.5) }

  let(:thought) do
    Legion::Extensions::CognitiveWhirlpool::Helpers::CapturedThought.new(
      content: 'test thought', domain: :analytical
    )
  end

  describe '#initialize' do
    it 'generates a vortex_id' do
      expect(vortex.vortex_id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores vortex_type' do
      expect(vortex.vortex_type).to eq(:analytical)
    end

    it 'clamps angular_velocity within bounds' do
      v = described_class.new(vortex_type: :creative, angular_velocity: 5.0)
      expect(v.angular_velocity).to eq(1.0)
    end

    it 'clamps depth within bounds' do
      v = described_class.new(vortex_type: :creative, depth: -1.0)
      expect(v.depth).to eq(0.0)
    end

    it 'raises ArgumentError for unknown vortex_type' do
      expect { described_class.new(vortex_type: :unknown) }.to raise_error(ArgumentError)
    end

    it 'starts with empty captured_thoughts' do
      expect(vortex.captured_thoughts).to be_empty
    end

    it 'sets created_at' do
      expect(vortex.created_at).to be_a(Time)
    end
  end

  describe '#capture!' do
    it 'adds thought to captured_thoughts' do
      vortex.capture!(thought)
      expect(vortex.captured_thoughts.size).to eq(1)
    end

    it 'returns the thought' do
      result = vortex.capture!(thought)
      expect(result).to eq(thought)
    end

    it 'raises ArgumentError for non-CapturedThought' do
      expect { vortex.capture!('not a thought') }.to raise_error(ArgumentError)
    end
  end

  describe '#tick!' do
    before { vortex.capture!(thought) }

    it 'spirals all captured thoughts deeper' do
      depth_before = thought.spiral_depth
      vortex.tick!
      expect(thought.spiral_depth).to be > depth_before
    end

    it 'increases the vortex depth' do
      depth_before = vortex.depth
      vortex.tick!
      expect(vortex.depth).to be > depth_before
    end

    it 'returns self' do
      expect(vortex.tick!).to eq(vortex)
    end

    it 'accepts custom spiral_rate' do
      vortex.tick!(spiral_rate: 0.3)
      expect(thought.spiral_depth).to be_within(0.001).of(0.3)
    end
  end

  describe '#dissipate!' do
    it 'reduces angular_velocity' do
      before = vortex.angular_velocity
      vortex.dissipate!
      expect(vortex.angular_velocity).to be < before
    end

    it 'reduces capture_radius' do
      before = vortex.capture_radius
      vortex.dissipate!
      expect(vortex.capture_radius).to be < before
    end

    it 'returns self' do
      expect(vortex.dissipate!).to eq(vortex)
    end

    it 'accepts custom rate' do
      vortex.dissipate!(rate: 0.4)
      expect(vortex.angular_velocity).to be < 0.5
    end

    it 'decays captured thoughts distance from core' do
      vortex.capture!(thought)
      thought.spiral!(rate: 0.5)
      before = thought.distance_from_core
      vortex.dissipate!
      expect(thought.distance_from_core).to be > before
    end

    it 'auto-escapes thoughts that drift to ESCAPE_DISTANCE' do
      near_edge = Legion::Extensions::CognitiveWhirlpool::Helpers::CapturedThought.new(
        content: 'drifting', distance_from_core: 0.99
      )
      vortex.capture!(near_edge)
      vortex.dissipate!
      expect(near_edge.escaped?).to be true
    end
  end

  describe '#powerful?' do
    it 'returns true when angular_velocity is above POWERFUL_VELOCITY' do
      v = described_class.new(vortex_type: :creative, angular_velocity: 0.9)
      expect(v.powerful?).to be true
    end

    it 'returns false when angular_velocity is below POWERFUL_VELOCITY' do
      v = described_class.new(vortex_type: :creative, angular_velocity: 0.4)
      expect(v.powerful?).to be false
    end
  end

  describe '#calm?' do
    it 'returns true when angular_velocity is at or below CALM_VELOCITY' do
      v = described_class.new(vortex_type: :creative, angular_velocity: 0.1)
      expect(v.calm?).to be true
    end

    it 'returns false when angular_velocity is above CALM_VELOCITY' do
      expect(vortex.calm?).to be false
    end
  end

  describe '#dissipated?' do
    it 'returns false for a fresh vortex' do
      expect(vortex.dissipated?).to be false
    end

    it 'returns true after many dissipation cycles' do
      50.times { vortex.dissipate!(rate: 0.2) }
      expect(vortex.dissipated?).to be true
    end
  end

  describe '#thoughts_at_core' do
    it 'returns only thoughts at core distance' do
      core_thought = Legion::Extensions::CognitiveWhirlpool::Helpers::CapturedThought.new(
        content: 'core', distance_from_core: 0.02
      )
      vortex.capture!(thought)
      vortex.capture!(core_thought)
      expect(vortex.thoughts_at_core.size).to eq(1)
      expect(vortex.thoughts_at_core.first).to eq(core_thought)
    end
  end

  describe '#active_thoughts' do
    it 'excludes escaped thoughts' do
      vortex.capture!(thought)
      escaped = Legion::Extensions::CognitiveWhirlpool::Helpers::CapturedThought.new(content: 'escaped')
      escaped.escape!
      vortex.capture!(escaped)
      expect(vortex.active_thoughts.size).to eq(1)
    end
  end

  describe '#depth_label' do
    it 'returns :surface for a new vortex' do
      expect(vortex.depth_label).to eq(:surface)
    end

    it 'returns :insight_core after deep tick cycles' do
      50.times { vortex.tick!(spiral_rate: 0.1) }
      expect(vortex.depth_label).to eq(:insight_core)
    end
  end

  describe '#to_h' do
    it 'returns a hash with all expected keys' do
      h = vortex.to_h
      %i[vortex_id vortex_type angular_velocity depth capture_radius
         depth_label powerful calm dissipated thought_count core_count created_at].each do |key|
        expect(h).to have_key(key)
      end
    end

    it 'reflects current powerful state' do
      v = described_class.new(vortex_type: :analytical, angular_velocity: 0.9)
      expect(v.to_h[:powerful]).to be true
    end
  end
end
