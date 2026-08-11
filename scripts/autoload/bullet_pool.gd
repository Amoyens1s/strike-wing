extends Node2D

const PLAYER_PREALLOC := 200
const ENEMY_PREALLOC := 400

var tex := {}
var _player_free: Array = []
var _enemy_free: Array = []
var _player_layer: Node2D
var _enemy_layer: Node2D

func _ready() -> void:
	z_index = 6
	for kind in ["shot", "shot_space", "missile", "orb", "orb_big", "diamond", "dot", "bolt"]:
		tex[kind] = Art.bullet_tex(kind)
	_player_layer = Node2D.new()
	add_child(_player_layer)
	_enemy_layer = Node2D.new()
	add_child(_enemy_layer)
	for i in PLAYER_PREALLOC:
		_player_free.append(_make_bullet(_player_layer))
	for i in ENEMY_PREALLOC:
		_enemy_free.append(_make_bullet(_enemy_layer))

func _make_bullet(parent: Node) -> Bullet:
	var b := Bullet.new()
	b.visible = false
	b.monitoring = false
	parent.add_child(b)
	return b

func fire_player(pos: Vector2, vel: Vector2, dmg: float, kind := "shot", opts := {}) -> void:
	if _player_free.is_empty():
		_player_free.append(_make_bullet(_player_layer))
	var b: Bullet = _player_free.pop_back()
	b.activate(pos, vel, dmg, 0, tex[kind], opts)

func fire_enemy(pos: Vector2, vel: Vector2, dmg: float, kind := "orb", opts := {}) -> void:
	if _enemy_free.is_empty():
		_enemy_free.append(_make_bullet(_enemy_layer))
	var b: Bullet = _enemy_free.pop_back()
	b.activate(pos, vel, dmg, 1, tex[kind], opts)

func release(b: Bullet) -> void:
	if not b.visible:
		return
	b.visible = false
	b.set_deferred("monitoring", false)
	b.set_process(false)
	if b.side == 0:
		_player_free.append(b)
	else:
		_enemy_free.append(b)

func clear_enemy_bullets(with_fx := true) -> int:
	var count := 0
	for b in _enemy_layer.get_children():
		if b.visible:
			count += 1
			if with_fx:
				FX.spark(b.global_position, Color("ff44aa"))
			release(b)
	return count

func reset() -> void:
	for layer in [_player_layer, _enemy_layer]:
		for b in layer.get_children():
			release(b)
