class_name Enemy
extends Area2D

signal died(enemy)

var type := "drone"
var stage := 1
var hp := 20.0
var score := 100
var t := 0.0
var vel := Vector2.ZERO
var base_x := 0.0
var fire_t := 2.0
var fire_interval := 2.4
var radius := 10.0
var diving := false
var dive_vel := Vector2.ZERO
var hover_y := 0.0
var flash_t := 0.0
var sprite: Sprite2D

func setup(p_type: String, p_stage: int, pos: Vector2, param := {}) -> void:
	type = p_type
	stage = p_stage
	position = pos
	base_x = pos.x
	var hp_mul := 1.0 + 0.22 * (stage - 1)
	match type:
		"drone":
			hp = 20; score = 100; radius = 18; vel = Vector2(0, 95 + stage * 4)
			fire_interval = maxf(1.4, 2.4 - stage * 0.08)
		"weaver":
			hp = 30; score = 150; radius = 19; vel = Vector2(0, 85)
			fire_interval = maxf(1.6, 2.8 - stage * 0.08)
		"diver":
			hp = 40; score = 200; radius = 16; vel = Vector2(0, 150)
			fire_interval = 99.0
		"gunship":
			hp = 130; score = 500; radius = 25; vel = Vector2(0, 55); hover_y = 150.0
			fire_interval = maxf(1.6, 2.6 - stage * 0.08)
		"tank":
			hp = 320; score = 1000; radius = 32; vel = Vector2(0, 26)
			fire_interval = maxf(2.0, 3.2 - stage * 0.1)
		"spinner":
			hp = 160; score = 400; radius = 26; vel = Vector2(0, 60); hover_y = 140.0
			fire_interval = maxf(0.6, 0.9 - stage * 0.02)
		"shooter":
			hp = 18; score = 150; radius = 16; vel = Vector2(0, 140)
			fire_interval = maxf(0.25, 0.38 - stage * 0.01)
		"burst":
			hp = 26; score = 180; radius = 19; vel = Vector2(0, 70); hover_y = 120.0
			fire_interval = maxf(1.6, 2.2 - stage * 0.05)
		"bomber":
			hp = 16; score = 100; radius = 20; vel = Vector2(0, 150)
			fire_interval = 99.0
	hp *= hp_mul
	vel.x = param.get("vx", 0.0)
	fire_t = randf_range(1.0, fire_interval)

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("damageable")
	collision_layer = 2
	collision_mask = 1 | 4
	sprite = Sprite2D.new()
	sprite.texture = Art.enemy_tex(type, stage)
	add_child(sprite)
	var sh := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = radius
	sh.shape = c
	add_child(sh)
	area_entered.connect(_on_area)

func _process(dt: float) -> void:
	t += dt
	match type:
		"weaver":
			position.x = base_x + sin(t * 2.2) * 70.0
			position.y += vel.y * dt
		"diver":
			if not diving and position.y > 140.0:
				diving = true
				var p := Game.player
				var target := p.position if is_instance_valid(p) and p.alive else Vector2(240, 700)
				dive_vel = (target - position).normalized() * (230.0 + stage * 8.0)
			position += (dive_vel if diving else vel) * dt
		"gunship":
			if position.y < hover_y:
				position.y += vel.y * dt
			else:
				position.y += 22.0 * dt
				position.x = clampf(position.x + sin(t * 0.8) * 30.0 * dt, 40.0, 440.0)
		"spinner":
			if position.y < hover_y:
				position.y += vel.y * dt
		"shooter":
			position += vel * dt
		"burst":
			if position.y < hover_y:
				position.y += vel.y * dt
			else:
				var dir := signf(240.0 - position.x)
				position.x += dir * 70.0 * dt
				if absf(240.0 - position.x) < 40.0:
					position.x = 240.0 + dir * 40.0
		"bomber":
			if not diving and position.y > 90.0:
				diving = true
				var p := Game.player
				var target := p.position if is_instance_valid(p) and p.alive else Vector2(240, 700)
				dive_vel = (target - position).normalized() * (200.0 + stage * 6.0)
			position += (dive_vel if diving else vel) * dt
			if diving and is_instance_valid(Game.player) and Game.player.alive \
					and position.distance_to(Game.player.position) < 110.0:
				_self_destruct()
		_:
			position += vel * dt
	if flash_t > 0.0:
		flash_t -= dt
		sprite.modulate = Color(4, 4, 4) if flash_t > 0.0 else Color(1, 1, 1)
	if fire_interval < 50.0 and position.y > 40.0 and position.y < 600.0 \
			and position.x > 30.0 and position.x < 450.0:
		fire_t -= dt
		if fire_t <= 0.0:
			fire_t = fire_interval
			_shoot()
	if position.y > 770.0 or position.x < -80.0 or position.x > 560.0:
		queue_free()

func _shoot() -> void:
	var p := Game.player
	if not is_instance_valid(p) or not p.alive:
		return
	var aim := (p.position - position).normalized()
	var spd := 130.0 + stage * 8.0
	match type:
		"drone":
			Pool.fire_enemy(position + Vector2(0, 10), aim * spd, 10, "dot")
		"weaver":
			for off in [-8, 8]:
				Pool.fire_enemy(position + Vector2(off, 10), aim * spd, 10, "dot")
		"gunship":
			for i in 5:
				var ang := aim.angle() + deg_to_rad(lerpf(-30.0, 30.0, i / 4.0))
				Pool.fire_enemy(position + Vector2(0, 14), Vector2(cos(ang), sin(ang)) * spd, 10, "orb")
		"tank":
			var n := 10
			var base := randf() * TAU
			for i in n:
				var ang := base + TAU * i / n
				Pool.fire_enemy(position, Vector2(cos(ang), sin(ang)) * spd * 0.8, 10, "orb")
		"spinner":
			var n := 8
			var base := t * 2.0
			for i in n:
				var ang := base + TAU * i / n
				Pool.fire_enemy(position, Vector2(cos(ang), sin(ang)) * spd * 0.75, 10, "orb")
		"shooter":
			Pool.fire_enemy(position + Vector2(0, 12), aim * spd * 1.15, 10, "dot")
		"burst":
			for i in 5:
				var ang := aim.angle() + deg_to_rad(lerpf(-35.0, 35.0, i / 4.0))
				Pool.fire_enemy(position + Vector2(0, 14), Vector2(cos(ang), sin(ang)) * spd * 0.9, 10, "orb")

func _self_destruct() -> void:
	var n := 8
	var base := randf() * TAU
	for i in n:
		var ang := base + TAU * i / n
		Pool.fire_enemy(position, Vector2(cos(ang), sin(ang)) * 130.0, 10, "orb", {"source": "bomber"})
	SFX.play("explode_s")
	FX.explode(position, 1.4)
	Game.add_score(score)
	died.emit(self)
	queue_free()

func take_damage(d: float) -> void:
	hp -= d
	flash_t = 0.06
	if hp <= 0.0:
		SFX.play("explode_s" if type != "tank" and type != "gunship" else "explode_m")
		FX.explode(position, 1.2 if radius < 20 else 2.0)
		Game.add_score(score)
		died.emit(self)
		queue_free()
	else:
		SFX.play("hit")

func _on_area(area: Area2D) -> void:
	if area.is_in_group("player"):
		area.hit()
		take_damage(9999.0)
