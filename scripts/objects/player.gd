class_name Player
extends Area2D

signal died
signal bomb_requested

const SPEED := 250.0
const BOUNDS := Rect2(20, 20, 440, 680)

var alive := true
var shield := false
var invincible := 0.0
var fire_t := 0.0
var missile_t := 0.3
var flash_t := 0.0

var body: Node2D
var sprite: Sprite2D
var flame: Sprite2D
var shield_spr: Sprite2D
var touch_id := -1
var touch_center := Vector2.ZERO
var touch_dir := Vector2.ZERO
var joy_base: Sprite2D
var joy_knob: Sprite2D

func _ready() -> void:
	add_to_group("player")
	collision_layer = 1
	collision_mask = 2 | 8 | 16
	Game.player = self
	body = Node2D.new()
	add_child(body)
	sprite = Sprite2D.new()
	sprite.texture = Art.player_ship_tex(Game.ship)
	body.add_child(sprite)
	flame = Sprite2D.new()
	flame.texture = Art.flame_tex()
	flame.modulate = Color(2.0, 2.0, 2.0)
	flame.position = Vector2(0, sprite.texture.get_height() * 0.8 + 4)
	body.add_child(flame)
	shield_spr = Sprite2D.new()
	shield_spr.texture = Art.shield_tex()
	shield_spr.modulate = Color(1.6, 1.6, 1.6)
	shield_spr.visible = false
	add_child(shield_spr)
	var sh := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 6.0
	sh.shape = c
	add_child(sh)
	joy_base = Sprite2D.new()
	joy_base.texture = Art.ring_tex(64)
	joy_base.scale = Vector2(0.7, 0.7)
	joy_base.visible = false
	joy_base.z_index = 30
	add_child(joy_base)
	joy_knob = Sprite2D.new()
	joy_knob.texture = Art.glow_tex(24)
	joy_knob.modulate = Color(1.6, 1.6, 1.6)
	joy_knob.visible = false
	joy_knob.z_index = 30
	add_child(joy_knob)
	position = Vector2(240, 620)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and event.index == 0:
			var w := get_viewport().get_visible_rect().size.x
			if event.position.x < w * 0.6:
				touch_id = event.index
				touch_center = event.position
				touch_dir = Vector2.ZERO
				joy_base.position = event.position
				joy_knob.position = event.position
				joy_base.visible = true
				joy_knob.visible = true
			else:
				bomb_requested.emit()
		elif not event.pressed and event.index == touch_id:
			touch_id = -1
			touch_dir = Vector2.ZERO
			joy_base.visible = false
			joy_knob.visible = false
	elif event is InputEventScreenDrag and event.index == touch_id:
		var d: Vector2 = event.position - touch_center
		touch_dir = (d / 60.0).limit_length(1.0)
		joy_knob.position = touch_center + touch_dir * 42.0

func _exit_tree() -> void:
	if Game.player == self:
		Game.player = null

func _process(dt: float) -> void:
	if not alive:
		return
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if touch_id != -1:
		dir = touch_dir
	position += dir * SPEED * dt
	position.x = clampf(position.x, BOUNDS.position.x, BOUNDS.end.x)
	position.y = clampf(position.y, BOUNDS.position.y, BOUNDS.end.y)
	var roll_amt := -dir.x
	body.scale.x = lerpf(body.scale.x, 1.0 - 0.25 * absf(roll_amt), minf(1.0, 10.0 * dt))
	if invincible > 0.0:
		invincible -= dt
		visible = int(invincible * 16.0) % 2 == 0
		if invincible <= 0.0:
			visible = true
	flame.scale.y = randf_range(0.75, 1.25)
	flame.scale.x = randf_range(0.9, 1.1)
	if shield:
		shield_spr.rotation += dt * 2.5
		shield_spr.modulate.a = 0.75 + sin(Time.get_ticks_msec() / 90.0) * 0.25
	if flash_t > 0.0:
		flash_t -= dt
		sprite.modulate = Color(3, 3, 3) if flash_t > 0.0 else Color(1, 1, 1)
	fire_t -= dt
	missile_t -= dt
	if fire_t <= 0.0:
		_fire()

func _fire() -> void:
	var lv := Game.weapon
	var top := position + Vector2(0, -20)
	match Game.ship:
		0:
			fire_t = 0.14
			var dmg := 10.0 * (1.0 + 0.12 * (lv - 1))
			if lv == 1:
				Pool.fire_player(top, Vector2(0, -540), dmg)
			elif lv == 2:
				Pool.fire_player(top + Vector2(-7, 0), Vector2(0, -540), dmg)
				Pool.fire_player(top + Vector2(7, 0), Vector2(0, -540), dmg)
			else:
				var count: int = [0, 0, 0, 3, 5, 7, 9][lv]
				var spread: float = [0.0, 0.0, 0.0, 8.0, 16.0, 24.0, 32.0][lv]
				for i in count:
					var ang := deg_to_rad(-90.0 + lerpf(-spread, spread, float(i) / maxf(1.0, count - 1.0)))
					Pool.fire_player(top, Vector2(cos(ang), sin(ang)) * 540.0, dmg)
			SFX.play("shoot0")
		1:
			fire_t = 0.11
			var dmg := 8.0 * (1.0 + 0.12 * (lv - 1))
			var count: int = [0, 2, 3, 4, 5, 6, 8][lv]
			var spacing := 11.0
			for i in count:
				var ox := (float(i) - (count - 1) * 0.5) * spacing
				Pool.fire_player(top + Vector2(ox, 0), Vector2(0, -580), dmg, "shot_space")
			SFX.play("shoot1")
		2:
			fire_t = 0.11
			var count: int = [0, 1, 2, 2, 3, 3, 3][lv]
			var dmg := 10.0 * (1.0 + 0.12 * (lv - 1))
			for i in count:
				var ox := (float(i) - (count - 1) * 0.5) * 11.0
				Pool.fire_player(top + Vector2(ox, 0), Vector2(0, -580), dmg, "shot_space")
			SFX.play("shoot1")
			if missile_t <= 0.0:
				missile_t = 0.7 if lv >= 6 else 1.0
				var m_count: int = [0, 1, 1, 2, 2, 3, 3][lv]
				var target := _nearest_enemy()
				var base_ang := -PI / 2.0
				if is_instance_valid(target):
					base_ang = (target.global_position - position).angle()
				for i in m_count:
					var spread := deg_to_rad(lerpf(-8.0, 8.0, float(i) / maxf(1.0, m_count - 1.0))) if m_count > 1 else 0.0
					var dir := Vector2(cos(base_ang + spread), sin(base_ang + spread))
					Pool.fire_player(position + dir * 10, dir * 340.0, 26.0 * (1.0 + 0.12 * (lv - 1)),
						"missile", {"homing": true, "turn": 3.0, "max_angle": 2.0, "radius": 5.0, "orient": true, "life": 5.0})
				SFX.play("shoot2")

func _nearest_enemy() -> Node2D:
	var best: Node2D = null
	var bd := INF
	for n in get_tree().get_nodes_in_group("damageable"):
		var d := position.distance_squared_to(n.global_position)
		if d < bd:
			bd = d
			best = n
	return best

func hit(source := "") -> void:
	if not alive or invincible > 0.0:
		return
	if shield:
		shield = false
		shield_spr.visible = false
		invincible = 1.0
		SFX.play("shield_break")
		FX.spark(position, Color(0.5, 0.9, 1.0))
		Ach.add_shield_block()
		return
	if source == "bomber":
		Ach.add_kamikaze()
	_die()

func _die() -> void:
	alive = false
	visible = false
	FX.explode(position, 1.8)
	FX.shake(10.0, 0.5)
	FX.slowmo(0.35, 0.5)
	SFX.play("die")
	died.emit()

func respawn() -> void:
	alive = true
	visible = true
	position = Vector2(240, 620)
	invincible = 5.0
	missile_t = 0.3
	Game.weapon = 1
	Game.weapon_changed.emit(1)

func add_shield() -> void:
	shield = true
	shield_spr.visible = true
	flash_t = 0.1
	SFX.play("shield_on")

func pickup_flash() -> void:
	flash_t = 0.12
