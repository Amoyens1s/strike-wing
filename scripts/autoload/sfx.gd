extends Node

const SR := 44100
const POOL_SIZE := 24
const THROTTLE := {"shoot0": 0.05, "shoot1": 0.05, "shoot2": 0.05, "hit": 0.03, "explode_s": 0.04}

var _pool: Array = []
var _idx := 0
var _cache := {}
var _last := {}

func _ready() -> void:
	_ensure_bus("SFX")
	_ensure_bus("BGM")
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_pool.append(p)

func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) == -1:
		AudioServer.add_bus()
		var i := AudioServer.bus_count - 1
		AudioServer.set_bus_name(i, bus_name)
		AudioServer.set_bus_send(i, "Master")

func play(sfx_name: String) -> void:
	if Data.muted:
		print("[SFX] ", sfx_name, " SKIP muted")
		return
	var now := Time.get_ticks_msec() / 1000.0
	if _last.get(sfx_name, -99.0) + THROTTLE.get(sfx_name, 0.0) > now:
		return
	_last[sfx_name] = now
	var stream: AudioStreamWAV = _cache.get(sfx_name)
	if stream == null:
		stream = _build(sfx_name)
		_cache[sfx_name] = stream
	var p: AudioStreamPlayer = _pool[_idx]
	_idx = (_idx + 1) % POOL_SIZE
	p.stream = stream
	p.pitch_scale = randf_range(0.95, 1.05)
	p.play()

# spec kinds:
# {"k":"tone","wave","f0","f1","dur","vol","a","r","curve","at"}
# {"k":"noise","dur","vol","lp","hp","a","r","at"}
# {"k":"seq","wave","notes","step","vol","at"}
func _build(sfx_name: String) -> AudioStreamWAV:
	var specs: Array
	var total := 0.5
	match sfx_name:
		"shoot0":
			specs = [{"k": "tone", "wave": "sqr25", "f0": 1150, "f1": 750, "dur": 0.06, "vol": 0.3, "a": 0.001, "r": 0.02}]
			total = 0.07
		"shoot1":
			specs = [{"k": "tone", "wave": "sqr", "f0": 650, "f1": 420, "dur": 0.07, "vol": 0.28, "a": 0.001, "r": 0.02}]
			total = 0.08
		"shoot2":
			specs = [{"k": "tone", "wave": "sqr25", "f0": 1800, "f1": 1200, "dur": 0.05, "vol": 0.26, "a": 0.001, "r": 0.02}]
			total = 0.06
		"hit":
			specs = [{"k": "tone", "wave": "sqr", "f0": 550, "f1": 220, "dur": 0.05, "vol": 0.3, "a": 0.001},
				{"k": "noise", "dur": 0.04, "vol": 0.25, "lp": 0.95, "hp": true}]
			total = 0.06
		"explode_s":
			specs = [{"k": "noise", "dur": 0.06, "vol": 0.5, "lp": 0.95, "hp": true, "r": 0.02},
				{"k": "noise", "dur": 0.32, "vol": 0.55, "lp": 0.15, "at": 0.005, "r": 0.2},
				{"k": "tone", "wave": "sin", "f0": 260, "f1": 55, "dur": 0.32, "vol": 0.5, "at": 0.005, "r": 0.2}]
			total = 0.34
		"explode_m":
			specs = [{"k": "noise", "dur": 0.08, "vol": 0.55, "lp": 0.95, "hp": true, "r": 0.02},
				{"k": "noise", "dur": 0.6, "vol": 0.6, "lp": 0.12, "at": 0.005, "r": 0.4},
				{"k": "tone", "wave": "sin", "f0": 180, "f1": 45, "dur": 0.6, "vol": 0.55, "at": 0.005, "r": 0.45},
				{"k": "noise", "dur": 0.12, "vol": 0.3, "lp": 0.4, "at": 0.03}]
			total = 0.65
		"explode_boss":
			specs = [{"k": "noise", "dur": 0.12, "vol": 0.6, "lp": 0.95, "hp": true, "r": 0.03},
				{"k": "noise", "dur": 1.5, "vol": 0.65, "lp": 0.08, "at": 0.01, "r": 1.0},
				{"k": "tone", "wave": "sin", "f0": 120, "f1": 30, "dur": 1.5, "vol": 0.6, "at": 0.01, "r": 1.0},
				{"k": "noise", "dur": 0.14, "vol": 0.4, "lp": 0.5, "at": 0.15},
				{"k": "noise", "dur": 0.14, "vol": 0.4, "lp": 0.5, "at": 0.5},
				{"k": "noise", "dur": 0.2, "vol": 0.45, "lp": 0.4, "at": 0.9}]
			total = 1.55
		"die":
			specs = [{"k": "noise", "dur": 0.08, "vol": 0.5, "lp": 0.95, "hp": true, "r": 0.02},
				{"k": "tone", "wave": "saw", "f0": 900, "f1": 80, "dur": 0.6, "vol": 0.45, "a": 0.002, "r": 0.3},
				{"k": "noise", "dur": 0.6, "vol": 0.55, "lp": 0.25, "at": 0.01, "r": 0.35}]
			total = 1.1
		"pickup":
			specs = [{"k": "seq", "wave": "tri", "notes": [76, 83, 88, 95], "step": 0.045, "vol": 0.32}]
			total = 0.24
		"powerup":
			specs = [{"k": "seq", "wave": "sqr25", "notes": [60, 64, 67, 72, 76, 80], "step": 0.06, "vol": 0.32}]
			total = 0.42
		"shield_on":
			specs = [{"k": "tone", "wave": "sin", "f0": 2093, "f1": 2093, "dur": 0.35, "vol": 0.3, "r": 0.3},
				{"k": "tone", "wave": "sin", "f0": 4186, "f1": 4186, "dur": 0.3, "vol": 0.12, "r": 0.25}]
			total = 0.38
		"shield_break":
			specs = [{"k": "noise", "dur": 0.32, "vol": 0.5, "lp": 0.92, "hp": true, "r": 0.2},
				{"k": "tone", "wave": "sqr", "f0": 2200, "f1": 400, "dur": 0.28, "vol": 0.26, "a": 0.001, "r": 0.2}]
			total = 0.34
		"bomb":
			specs = [{"k": "tone", "wave": "saw", "f0": 80, "f1": 520, "dur": 0.4, "vol": 0.4, "a": 0.002, "curve": 2.0},
				{"k": "noise", "dur": 0.1, "vol": 0.6, "lp": 0.95, "hp": true, "at": 0.3},
				{"k": "noise", "dur": 1.0, "vol": 0.65, "lp": 0.1, "at": 0.3, "r": 0.6},
				{"k": "tone", "wave": "sin", "f0": 150, "f1": 35, "dur": 1.0, "vol": 0.55, "at": 0.3, "r": 0.6}]
			total = 1.35
		"alarm":
			specs = [{"k": "seq", "wave": "sqr", "notes": [78, 75, 78, 75, 78, 75], "step": 0.16, "vol": 0.3}]
			total = 1.0
		"boss_down":
			specs = [{"k": "noise", "dur": 0.5, "vol": 0.55, "lp": 0.15},
				{"k": "noise", "dur": 0.5, "vol": 0.55, "lp": 0.12, "at": 0.35},
				{"k": "noise", "dur": 0.7, "vol": 0.6, "lp": 0.1, "at": 0.7},
				{"k": "seq", "wave": "sqr25", "notes": [72, 76, 79, 84, 88], "step": 0.1, "vol": 0.32, "at": 1.3}]
			total = 1.9
		"ui_move":
			specs = [{"k": "tone", "wave": "sqr", "f0": 1500, "f1": 1300, "dur": 0.025, "vol": 0.2, "a": 0.001, "r": 0.01}]
			total = 0.035
		"ui_ok":
			specs = [{"k": "seq", "wave": "sqr", "notes": [76, 84], "step": 0.06, "vol": 0.28}]
			total = 0.16
		"1up":
			specs = [{"k": "seq", "wave": "tri", "notes": [72, 76, 79, 84, 88, 91], "step": 0.06, "vol": 0.32}]
			total = 0.42
		"stage_clear":
			specs = [{"k": "seq", "wave": "sqr25", "notes": [72, 72, 72, 76, 79, 84, 88], "step": 0.1, "vol": 0.32}]
			total = 0.78
		_:
			specs = [{"k": "tone", "wave": "sqr", "f0": 440, "f1": 440, "dur": 0.1, "vol": 0.2}]
			total = 0.12
	var samples := PackedFloat32Array()
	samples.resize(int(total * SR))
	for spec in specs:
		_render_into(samples, spec)
	return AudioUtil.pack16(samples, SR)

func _render_into(out: PackedFloat32Array, spec: Dictionary) -> void:
	var start := int(spec.get("at", 0.0) * SR)
	match spec.get("k", "tone"):
		"tone":
			var dur: float = spec["dur"]
			var n := int(dur * SR)
			var phase := 0.0
			var a: float = spec.get("a", 0.005)
			var r: float = spec.get("r", 0.03)
			var curve: float = spec.get("curve", 1.0)
			for i in n:
				var idx := start + i
				if idx >= out.size():
					break
				var t := float(i) / SR
				var k := t / dur
				var f := lerpf(spec["f0"], spec["f1"], pow(k, curve))
				phase += f / SR
				var env := 1.0
				if t < a:
					env = t / a
				elif t > dur - r:
					env = maxf(0.0, (dur - t) / r)
				out[idx] += AudioUtil.osc(spec["wave"], phase) * spec["vol"] * env
		"noise":
			var dur: float = spec["dur"]
			var n := int(dur * SR)
			var lp: float = spec.get("lp", 0.2)
			var hp: bool = spec.get("hp", false)
			var a: float = spec.get("a", 0.005)
			var r: float = spec.get("r", 0.08)
			var y := 0.0
			for i in n:
				var idx := start + i
				if idx >= out.size():
					break
				var t := float(i) / SR
				var w := randf() * 2.0 - 1.0
				y += lp * (w - y)
				var s := (w - y) if hp else y
				var env := 1.0
				if t < a:
					env = t / a
				elif t > dur - r:
					env = maxf(0.0, (dur - t) / r)
				out[idx] += s * spec["vol"] * env
		"seq":
			var notes: Array = spec["notes"]
			var step: float = spec["step"]
			var a := 0.005
			for ni in notes.size():
				var m: int = notes[ni]
				if m < 0:
					continue
				var f := AudioUtil.midi(m)
				var n := int(step * SR)
				var phase := 0.0
				for i in n:
					var idx := start + ni * int(step * SR) + i
					if idx >= out.size():
						break
					var t := float(i) / SR
					var env := 1.0
					if t < a:
						env = t / a
					else:
						env = maxf(0.15, 1.0 - t / step * 0.85)
					phase += f / SR
					out[idx] += AudioUtil.osc(spec["wave"], phase) * spec["vol"] * env
