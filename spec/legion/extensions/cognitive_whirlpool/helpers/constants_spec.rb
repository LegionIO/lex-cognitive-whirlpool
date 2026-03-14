# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveWhirlpool::Helpers::Constants do
  describe 'VORTEX_TYPES' do
    it 'is a frozen array of symbols' do
      expect(described_class::VORTEX_TYPES).to be_a(Array)
      expect(described_class::VORTEX_TYPES).to be_frozen
      expect(described_class::VORTEX_TYPES).to all(be_a(Symbol))
    end

    it 'includes the five cognitive vortex types' do
      expect(described_class::VORTEX_TYPES).to include(:analytical, :creative, :emotional, :procedural, :associative)
    end
  end

  describe 'MAX_VORTICES' do
    it 'is a positive integer' do
      expect(described_class::MAX_VORTICES).to be_a(Integer)
      expect(described_class::MAX_VORTICES).to be > 0
    end
  end

  describe 'VELOCITY_DECAY' do
    it 'is a positive float less than 1' do
      expect(described_class::VELOCITY_DECAY).to be_a(Float)
      expect(described_class::VELOCITY_DECAY).to be > 0
      expect(described_class::VELOCITY_DECAY).to be < 1
    end
  end

  describe 'DEPTH_LABELS' do
    it 'is a frozen array' do
      expect(described_class::DEPTH_LABELS).to be_a(Array)
    end

    it 'each entry has a range and label' do
      described_class::DEPTH_LABELS.each do |entry|
        expect(entry).to have_key(:range)
        expect(entry).to have_key(:label)
        expect(entry[:range]).to be_a(Range)
        expect(entry[:label]).to be_a(Symbol)
      end
    end

    it 'includes insight_core label' do
      labels = described_class::DEPTH_LABELS.map { |e| e[:label] }
      expect(labels).to include(:insight_core)
    end

    it 'covers 0.0 to 1.0' do
      min = described_class::DEPTH_LABELS.map { |e| e[:range].min }.min
      expect(min).to eq(0.0)
    end
  end

  describe 'thresholds' do
    it 'POWERFUL_VELOCITY > CALM_VELOCITY' do
      expect(described_class::POWERFUL_VELOCITY).to be > described_class::CALM_VELOCITY
    end

    it 'DISSIPATION_THRESHOLD < ANGULAR_VELOCITY_MIN' do
      expect(described_class::DISSIPATION_THRESHOLD).to be < described_class::ANGULAR_VELOCITY_MIN
    end
  end
end
