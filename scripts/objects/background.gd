class_name Background
extends Node2D

const TILE_H := 512
const SPRITES_PER_LAYER := 3
const SPEEDS := [26.0, 60.0, 130.0]

var layers: Array = []
var offsets := [0.0, 0.0, 0.0]
var star_layer: Node2D
var stars: Array = []
var star_t := 0.0

func _ready() -> void:
	z_index = -10
	if layers.is_empty():
		_build_layers()
	star_layer = Node2D.new()
	add_child(star_layer)

func _build_layers() -> void:
	for i in 3:
		var node := Node2D.new()
		add_child(node)
		var sprites := []
		for j in SPRITES_PER_LAYER:
			var s := Sprite2D.new()
			s.centered = false
			s.scale = Vector2(2, 2)
			node.add_child(s)
			sprites.append(s)
		layers.append(sprites)

func set_theme(theme: String) -> void:
	if layers.is_empty():
		_build_layers()
	for i in 3:
		var tex := Art.bg_tile(theme, i, randi())
		for s in layers[i]:
			s.texture = tex
	star_layer.visible = theme == "space"
	_setup_stars()

func _setup_stars() -> void:
	for c in star_layer.get_children():
		c.queue_free()
	stars.clear()
	for i in 64:
		var fast := i >= 40
		var sp := Sprite2D.new()
		sp.texture = Art.glow_tex(8)
		var tint := Color(1, 1, 1)
		var r := randf()
		if r < 0.15:
			tint = Color(0.7, 0.85, 1.0)
		elif r < 0.3:
			tint = Color(1.0, 0.95, 0.8)
		sp.modulate = tint * 1.8
		sp.scale = Vector2.ONE * (randf_range(1.6, 2.6) if fast else randf_range(0.7, 1.4))
		sp.position = Vector2(randf_range(0, 480), randf_range(0, 720))
		star_layer.add_child(sp)
		stars.append({
			"sprite": sp,
			"speed": randf_range(34, 58) if fast else randf_range(8, 18),
			"freq": randf_range(1.5, 4.0),
			"phase": randf() * TAU,
		})

func _process(dt: float) -> void:
	for i in 3:
		offsets[i] += SPEEDS[i] * dt
		var span := float(TILE_H * SPRITES_PER_LAYER)
		for j in SPRITES_PER_LAYER:
			var y := fposmod(offsets[i] + j * TILE_H, span) - TILE_H
			layers[i][j].position = Vector2(0, y)
	star_t += dt
	for s in stars:
		var sp: Sprite2D = s["sprite"]
		sp.position.y += s["speed"] * dt
		if sp.position.y > 740:
			sp.position.y = -20
			sp.position.x = randf_range(0, 480)
		var a := 0.35 + 0.55 * (0.5 + 0.5 * sin(star_t * s["freq"] + s["phase"]))
		sp.modulate.a = a
