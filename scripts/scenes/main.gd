class_name Main
extends Node2D

enum State { PLAY, CLEAR_WAIT, WARN, BOSS, CLEAR, OVER, WIN }

var state := State.PLAY
var stage := 1
var stage_def: Dictionary
var pending: Array = []
var director_t := 0.0
var clear_t := 0.0
var bomb_cd := 0.0
var stage_deaths := 0
var player: Player
var hud: HUD
var bg: Background

func _ready() -> void:
	if OS.get_cmdline_user_args().has("--turbo"):
		Engine.time_scale = 8.0
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_CANVAS
	env.glow_enabled = true
	env.glow_intensity = 0.6
	env.glow_strength = 1.2
	env.glow_bloom = 0.05
	we.environment = env
	add_child(we)
	var cam := Camera2D.new()
	cam.position = Vector2(240, 360)
	add_child(cam)
	cam.make_current()
	FX.camera = cam
	Pool.reset()
	bg = Background.new()
	add_child(bg)
	player = Player.new()
	add_child(player)
	player.died.connect(_on_player_died)
	player.bomb_requested.connect(_use_bomb)
	hud = HUD.new()
	add_child(hud)
	hud.main = self
	if OS.get_cmdline_user_args().has("--turbo"):
		player.invincible = 99999.0
	stage = Game.stage
	_start_stage()

func can_pause() -> bool:
	return state == State.PLAY or state == State.CLEAR_WAIT or state == State.WARN or state == State.BOSS

func _start_stage() -> void:
	Game.stage = stage
	stage_deaths = 0
	stage_def = Stages.get_stage(stage)
	bg.set_theme(stage_def["theme"])
	BGM.play_track(stage_def["bgm"])
	hud.set_stage(stage)
	hud.show_banner("第 %d 关" % stage, stage_def["name"], HUD.WHITE, 2.2, 2, 4)
	SFX.play("stage_clear" if stage == 1 else "ui_ok")
	pending.clear()
	for wave in stage_def["waves"]:
		_expand_wave(wave)
	pending.sort_custom(func(a, b): return a["t"] < b["t"])
	director_t = 0.0
	state = State.PLAY

func _expand_wave(wave: Dictionary) -> void:
	var n: int = wave["n"]
	var gap: float = wave["gap"]
	var stream_x := randf_range(90.0, 390.0)
	for i in n:
		var pos := Vector2.ZERO
		var param := {}
		match wave["pattern"]:
			"line":
				pos = Vector2(lerpf(80.0, 400.0, float(i) / maxf(1.0, n - 1.0)), -30.0)
			"vee":
				var ox := (float(i) - (n - 1) * 0.5) * 70.0
				pos = Vector2(clampf(240.0 + ox, 30.0, 450.0), -30.0 - minf(absf(ox), 90.0) * 0.5)
			"stream":
				pos = Vector2(stream_x, -30.0)
			"sides":
				if i % 2 == 0:
					pos = Vector2(-30.0, -30.0 - i * 30.0)
					param = {"vx": 60.0}
				else:
					pos = Vector2(510.0, -30.0 - i * 30.0)
					param = {"vx": -60.0}
				if wave["type"] == "gunship":
					pos = Vector2(60.0 if i % 2 == 0 else 420.0, -40.0 - i * 40.0)
					param = {}
			"center":
				pos = Vector2(240.0, -60.0)
		pending.append({"t": wave["t"] + i * gap, "type": wave["type"], "pos": pos, "param": param})

func _process(dt: float) -> void:
	if state == State.PLAY or state == State.CLEAR_WAIT or state == State.WARN or state == State.BOSS:
		Game.run_time += dt
	if bomb_cd > 0.0:
		bomb_cd -= dt
		if bomb_cd <= 0.0:
			hud.set_bomb_cd(false)
	if state == State.CLEAR_WAIT:
		clear_t += dt
		if clear_t > 0.8 and get_tree().get_nodes_in_group("enemy").is_empty():
			Pool.clear_enemy_bullets(true)
			clear_t = 0.0
			_enter_warning()
		return
	if state != State.PLAY:
		return
	director_t += dt
	while not pending.is_empty() and pending[0]["t"] <= director_t:
		var ev: Dictionary = pending.pop_front()
		_spawn_enemy(ev)
	if pending.is_empty():
		state = State.CLEAR_WAIT
		clear_t = 0.0

func _spawn_enemy(ev: Dictionary) -> void:
	var e := Enemy.new()
	e.setup(ev["type"], stage, ev["pos"], ev["param"])
	add_child(e)
	e.died.connect(_on_enemy_died)

func _on_enemy_died(e: Enemy) -> void:
	Ach.add_kill(e.type)
	var r := randf()
	var drop := ""
	match e.type:
		"gunship":
			if r < 0.25:
				drop = "P"
			elif r < 0.30:
				drop = "S"
		"tank":
			if r < 0.50:
				drop = "P"
			elif r < 0.60:
				drop = "S"
		_:
			if r < 0.08:
				drop = "P"
			elif r < 0.095:
				drop = "S"
			elif r < 0.108:
				drop = "B"
			elif r < 0.112:
				drop = "1UP"
	if drop != "":
		_drop_pickup(drop, e.position)

func _enter_warning() -> void:
	state = State.WARN
	hud.show_warning()
	SFX.play("alarm")
	await get_tree().create_timer(2.6, false).timeout
	hud.hide_warning()
	_boss_intro()

func _boss_intro() -> void:
	BGM.play_track("boss")
	FX.slowmo(0.4, 1.4)
	var boss_name: String = stage_def["boss"].get("name", "首领")
	hud.show_boss_intro(boss_name)
	_tween_cam(Vector2(240, 590), 1.35, 0.7)
	await get_tree().create_timer(0.8, false).timeout
	_spawn_boss()
	_tween_cam(Vector2(240, 120), 1.5, 1.0)
	FX.flash(Color(1, 1, 1), 0.25, 0.3)
	await get_tree().create_timer(2.0, false).timeout
	hud.hide_boss_intro()
	_tween_cam(Vector2(240, 360), 1.0, 0.8)

func _tween_cam(pos: Vector2, zoom: float, dur: float) -> void:
	if FX.camera == null:
		return
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(FX.camera, "position", pos, dur)
	tw.tween_property(FX.camera, "zoom", Vector2(zoom, zoom), dur)

func _spawn_boss() -> void:
	var b := Boss.new()
	b.setup(stage, stage_def["boss"])
	add_child(b)
	b.died.connect(_on_boss_died)
	b.hp_changed.connect(hud.update_boss_hp)
	hud.show_boss_bar(true)
	hud.update_boss_hp(b.hp, b.max_hp)
	state = State.BOSS

func _drop_pickup(type: String, pos: Vector2) -> void:
	var p := Pickup.new()
	p.setup(type, pos)
	call_deferred("add_child", p)

func _on_boss_died(b: Boss) -> void:
	state = State.CLEAR
	hud.show_boss_bar(false)
	Ach.on_boss_killed(Game.stage, stage_deaths > 0, Game.ship)
	Game.add_score(10000 * stage)
	_drop_pickup("P", b.position + Vector2(-40, 0))
	_drop_pickup("S", b.position + Vector2(40, 0))
	Pool.clear_enemy_bullets(true)
	FX.flash(Color(1, 1, 1), 0.9, 0.5)
	FX.shake(12.0, 0.8)
	FX.slowmo(0.25, 1.1)
	SFX.play("boss_down")
	var pos := b.position
	for i in 5:
		var off := Vector2(randf_range(-50, 50), randf_range(-40, 40))
		get_tree().create_timer(0.15 * i, false).timeout.connect(
			func(): FX.explode(pos + off, randf_range(1.0, 2.0)))
	BGM.play_track("victory")
	SFX.play("stage_clear")
	if stage >= Stages.count():
		_win()
		return
	hud.show_banner("关卡通过", "奖励 %d" % (10000 * stage), HUD.YELLOW, 3.0)
	await get_tree().create_timer(4.0, false).timeout
	stage += 1
	_start_stage()

func _win() -> void:
	state = State.WIN
	Ach.on_win(Game.bombs_used == 0)
	_record_run(true)
	hud.show_overlay([
		{"text": "全部通关", "color": HUD.YELLOW, "scale": 5},
		{"text": "得分 %07d" % Game.score, "color": HUD.WHITE, "scale": 2},
		{"text": "用时 %d 秒" % int(Game.run_time), "color": HUD.WHITE, "scale": 2},
		{"text": "阵亡 %d 次" % Game.deaths, "color": HUD.WHITE, "scale": 2},
		{"text": "按回车返回", "color": HUD.CYAN, "scale": 2},
	])

func _on_player_died() -> void:
	Game.deaths += 1
	stage_deaths += 1
	Ach.add_death()
	if Game.lives > 0:
		Game.add_lives(-1)
		await get_tree().create_timer(1.6, false).timeout
		player.respawn()
	else:
		Game.add_lives(-1)
		_game_over()

func _game_over() -> void:
	state = State.OVER
	_record_run(false)
	BGM.play_track("menu")
	hud.show_overlay([
		{"text": "游戏结束", "color": HUD.RED, "scale": 5},
		{"text": "得分 %07d" % Game.score, "color": HUD.WHITE, "scale": 2},
		{"text": "第 %d 关" % stage, "color": HUD.WHITE, "scale": 2},
		{"text": "按回车返回", "color": HUD.CYAN, "scale": 2},
	])

func _record_run(clear: bool) -> void:
	Data.add_run({
		"score": Game.score,
		"time": int(Game.run_time),
		"deaths": Game.deaths,
		"stage": stage,
		"ship": Game.SHIP_NAMES[Game.ship],
		"clear": clear,
	})

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("bomb"):
		if state == State.OVER or state == State.WIN:
			exit_to_menu()
			return
		_use_bomb()
	elif event.is_action_pressed("ui_accept") and (state == State.OVER or state == State.WIN):
		exit_to_menu()

func _use_bomb() -> void:
	if state == State.CLEAR or Game.bombs <= 0 or not player.alive or bomb_cd > 0.0:
		return
	bomb_cd = 5.0
	hud.set_bomb_cd(true)
	Game.add_bombs(-1)
	Game.bombs_used += 1
	Ach.mark_bomb()
	Ach.add_bomb()
	FX.bomb_effect(Vector2(240, 400))
	SFX.play("bomb")
	var cleared := Pool.clear_enemy_bullets(true)
	Ach.on_bomb_enemy_clear(cleared)
	match Game.ship:
		0:
			var enemy_count := get_tree().get_nodes_in_group("enemy").size()
			for e in get_tree().get_nodes_in_group("enemy"):
				e.take_damage(9999.0)
			Ach.on_bomb_clear(enemy_count)
			if is_instance_valid(Game.boss):
				Game.boss.take_damage(800.0)
		1:
			_volley_burst()
		2:
			_missile_rain()

func _volley_burst() -> void:
	Ach.mark_skill(1)
	for round_i in 8:
		for i in 16:
			var x := lerpf(20.0, 460.0, i / 15.0)
			Pool.fire_player(Vector2(x, 732.0), Vector2(0, -640.0), 90.0)
		SFX.play("shoot0")
		FX.shake(4.0, 0.1)
		await get_tree().create_timer(0.12, false).timeout

func _missile_rain() -> void:
	Ach.mark_skill(2)
	for i in 13:
		for side in [-1, 1]:
			for j in 2:
				Pool.fire_player(Vector2(30.0 if side < 0 else 450.0, randf_range(10, 70)),
					Vector2(0, 340), 30.0, "missile",
					{"homing": true, "turn": 4.0, "max_angle": 2.6, "radius": 5.0, "orient": true, "life": 8.0})
		SFX.play("shoot2")
		await get_tree().create_timer(0.15, false).timeout

func exit_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
