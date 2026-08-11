class_name Stages

const NAMES := ["丛林", "沙漠", "海洋", "雪原", "基地", "峡谷", "风暴", "冻土", "要塞", "母舰"]
const THEMES := ["jungle", "desert", "ocean", "snow", "base", "canyon", "storm", "tundra", "fortress", "space"]

const BOSS_NAMES := ["藤蔓之王", "沙暴君主", "深海霸主", "霜牙暴君", "钢铁暴君",
	"赤岩巨蟒", "雷暴之眼", "寒渊巨兽", "铁壁巨人", "星辰毁灭者"]

const BOSS_PHASES := {
	1: [["fan"], ["ring"]],
	2: [["spiral"], ["fan"]],
	3: [["homing"], ["ring"]],
	4: [["wave"], ["spiral"]],
	5: [["wall"], ["fan"], ["ring"]],
	6: [["spiral"], ["homing"]],
	7: [["ring"], ["wave"], ["fan"]],
	8: [["fan"], ["homing"], ["spiral"]],
	9: [["wall"], ["ring"], ["wave"]],
	10: [["spiral"], ["fan"], ["homing"], ["ring"], ["wave"]],
}

static func count() -> int:
	return 10

static func get_stage(s: int) -> Dictionary:
	var waves := []
	var t := 1.5
	var wave_count := 7 + s
	var gap := clampf(4.6 - 0.16 * s, 2.7, 4.6)
	var pool := ["drone", "weaver", "diver"]
	if s >= 2:
		pool.append("gunship")
	if s >= 3:
		pool.append("burst")
		pool.append("shooter")
	if s >= 4:
		pool.append("spinner")
	if s >= 5:
		pool.append("tank")
		pool.append("bomber")
	var barrages := ["spinner", "burst", "shooter"]
	if s >= 7:
		barrages = ["spinner", "spinner", "burst", "shooter"]
	for w in wave_count:
		var ttype: String
		if s >= 3 and w % 4 == 3:
			ttype = barrages[(w / 4) % barrages.size()]
		else:
			ttype = pool[w % pool.size()]
		_append_wave(waves, ttype, s, t, gap)
		t += gap

	return {
		"name": NAMES[s - 1],
		"theme": THEMES[s - 1],
		"bgm": "stage%d" % s,
		"waves": waves,
		"boss": {"name": BOSS_NAMES[s - 1], "hp": 2600.0 + 1600.0 * (s - 1), "phases": BOSS_PHASES[s]},
	}

static func _append_wave(waves: Array, ttype: String, s: int, t: float, gap: float) -> void:
	match ttype:
		"drone":
			waves.append({"t": t, "type": ttype, "n": 4 + s / 2, "pattern": "line", "gap": 0.35})
		"weaver":
			waves.append({"t": t, "type": ttype, "n": 3 + s / 3, "pattern": "vee", "gap": 0.4})
		"diver":
			waves.append({"t": t, "type": ttype, "n": 3 + s / 2, "pattern": "stream", "gap": 0.5})
		"gunship":
			waves.append({"t": t, "type": ttype, "n": 2 if s >= 5 else 1, "pattern": "sides", "gap": 1.2})
		"tank":
			waves.append({"t": t, "type": ttype, "n": 1, "pattern": "center", "gap": 0.0})
		"spinner":
			waves.append({"t": t, "type": ttype, "n": 2 if s >= 6 else 1, "pattern": "line", "gap": 1.0})
		"shooter":
			waves.append({"t": t, "type": ttype, "n": 3 + s / 2, "pattern": "line", "gap": 0.3})
		"burst":
			waves.append({"t": t, "type": ttype, "n": 3 + s / 2, "pattern": "sides", "gap": 0.5})
		"bomber":
			waves.append({"t": t, "type": ttype, "n": 3 + s / 2, "pattern": "stream", "gap": 0.4})
		_:
			waves.append({"t": t, "type": "drone", "n": 4, "pattern": "line", "gap": 0.35})
