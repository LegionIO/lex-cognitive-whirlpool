# Changelog

## [0.1.1] - 2026-03-18

### Added
- `CapturedThought#decay!` method — increases `distance_from_core` by `CAPTURE_DECAY_RATE` (0.03), auto-escapes thoughts that drift to `ESCAPE_DISTANCE`

### Fixed
- Enforce `CAPTURE_DECAY_RATE` — `Vortex#dissipate!` now decays all captured thoughts when the vortex loses angular velocity, causing loosely-held thoughts to escape dissipating vortices

## [0.1.0] - 2026-03-13

### Added
- Initial release: vortex creation, thought capture, spiraling, dissipation
- Five vortex types (analytical, creative, emotional, procedural, associative)
- Depth labels, whirlpool engine, standalone Client
