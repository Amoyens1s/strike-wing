class_name Pickup
extends Area2D

var type := "P"
var t := 0.0
var base_x := 0.0
var life := 12.0
var sprite: Sprite2D

func setup(p_type: String, pos: Vector2) -> void:
	type = p_type
	position = pos
	base_x = pos.x

func _ready() -> void:
	add_to_group("pickup")
	collision_layer = 16
	collision_mask = 1
	sprite = Sprite2D.new()
	sprite.texture = Art.badge_tex(type)
	sprite.modulate = Color(1.8, 1.8, 1.8)
	add_child(sprite)
	var sh := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 13.0
	sh.shape = c
	add_child(sh)
	area_entered.connect(_on_area)

func _process(dt: float) -> void:
	t += dt
	life -= dt
	position.y += 50.0 * dt
	position.x = base_x + sin(t * 2.5) * 24.0
	sprite.scale = Vector2.ONE * (1.0 + sin(t * 6.0) * 0.08)
	if life < 2.0:
		visible = int(life * 8.0) % 2 == 0
	if life <= 0.0 or position.y > 750.0:
		queue_free()

func _on_area(area: Area2D) -> void:
	if not area.is_in_group("player"):
		return
	var p := area as Player
	match type:
		"P":
			if Game.weapon < Game.MAX_WEAPON:
				Game.add_weapon(1)
				SFX.play("powerup")
				Game.add_score(300)
			else:
				SFX.play("pickup")
				Game.add_score(1500)
		"S":
			if p.shield:
				SFX.play("pickup")
				Game.add_score(1000)
			else:
				p.add_shield()
				SFX.play("shield_on")
				Game.add_score(300)
		"B":
			if Game.bombs >= Game.MAX_BOMBS:
				SFX.play("pickup")
				Game.add_score(1000)
			else:
				Game.add_bombs(1)
				SFX.play("pickup")
				Game.add_score(300)
		"1UP":
			if Game.lives >= Game.MAX_LIVES:
				SFX.play("pickup")
				Game.add_score(1500)
			else:
				Game.add_lives(1)
				SFX.play("1up")
				Game.add_score(500)
	Ach.add_pickup(type)
	p.pickup_flash()
	FX.spark(position, Color("ffd23c"))
	queue_free()
