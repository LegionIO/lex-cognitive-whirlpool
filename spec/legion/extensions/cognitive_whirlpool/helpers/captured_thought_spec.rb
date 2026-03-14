# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveWhirlpool::Helpers::CapturedThought do
  let(:thought) { described_class.new(content: 'test thought', domain: :analytical) }

  describe '#initialize' do
    it 'generates a UUID thought_id' do
      expect(thought.thought_id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores content and domain' do
      expect(thought.content).to eq('test thought')
      expect(thought.domain).to eq(:analytical)
    end

    it 'defaults spiral_depth to 0.0' do
      expect(thought.spiral_depth).to eq(0.0)
    end

    it 'defaults distance_from_core to 1.0' do
      expect(thought.distance_from_core).to eq(1.0)
    end

    it 'sets captured_at to a UTC time' do
      expect(thought.captured_at).to be_a(Time)
    end

    it 'clamps spiral_depth above maximum' do
      t = described_class.new(content: 'x', spiral_depth: 5.0)
      expect(t.spiral_depth).to eq(1.0)
    end

    it 'clamps spiral_depth below zero' do
      t = described_class.new(content: 'x', spiral_depth: -1.0)
      expect(t.spiral_depth).to eq(0.0)
    end

    it 'clamps distance_from_core above maximum' do
      t = described_class.new(content: 'x', distance_from_core: 3.0)
      expect(t.distance_from_core).to eq(1.0)
    end

    it 'clamps distance_from_core below zero' do
      t = described_class.new(content: 'x', distance_from_core: -1.0)
      expect(t.distance_from_core).to eq(0.0)
    end

    it 'defaults domain to :general' do
      t = described_class.new(content: 'x')
      expect(t.domain).to eq(:general)
    end
  end

  describe '#spiral!' do
    it 'increases spiral_depth' do
      before = thought.spiral_depth
      thought.spiral!
      expect(thought.spiral_depth).to be > before
    end

    it 'decreases distance_from_core' do
      before = thought.distance_from_core
      thought.spiral!
      expect(thought.distance_from_core).to be < before
    end

    it 'accepts custom rate' do
      thought.spiral!(rate: 0.2)
      expect(thought.spiral_depth).to be_within(0.001).of(0.2)
    end

    it 'does not exceed DEPTH_MAX' do
      20.times { thought.spiral!(rate: 0.3) }
      expect(thought.spiral_depth).to eq(1.0)
    end

    it 'does not go below 0.0 for distance_from_core' do
      20.times { thought.spiral!(rate: 0.3) }
      expect(thought.distance_from_core).to eq(0.0)
    end

    it 'does nothing if thought has escaped' do
      thought.escape!
      depth_before    = thought.spiral_depth
      distance_before = thought.distance_from_core
      thought.spiral!
      expect(thought.spiral_depth).to eq(depth_before)
      expect(thought.distance_from_core).to eq(distance_before)
    end
  end

  describe '#at_core?' do
    it 'returns false when distance_from_core is large' do
      expect(thought.at_core?).to be false
    end

    it 'returns true when distance_from_core is near zero' do
      t = described_class.new(content: 'x', distance_from_core: 0.02)
      expect(t.at_core?).to be true
    end

    it 'returns true after spiraling all the way in' do
      20.times { thought.spiral!(rate: 0.4) }
      expect(thought.at_core?).to be true
    end
  end

  describe '#escaped?' do
    it 'returns false initially' do
      expect(thought.escaped?).to be false
    end

    it 'returns true after escape!' do
      thought.escape!
      expect(thought.escaped?).to be true
    end
  end

  describe '#depth_label' do
    it 'returns :surface for depth 0.0' do
      t = described_class.new(content: 'x', spiral_depth: 0.0)
      expect(t.depth_label).to eq(:surface)
    end

    it 'returns :insight_core for depth near 1.0' do
      t = described_class.new(content: 'x', spiral_depth: 0.95)
      expect(t.depth_label).to eq(:insight_core)
    end

    it 'returns :deep for depth 0.7' do
      t = described_class.new(content: 'x', spiral_depth: 0.7)
      expect(t.depth_label).to eq(:deep)
    end

    it 'returns :mid for depth 0.5' do
      t = described_class.new(content: 'x', spiral_depth: 0.5)
      expect(t.depth_label).to eq(:mid)
    end

    it 'returns :shallow for depth 0.3' do
      t = described_class.new(content: 'x', spiral_depth: 0.3)
      expect(t.depth_label).to eq(:shallow)
    end
  end

  describe '#to_h' do
    it 'returns a hash with all fields' do
      h = thought.to_h
      expect(h).to have_key(:thought_id)
      expect(h).to have_key(:content)
      expect(h).to have_key(:domain)
      expect(h).to have_key(:spiral_depth)
      expect(h).to have_key(:distance_from_core)
      expect(h).to have_key(:depth_label)
      expect(h).to have_key(:at_core)
      expect(h).to have_key(:escaped)
      expect(h).to have_key(:captured_at)
    end

    it 'rounds spiral_depth to 10 decimal places' do
      thought.spiral!(rate: 0.1)
      h = thought.to_h
      expect(h[:spiral_depth]).to be_a(Float)
    end

    it 'reflects escaped state' do
      thought.escape!
      expect(thought.to_h[:escaped]).to be true
    end
  end
end
