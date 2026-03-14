# lex-cognitive-whirlpool

A LegionIO cognitive architecture extension that models circular cognitive patterns as vortices — spiraling thought attractors that pull related content toward an insight core.

## What It Does

Tracks **vortices** (rotating thought attractors) and the **captured thoughts** spiraling within them.

Each vortex has:
- A type (`:analytical`, `:creative`, `:emotional`, `:procedural`, `:associative`)
- Angular velocity (rotation speed), depth (how deep the vortex has drilled), and capture radius
- Depth label: `:surface`, `:shallow`, `:mid`, `:deep`, `:insight_core`

Each captured thought spirals inward over ticks — `spiral_depth` increases and `distance_from_core` decreases. When a thought reaches the core (`distance_from_core <= 0.05`), it has been deeply processed.

Vortices dissipate over time by losing angular velocity. When velocity drops below 0.05, the vortex is removed during the next `dissipate_all` call.

## Usage

```ruby
require 'lex-cognitive-whirlpool'

client = Legion::Extensions::CognitiveWhirlpool::Client.new

# Create an analytical vortex
result = client.create_vortex(
  vortex_type:      :analytical,
  angular_velocity: 0.8,
  depth:            0.0,
  capture_radius:   0.6
)
# => { success: true, vortex: { vortex_id: "uuid...", vortex_type: :analytical,
#      angular_velocity: 0.8, depth: 0.0, depth_label: :surface, powerful: true, ... } }

vortex_id = result[:vortex][:vortex_id]

# Inject a thought into the vortex
client.inject_thought(
  vortex_id:          vortex_id,
  content:            'Is this decision consistent with my values?',
  domain:             :ethics,
  distance_from_core: 1.0
)
# => { success: true, vortex_id: "uuid...", thought_id: "uuid...", domain: :ethics }

# Advance all vortices by one tick (thoughts spiral inward)
client.tick_all
# => { success: true, ticked: 1, results: [{ vortex_id: "uuid...", depth: 0.032, active_thoughts: 1 }] }

# Check the vortex report
client.vortex_report
# => { success: true, total_vortices: 1, powerful_count: 1, calm_count: 0,
#      total_thoughts: 1, core_thoughts: 0, deepest_vortices: [...] }

# Find the deepest vortices
client.deepest_vortices(limit: 3)
# => { success: true, vortices: [...] }

# Dissipate all vortices (periodic decay — removes fully dissipated ones)
client.dissipate_all
# => { success: true, dissipated: 0, remaining: 1 }
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
