class_name Bullet
extends Area2D

var vel := Vector2.ZERO
var dmg := 10.0
var side := 0
var homing := false
var homing_t := 0.0
var turn := 5.0
var max_angle := PI
var speed := 0.0
var life := 6.0
var spin := 0.0
var target: Node2D = null
var source := ""
var sprite: Sprite2D
var shape_node: CollisionShape2D

func _ready() -> void:
	sprite = Sprite2D.new()
	add_child(sprite)
	shape_node = CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 4.0
	shape_node.shape = c
	add_child(shape_node)
	area_entered.connect(_on_area)
	monitorable = false
	set_process(false)

func activate(pos: Vector2, p_vel: Vector2, p_dmg: float, p_side: int, tex: Texture2D, opts := {}) -> void:
	position = pos
	vel = p_vel
	dmg = p_dmg
	side = p_side
	sprite.texture = tex
	sprite.modulate = Color(2.2, 2.2, 2.2)
	homing = opts.get("homing", false)
	turn = opts.get("turn", 5.0)
	max_angle = opts.get("max_angle", PI)
	homing_t = opts.get("homing_t", 0.0)
	spin = opts.get("spin", 0.0)
	life = opts.get("life", 6.0)
	source = str(opts.get("source", ""))
	speed = vel.length()
	sprite.rotation = vel.angle() + PI / 2.0 if opts.get("orient", false) else 0.0
	collision_layer = 4 if side == 0 else 8
	collision_mask = 2 if side == 0 else 1
	(shape_node.shape as CircleShape2D).radius = opts.get("radius", 4.0)
	target = null
	if homing and side == 0:
		target = _nearest_damageable()
	visible = true
	set_deferred("monitoring", true)
	set_process(true)

func _process(dt: float) -> void:
	if homing:
		if side == 1:
			homing_t -= dt
			if homing_t <= 0.0:
				homing = false
			target = Game.player
		if is_instance_valid(target):
			var want := (target.global_position - global_position).angle()
			var cur := vel.angle()
			var d := wrapf(want - cur, -PI, PI)
			if absf(d) > max_angle:
				homing = false
			else:
				var a := cur + clampf(d, -turn * dt, turn * dt)
				vel = Vector2(cos(a), sin(a)) * speed
				sprite.rotation = a + PI / 2.0
	if spin != 0.0:
		sprite.rotation += spin * dt
	position += vel * dt
	life -= dt
	if life <= 0.0 or position.y < -60 or position.y > 780 or position.x < -60 or position.x > 540:
		Pool.release(self)

func _nearest_damageable() -> Node2D:
	var best: Node2D = null
	var best_d := INF
	for n in get_tree().get_nodes_in_group("damageable"):
		var d := global_position.distance_squared_to(n.global_position)
		if d < best_d:
			best_d = d
			best = n
	return best

func _on_area(area: Area2D) -> void:
	if side == 0:
		if area.is_in_group("damageable"):
			area.take_damage(dmg)
			FX.spark(global_position, Color(1.0, 0.85, 0.4))
			Pool.release(self)
	else:
		if area.is_in_group("player"):
			area.hit(source)
			Pool.release(self)
