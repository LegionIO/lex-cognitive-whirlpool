# lex-cognitive-whirlpool

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-cognitive-whirlpool`
- **Version**: 0.1.1
- **Namespace**: `Legion::Extensions::CognitiveWhirlpool`

## Purpose

Models circular cognitive patterns as vortices — spiraling thought attractors that pull related content toward a core. Thoughts captured by a vortex spiral inward over successive ticks, decreasing their distance from the core. At the core, thoughts represent deep focal points of rumination or insight. Vortices dissipate over time by losing angular velocity, and fully dissipated vortices are removed from the engine.

## Gem Info

- **Gemspec**: `lex-cognitive-whirlpool.gemspec`
- **Require**: `lex-cognitive-whirlpool`
- **Ruby**: >= 3.4
- **License**: MIT
- **Homepage**: https://github.com/LegionIO/lex-cognitive-whirlpool

## File Structure

```
lib/legion/extensions/cognitive_whirlpool/
  version.rb
  helpers/
    constants.rb          # Vortex types, depth labels, velocity/decay thresholds
    vortex.rb             # Vortex class — one rotating thought attractor
    captured_thought.rb   # CapturedThought class — one thought spiraling in a vortex
    whirlpool_engine.rb   # WhirlpoolEngine — registry of vortices
  runners/
    cognitive_whirlpool.rb  # Runner module — public API (extend self)
  client.rb
```

## Key Constants

| Constant | Value | Meaning |
|---|---|---|
| `MAX_VORTICES` | 12 | Hard cap; `ArgumentError` raised on create when full |
| `VELOCITY_DECAY` | 0.05 | Default angular velocity reduction per `dissipate!` call |
| `SPIRAL_RATE_DEFAULT` | 0.08 | Default spiral inward rate per `tick!` call |
| `DISSIPATION_THRESHOLD` | 0.05 | Angular velocity <= this = `dissipated?` true |
| `POWERFUL_VELOCITY` | 0.7 | Angular velocity >= this = `powerful?` true |
| `CALM_VELOCITY` | 0.2 | Angular velocity <= this = `calm?` true |
| `ANGULAR_VELOCITY_MIN` | 0.1 | Minimum clamped angular velocity at creation |
| `CAPTURE_DECAY_RATE` | 0.03 | Thought drift rate per `dissipate!` call; auto-escapes at `ESCAPE_DISTANCE` |

`VORTEX_TYPES`: `[:analytical, :creative, :emotional, :procedural, :associative]`

Depth labels (by `spiral_depth` or vortex `depth`): `0.0..0.2` = `:surface`, `0.2..0.4` = `:shallow`, `0.4..0.6` = `:mid`, `0.6..0.8` = `:deep`, `0.8..1.0` = `:insight_core`

`CapturedThought::ESCAPE_DISTANCE` = 1.0 (outer boundary); `CORE_DISTANCE` = 0.05 (inner boundary)

## Key Classes

### `Helpers::CapturedThought`

One thought spiraling in a vortex.

- `spiral!(rate:)` — increases `spiral_depth` by rate; decreases `distance_from_core` by rate; does nothing if escaped
- `at_core?` — `distance_from_core <= 0.05`
- `escaped?` — returns `@escaped` flag; `escape!` sets it true (no further spiraling)
- `depth_label` — based on `spiral_depth` against `DEPTH_LABELS`
- Fields: `thought_id` (UUID), `content`, `domain`, `spiral_depth`, `distance_from_core`, `captured_at`

### `Helpers::Vortex`

One rotating thought attractor.

- `capture!(thought)` — appends `CapturedThought` to `@captured_thoughts`; raises `ArgumentError` if not a `CapturedThought`
- `tick!(spiral_rate:)` — advances all captured thoughts by `rate = spiral_rate || (SPIRAL_RATE_DEFAULT * angular_velocity)`; increases vortex depth by `rate * 0.5`
- `dissipate!(rate:)` — decreases angular velocity by rate; decreases capture_radius by `rate * 0.5`
- `powerful?` — `angular_velocity >= 0.7`; `calm?` — `angular_velocity <= 0.2`; `dissipated?` — `angular_velocity <= 0.05`
- `thoughts_at_core` — thoughts with `distance_from_core <= 0.05`; `active_thoughts` — thoughts not escaped
- `depth_label` — based on vortex `@depth`
- Fields: `vortex_id` (UUID), `vortex_type`, `angular_velocity`, `depth`, `capture_radius`, `captured_thoughts`, `created_at`

### `Helpers::WhirlpoolEngine`

Registry of vortices.

- `create_vortex(vortex_type:, angular_velocity:, depth:, capture_radius:)` — raises `ArgumentError` when at `MAX_VORTICES`
- `inject_thought(vortex_id:, content:, domain:, distance_from_core:)` — creates `CapturedThought` and calls `vortex.capture!`; raises `ArgumentError` if vortex not found; returns `{ vortex_id:, thought_id:, domain: }`
- `tick_all!(spiral_rate:)` — calls `tick!` on every vortex; returns `{ ticked:, results: [{ vortex_id:, depth:, active_thoughts: }] }`
- `dissipate_all!(rate:)` — dissipates all vortices, then removes those where `dissipated?` is true; returns `{ dissipated:, remaining: }`
- `deepest_vortices(limit:)` — top N vortices by `depth`, returned as `to_h` array
- `vortex_report` — `{ total_vortices:, powerful_count:, calm_count:, total_thoughts:, core_thoughts:, deepest_vortices: }`
- `remove_vortex(vortex_id)` — removes by ID, returns `{ removed: }`; `clear` resets all vortices

## Runners

Module: `Legion::Extensions::CognitiveWhirlpool::Runners::CognitiveWhirlpool` (`extend self`)

| Runner | Key Args | Returns |
|---|---|---|
| `create_vortex` | `vortex_type:`, `angular_velocity:`, `depth:`, `capture_radius:` | `{ success:, vortex: }` or `{ success: false, error: }` |
| `inject_thought` | `vortex_id:`, `content:`, `domain:`, `distance_from_core:` | `{ success:, vortex_id:, thought_id:, domain: }` or error |
| `tick_all` | `spiral_rate:` | `{ success:, ticked:, results: }` |
| `dissipate_all` | `rate:` | `{ success:, dissipated:, remaining: }` |
| `vortex_report` | — | full report merged with `success: true` |
| `deepest_vortices` | `limit:` | `{ success:, vortices: }` |
| `remove_vortex` | `vortex_id:` | `{ success:, removed: }` |
| `clear_engine` | — | `{ success:, cleared: true }` |

All runners accept optional `engine:` keyword for test injection.

## Integration Points

- No actors defined; `tick_all` should be called periodically to advance spiraling
- `dissipate_all` should be called periodically as a decay mechanism; removes vortices that fall below `DISSIPATION_THRESHOLD`
- `vortex_report` surfaces `core_thoughts` — deeply processed content that has reached the insight core
- Pairs with `lex-cognitive-triage` — rumination vortices can emerge from unresolved high-priority demands
- All state is in-memory per `WhirlpoolEngine` instance

## Development Notes

- `MAX_VORTICES` raises `ArgumentError` (not a soft return nil) — callers must handle the exception
- Angular velocity minimum at creation is `ANGULAR_VELOCITY_MIN = 0.1` — vortices cannot be created stationary
- `tick!` spiral rate = `spiral_rate || (SPIRAL_RATE_DEFAULT * angular_velocity)` — faster vortices spiral thoughts inward faster
- `dissipate_all!` removes vortices in-place after dissipation (the `reject!` call); total dissipated = before minus remaining
- `CAPTURE_DECAY_RATE = 0.03` is enforced: `Vortex#dissipate!` calls `decay!` on all captured thoughts, increasing their `distance_from_core`; thoughts that drift to `ESCAPE_DISTANCE` (1.0) auto-escape
- Vortex `depth` increases each tick regardless of whether the vortex has captured thoughts
