// hall_of_mirrors_sky.gdshader
//
// Simulates the "Hall of Mirrors" (HOM) artifact from 90s BSP engines.
// When a renderer fails to clear the framebuffer before drawing a new frame,
// old pixel data bleeds through wherever geometry is missing. The result is
// that the sky/void areas show smeared, ghostly echoes of the world around them.
//
// This shader fakes that by sampling the sky from slightly offset view directions
// (simulating "ghost frames" that were never erased), then accumulating them
// with a decaying weight — exactly what a non-cleared framebuffer looks like.
//
// HOW TO USE:
//   1. Add a WorldEnvironment node to your scene.
//   2. Create a new Sky resource on it.
//   3. Set the Sky Material to a new ShaderSkyMaterial.
//   4. Assign this shader to the ShaderSkyMaterial.
//
// TWEAKING TIPS:
//   - ghost_count:    More ghosts = denser smear, more expensive. 6–12 is good.
//   - smear_angle:    How far each ghost is offset. Larger = wider smear trails.
//   - decay:          How fast ghosts fade. Low = long persistent trails (more HOM-like).
//   - rotation_speed: Simulates the player spinning/moving, driving the smear direction.
//   - smear_axis:     Which way the trails smear (world-space axis).

shader_type sky;

// ── Tunables ────────────────────────────────────────────────────────────────

// How many "uncleared frames" to accumulate behind the current view
uniform int   ghost_count      : hint_range(1, 16)      = 8;

// Angular spread of each ghost frame in radians (how far back each echo is rotated)
uniform float smear_angle      : hint_range(0.0, 0.5)   = 0.07;

// Decay factor per ghost: 0 = all ghosts same brightness, 1 = ghosts invisible
uniform float decay            : hint_range(0.0, 1.0)   = 0.45;

// Simulated camera rotation speed — drives the smear direction over time
uniform float rotation_speed   : hint_range(-4.0, 4.0)  = 0.6;

// World-space axis the smear trails along (normalized automatically in shader)
uniform vec3  smear_axis                                 = vec3(0.0, 1.0, 0.0);

// Base "void" color — what the framebuffer held before anything was drawn
// In old games this was whatever junk was in VRAM (often black or a solid color)
uniform vec3  void_color       : source_color            = vec3(0.0, 0.0, 0.0);

// The "world edge" color — color of geometry bleeding into the void
// This approximates the dominant color at the boundary of visible geometry
uniform vec3  world_edge_color : source_color            = vec3(0.35, 0.18, 0.05);

// A secondary color for variety (like multiple material colors smearing together)
uniform vec3  world_edge_color2: source_color            = vec3(0.08, 0.22, 0.30);

// How strongly the geometry color bleeds into the smear
uniform float bleed_strength   : hint_range(0.0, 1.0)   = 0.85;

// Adds a subtle brightness pulse — old monitors had refresh sync issues
uniform float flicker          : hint_range(0.0, 1.0)   = 0.12;

// Slight color channel misalignment (chromatic aberration from analog output)
uniform float chroma_shift     : hint_range(0.0, 0.05)  = 0.008;

// ── Helpers ─────────────────────────────────────────────────────────────────

// Rotate a direction vector around an arbitrary axis by angle (Rodrigues' formula)
vec3 rotate_around(vec3 v, vec3 axis, float angle) {
	axis = normalize(axis);
	float c = cos(angle);
	float s = sin(angle);
	return v * c + cross(axis, v) * s + axis * dot(axis, v) * (1.0 - c);
}

// Sample the "world bleed" color for a given direction.
// This stands in for what old framebuffer pixels would actually contain —
// remnants of geometry. We synthesize it from the two world_edge colors
// using directional and time variation.
vec3 sample_world_bleed(vec3 dir, float time) {
	// Mix between the two edge colors based on horizontal direction
	float h = atan(dir.z, dir.x) / (2.0 * PI) + 0.5;
	// Slow drift to simulate the framebuffer content changing over time
	float drift = fract(h + time * 0.03);

	// Chunky steps — old palettized renderers had discrete color levels
	float steps = 8.0;
	drift = floor(drift * steps) / steps;

	vec3 bleed = mix(world_edge_color, world_edge_color2, drift);

	// Vertical gradient: geometry color is stronger near the horizon,
	// fades to void at the zenith/nadir (no geometry there to bleed from)
	float horizon_factor = 1.0 - abs(dir.y);
	horizon_factor = pow(horizon_factor, 1.5);

	return mix(void_color, bleed, horizon_factor * bleed_strength);
}

// ── Main ────────────────────────────────────────────────────────────────────

void sky() {
	vec3  view_dir = EYEDIR;
	float time     = TIME;
	vec3  axis     = normalize(smear_axis);

	// ── Accumulate ghost frames ──────────────────────────────────────────────
	// We simulate N "previous frames" that were never cleared from the buffer.
	// Each one is rotated slightly from the current view (as if the camera moved)
	// and blended in with decreasing weight — exactly what HOM looks like.

	vec3  accumulated_color = vec3(0.0);
	float total_weight      = 0.0;

	// Simulated camera rotation offset accumulated so far
	float angle_offset = time * rotation_speed * 0.01; // slow drift baseline

	for (int i = 0; i < ghost_count; i++) {
		float t = float(i) / float(ghost_count);

		// Each ghost is offset by one more smear_angle step back in "time"
		float ghost_angle = smear_angle * float(i + 1) * sign(rotation_speed + 0.001);

		// Rotate the view direction to where this ghost frame "came from"
		vec3 ghost_dir = rotate_around(view_dir, axis, ghost_angle + angle_offset * t);

		// Sample what the framebuffer held in that direction
		vec3 ghost_color = sample_world_bleed(ghost_dir, time - float(i) * 0.016);
		// 0.016s per frame ≈ 60fps — each ghost is one frame older

		// Weight decays exponentially: closer ghosts are brighter
		float weight = pow(1.0 - decay, float(i));

		accumulated_color += ghost_color * weight;
		total_weight      += weight;
	}

	// Normalize
	vec3 color = accumulated_color / max(total_weight, 0.001);

	// ── Current "frame" sample ───────────────────────────────────────────────
	// The "real" current pixel — but in HOM, even the current frame is contaminated.
	// We blend it weakly against the ghost accumulation.
	vec3 current = sample_world_bleed(view_dir, time);
	color = mix(color, current, 0.2);

	// ── Chromatic aberration ─────────────────────────────────────────────────
	// Analog video output caused color channels to misalign, especially on motion.
	// Sample R and B from slightly offset directions.
	if (chroma_shift > 0.0) {
		vec3 dir_r = rotate_around(view_dir, axis,  chroma_shift);
		vec3 dir_b = rotate_around(view_dir, axis, -chroma_shift);
		color.r = sample_world_bleed(dir_r, time).r;
		color.b = sample_world_bleed(dir_b, time).b;
	}

	// ── Flicker ──────────────────────────────────────────────────────────────
	// VSync issues and monitor phosphor decay caused subtle frame-level flicker.
	float flicker_val = 1.0 - flicker * abs(sin(time * 29.7)) * 0.5;
	color *= flicker_val;

	// ── Hard void at extreme zenith/nadir ────────────────────────────────────
	// Looking straight up or down, there's nothing — just raw VRAM junk (void color).
	float extremity = pow(abs(view_dir.y), 3.0);
	color = mix(color, void_color, extremity * 0.8);

	COLOR = color;
}
