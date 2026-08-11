class_name Boss
extends Area2D

signal died(boss)
signal hp_changed(cur, max_hp)

var stage := 1
var max_hp := 2600.0
var hp := 2600.0
var phases: Array = []
var phase_idx := -1
var entering := true
var dead := false
var t := 0.0
var spiral_angle := 0.0
var flash_t := 0.0
var timers := {}
var sprite: Sprite2D

func setup(p_stage: int, def: Dictionary) -> void:
	stage = p_stage
	max_hp = def["hp"]
	hp = max_hp
	phases = def["phases"]
	position = Vector2(240, -90)

func _ready() -> void:
	add_to_group("damageable")
	add_to_group("boss")
	collision_layer = 2
	collision_mask = 1 | 4
	Game.boss = self
	sprite = Sprite2D.new()
	sprite.texture = Art.boss_ship_tex(stage)
	add_child(sprite)
	var sh := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 42.0
	sh.shape = c
	add_child(sh)
	area_entered.connect(_on_area)

func _exit_tree() -> void:
	if Game.boss == self:
		Game.boss = null

func _process(dt: float) -> void:
	if dead:
		return
	t += dt
	if entering:
		position.y += 70.0 * dt
		if position.y >= 150.0:
			entering = false
			t = 0.0
			_next_phase()
		return
	position.x = 240.0 + sin(t * 0.6) * 140.0
	position.y = 150.0 + sin(t * 1.2) * 26.0
	if flash_t > 0.0:
		flash_t -= dt
		sprite.modulate = Color(4, 4, 4) if flash_t > 0.0 else Color(1, 1, 1)
	_fire(dt)

func _next_phase() -> void:
	phase_idx += 1
	if phase_idx >= phases.size():
		phase_idx = phases.size() - 1
	timers.clear()
	FX.flash(Color(1, 0.4, 0.3), 0.35, 0.25)
	FX.shake(6.0, 0.3)
	SFX.play("explode_m")

func _fire(dt: float) -> void:
	if phase_idx < 0 or phase_idx >= phases.size():
		return
	var pattern: String = phases[phase_idx][0]
	var spd := 1.0 + 0.06 * (stage - 1)
	for key in timers.keys():
		timers[key] -= dt
	match pattern:
		"spiral":
			if timers.get("a", 0.0) <= 0.0:
				timers["a"] = maxf(0.05, 0.10 - stage * 0.003)
				spiral_angle += 0.42
				for off in [0.0, PI]:
					var ang: float = spiral_angle + off
					Pool.fire_enemy(position, Vector2(cos(ang), sin(ang)) * 120.0 * spd, 10, "dot")
		"fan":
			if timers.get("a", 0.0) <= 0.0:
				timers["a"] = maxf(0.9, 1.5 - stage * 0.05)
				var base := _aim_angle()
				for i in 7:
					var ang := base + deg_to_rad(lerpf(-36.0, 36.0, i / 6.0))
					Pool.fire_enemy(position, Vector2(cos(ang), sin(ang)) * 190.0 * spd, 10, "orb")
		"ring":
			if timers.get("a", 0.0) <= 0.0:
				timers["a"] = maxf(1.1, 1.9 - stage * 0.06)
				var base := randf() * TAU
				var n := 18 + stage
				for i in n:
					var ang := base + TAU * i / n
					Pool.fire_enemy(position, Vector2(cos(ang), sin(ang)) * 130.0 * spd, 10, "diamond", {"spin": 4.0})
		"homing":
			if timers.get("a", 0.0) <= 0.0:
				timers["a"] = maxf(1.4, 2.3 - stage * 0.07)
				var base := _aim_angle()
				for i in 5:
					var ang := base + deg_to_rad(lerpf(-40.0, 40.0, i / 4.0))
					Pool.fire_enemy(position, Vector2(cos(ang), sin(ang)) * 100.0 * spd, 10, "orb_big",
						{"homing": true, "homing_t": 1.5, "turn": 2.2, "radius": 6.0, "life": 7.0})
		"wave":
			if timers.get("a", 0.0) <= 0.0:
				timers["a"] = 0.55
				var base := _aim_angle() + deg_to_rad(sin(t * 3.0) * 40.0)
				for i in 4:
					var ang := base + deg_to_rad(lerpf(-22.0, 22.0, i / 3.0))
					Pool.fire_enemy(position, Vector2(cos(ang), sin(ang)) * 170.0 * spd, 10, "bolt")
		"wall":
			if timers.get("a", 0.0) <= 0.0:
				timers["a"] = 2.6
				for i in 10:
					var ang := deg_to_rad(lerpf(10.0, 170.0, i / 9.0))
					Pool.fire_enemy(position, Vector2(cos(ang), sin(ang)) * 150.0 * spd, 10, "orb")
				timers["b"] = 0.6
			if timers.has("b") and timers["b"] <= 0.0:
				timers.erase("b")
				var base := _aim_angle()
				for off in [-0.12, 0.0, 0.12]:
					var ang: float = base + off
					Pool.fire_enemy(position, Vector2(cos(ang), sin(ang)) * 260.0 * spd, 10, "dot")

func _aim_angle() -> float:
	var p := Game.player
	if is_instance_valid(p) and p.alive:
		return (p.position - position).angle()
	return PI / 2.0

func take_damage(d: float) -> void:
	if dead or entering:
		return
	hp -= d
	flash_t = 0.05
	hp_changed.emit(hp, max_hp)
	if hp <= 0.0:
		_die()
		return
	var frac := hp / max_hp
	var want := mini(phases.size() - 1, int((1.0 - frac) * phases.size()))
	if want > phase_idx:
		_next_phase_to(want)

func _next_phase_to(idx: int) -> void:
	phase_idx = idx - 1
	_next_phase()

func _die() -> void:
	dead = true
	set_process(false)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	sprite.visible = false
	FX.explode(position, 3.0)
	SFX.play("explode_boss")
	died.emit(self)
	await get_tree().create_timer(0.1).timeout
	queue_free()

func _on_area(area: Area2D) -> void:
	if area.is_in_group("player"):
		area.hit()
