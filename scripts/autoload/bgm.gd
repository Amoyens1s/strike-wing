extends Node

const SR := 22050
const STEPS := 32

# ---------------- scales (semitone offsets from root) ----------------

const MAJOR := [0, 2, 4, 5, 7, 9, 11]
const MINOR := [0, 2, 3, 5, 7, 8, 10]
const DORIAN := [0, 2, 3, 5, 7, 9, 10]
const PHRYGIAN := [0, 1, 3, 5, 7, 8, 10]
const PHRYGIAN_DOM := [0, 1, 4, 5, 7, 8, 10]
const MIXOLYDIAN := [0, 2, 4, 5, 7, 9, 10]
const PENTA_MAJ := [0, 2, 4, 7, 9]

# ---------------- melodies (32 steps of 16th notes, scale degree or -1 rest) ----------------

const M_JUNGLE := [0, -1, 4, -1, 7, -1, 4, -1, 5, -1, 7, -1, 9, -1, 7, -1,
	4, -1, 2, -1, 4, -1, 7, -1, 0, -1, 2, 4, 5, -1, 7, -1]
const M_DESERT := [0, -1, 0, -1, 1, -1, 4, -1, 3, -1, 2, -1, 4, -1, 3, -1,
	4, -1, 3, 2, 1, -1, 4, -1, 0, -1, 0, -1, 1, -1, 4, 3]
const M_OCEAN := [0, 2, 4, 2, 4, -1, 2, -1, 4, 2, 4, 7, 9, -1, 7, -1,
	4, 2, 4, 2, 0, -1, 2, -1, 4, -1, 2, 0, -1, -1, -1, -1]
const M_SNOW := [0, -1, -1, 0, 2, -1, 3, -1, 5, -1, -1, 3, 2, -1, 0, -1,
	-1, -1, 3, -1, 5, -1, 7, -1, 5, 3, 2, 0, -1, -1, -1, -1]
const M_BASE := [0, 1, 0, 1, 0, -1, 1, -1, 0, 1, 3, 1, 0, -1, -1, -1,
	4, 3, 4, 3, 4, -1, 3, -1, 1, 3, 1, 0, -1, -1, -1, -1]
const M_CANYON := [4, -1, 3, -1, 4, -1, 3, 2, 1, -1, 4, -1, 3, -1, 2, -1,
	4, -1, 4, 3, 2, -1, 1, -1, 0, -1, 1, 0, -1, -1, -1, -1]
const M_STORM := [0, 2, 4, 5, 7, 5, 4, 2, 4, 5, 7, 9, 7, 5, 4, 2,
	0, 2, 4, 5, 7, 9, 7, 5, 9, 7, 5, 4, 2, -1, 0, -1]
const M_TUNDRA := [0, -1, 3, -1, 5, -1, 3, -1, 0, -1, 3, -1, 5, -1, 7, -1,
	5, 3, 2, 3, 0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]
const M_FORTRESS := [0, 1, 0, 1, 0, -1, 1, -1, 3, 1, 0, 1, 0, -1, -1, -1,
	0, 1, 3, 4, 3, 1, 0, -1, 1, 3, 4, 3, 1, -1, 0, -1]
const M_MOTHERSHIP := [0, -1, 4, -1, 7, -1, 4, -1, 7, 9, 7, -1, 9, -1, 7, -1,
	4, -1, 9, -1, 11, -1, 9, 7, 9, -1, 4, -1, 2, -1, 4, -1]
const M_BOSS := [0, 1, 0, 1, 4, 3, 4, 3, 0, 1, 0, 1, 7, 4, 3, 1,
	0, 1, 4, 3, 4, 3, 1, 0, 1, 3, 4, 3, 4, -1, 3, -1]
const M_MENU := [0, -1, 2, -1, 4, -1, 2, -1, 4, -1, 5, -1, 7, -1, 5, 4,
	2, -1, 4, -1, 5, -1, 7, -1, 9, -1, 7, 5, 4, -1, 2, -1]
const M_VICTORY := [0, 0, 2, 4, 5, 4, 2, 0, 4, 4, 5, 7, 9, 7, 5, 4,
	7, 7, 9, 11, 12, 11, 9, 7, 9, 7, 5, 4, 2, -1, 0, -1]

# ---------------- drum patterns (1=kick, 2=hat, 3=snare) ----------------

const D_FULL := [1, 2, 0, 2, 1, 2, 3, 2, 1, 2, 0, 2, 1, 2, 3, 2,
	1, 2, 0, 2, 1, 2, 3, 2, 1, 2, 0, 2, 1, 2, 3, 2]
const D_LIGHT := [0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2,
	0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2]
const D_PERSIAN := [1, 0, 2, 0, 1, 0, 2, 2, 1, 0, 2, 0, 1, 0, 2, 2,
	1, 0, 2, 0, 1, 0, 2, 2, 1, 0, 2, 0, 1, 0, 2, 2]
const D_SPACE := [1, 2, 1, 2, 3, 2, 1, 2, 1, 2, 1, 2, 3, 2, 1, 2,
	1, 2, 1, 2, 3, 2, 1, 2, 1, 2, 1, 2, 3, 2, 1, 2]

const TRACKS := {
	"menu": {"scale": MAJOR, "root": 48, "melody": M_MENU, "bass": [48, 48, 45, 43],
		"drums": D_LIGHT, "bpm": 96, "duty": "sqr"},
	"stage1": {"scale": DORIAN, "root": 50, "melody": M_JUNGLE, "bass": [50, 50, 45, 45],
		"drums": D_FULL, "bpm": 132, "duty": "sqr"},
	"stage2": {"scale": PHRYGIAN_DOM, "root": 52, "melody": M_DESERT, "bass": [52, 52, 52, 47],
		"drums": D_PERSIAN, "bpm": 118, "duty": "sqr25"},
	"stage3": {"scale": PENTA_MAJ, "root": 48, "melody": M_OCEAN, "bass": [48, 48, 43, 48],
		"drums": D_LIGHT, "bpm": 100, "duty": "tri"},
	"stage4": {"scale": MINOR, "root": 45, "melody": M_SNOW, "bass": [45, 45, 40, 45],
		"drums": D_FULL, "bpm": 120, "duty": "sqr25"},
	"stage5": {"scale": PHRYGIAN, "root": 50, "melody": M_BASE, "bass": [50, 49, 50, 48],
		"drums": D_FULL, "bpm": 140, "duty": "sqr25"},
	"stage6": {"scale": PHRYGIAN_DOM, "root": 45, "melody": M_CANYON, "bass": [45, 45, 40, 45],
		"drums": D_PERSIAN, "bpm": 132, "duty": "sqr25"},
	"stage7": {"scale": DORIAN, "root": 43, "melody": M_STORM, "bass": [43, 43, 43, 38],
		"drums": D_FULL, "bpm": 152, "duty": "sqr25"},
	"stage8": {"scale": MINOR, "root": 40, "melody": M_TUNDRA, "bass": [40, 40, 40, 36],
		"drums": D_FULL, "bpm": 126, "duty": "tri"},
	"stage9": {"scale": PHRYGIAN, "root": 46, "melody": M_FORTRESS, "bass": [46, 45, 46, 44],
		"drums": D_FULL, "bpm": 150, "duty": "sqr25"},
	"stage10": {"scale": MIXOLYDIAN, "root": 43, "melody": M_MOTHERSHIP, "bass": [43, 43, 50, 43],
		"drums": D_SPACE, "bpm": 160, "duty": "sqr"},
	"boss": {"scale": PHRYGIAN_DOM, "root": 52, "melody": M_BOSS, "bass": [52, 52, 47, 52],
		"drums": D_FULL, "bpm": 170, "duty": "sqr25"},
	"victory": {"scale": MAJOR, "root": 48, "melody": M_VICTORY, "bass": [48, 48, 45, 43],
		"drums": D_FULL, "bpm": 150, "duty": "sqr"},
}

var player: AudioStreamPlayer
var _current := ""
var _cache := {}

func _ready() -> void:
	player = AudioStreamPlayer.new()
	player.bus = "BGM"
	player.volume_db = -4.0
	add_child(player)

func play_track(id: String) -> void:
	if id == _current and player.playing:
		return
	_current = id
	if Data.muted:
		player.stop()
		return
	var s: AudioStreamWAV = _cache.get(id)
	if s == null:
		s = _render(TRACKS.get(id, TRACKS["menu"]))
		_cache[id] = s
	player.stream = s
	player.play()

func stop() -> void:
	player.stop()
	_current = ""

func refresh() -> void:
	if Data.muted:
		player.stop()
	elif _current != "" and not player.playing:
		player.play()

func set_paused(p: bool) -> void:
	player.stream_paused = p

func _render(def: Dictionary) -> AudioStreamWAV:
	var spb: float = 60.0 / def["bpm"] / 4.0
	var out := PackedFloat32Array()
	out.resize(int(STEPS * spb * SR) + 1)
	var scale: Array = def["scale"]
	var root: int = def["root"]
	var mel: Array = def["melody"]
	var bass: Array = def["bass"]
	var drums: Array = def["drums"]
	var duty: String = def["duty"]
	for i in STEPS:
		var start := int(i * spb * SR)
		var deg: int = mel[i]
		if deg >= 0:
			var note: int = root + scale[deg % scale.size()] + 12
			_add_tone(out, start, duty, AudioUtil.midi(note), spb * 0.9, 0.26)
		if i % 8 == 0:
			var bn: int = bass[i / 8]
			_add_tone(out, start, "tri", AudioUtil.midi(bn - 12), spb * 7.4, 0.26)
		match drums[i]:
			1:
				_add_kick(out, start)
			2:
				_add_hat(out, start)
			3:
				_add_snare(out, start)
	for i in out.size():
		out[i] = tanh(out[i] * 1.2) * 0.85
	return AudioUtil.pack16(out, SR, true)

func _add_tone(out: PackedFloat32Array, start: int, wave: String, freq: float, dur: float, vol: float) -> void:
	var n := mini(int(dur * SR), out.size() - start)
	var phase := 0.0
	for i in n:
		var t := float(i) / SR
		var env := 1.0
		if t < 0.01:
			env = t / 0.01
		elif t > dur * 0.8:
			env = maxf(0.0, (dur - t) / (dur * 0.2))
		phase += freq / SR
		out[start + i] += AudioUtil.osc(wave, phase) * vol * env

func _add_kick(out: PackedFloat32Array, start: int) -> void:
	var dur := 0.1
	var n := mini(int(dur * SR), out.size() - start)
	var phase := 0.0
	for i in n:
		var t := float(i) / SR
		var f := lerpf(160.0, 48.0, t / dur)
		phase += f / SR
		out[start + i] += sin(phase * TAU) * 0.5 * (1.0 - t / dur)

func _add_snare(out: PackedFloat32Array, start: int) -> void:
	var dur := 0.09
	var n := mini(int(dur * SR), out.size() - start)
	for i in n:
		var t := float(i) / SR
		out[start + i] += (randf() * 2.0 - 1.0) * 0.3 * (1.0 - t / dur)

func _add_hat(out: PackedFloat32Array, start: int) -> void:
	var dur := 0.04
	var n := mini(int(dur * SR), out.size() - start)
	var y := 0.0
	for i in n:
		var t := float(i) / SR
		var w := randf() * 2.0 - 1.0
		y += 0.3 * (w - y)
		out[start + i] += (w - y) * 0.14 * (1.0 - t / dur)
