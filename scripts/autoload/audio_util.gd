class_name AudioUtil

static func midi(m: float) -> float:
	return 440.0 * pow(2.0, (m - 69.0) / 12.0)

static func osc(wave: String, phase: float) -> float:
	var p := fposmod(phase, 1.0)
	match wave:
		"sin":
			return sin(p * TAU)
		"sqr":
			return 1.0 if p < 0.5 else -1.0
		"sqr25":
			return 1.0 if p < 0.25 else -1.0
		"tri":
			return 4.0 * absf(p - 0.5) - 1.0
		"saw":
			return p * 2.0 - 1.0
	return 0.0

static func pack16(samples: PackedFloat32Array, sr: int, loop := false) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in samples.size():
		var v := int(clampf(samples[i], -1.0, 1.0) * 32767.0)
		if v < 0:
			v += 65536
		data[i * 2] = v & 0xFF
		data[i * 2 + 1] = (v >> 8) & 0xFF
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = sr
	s.stereo = false
	s.data = data
	if loop:
		s.loop_mode = AudioStreamWAV.LOOP_FORWARD
		s.loop_begin = 0
		s.loop_end = samples.size()
	return s
