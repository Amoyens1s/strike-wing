extends Node2D

const RIGS := 8
const SPARKS := 12

var camera: Camera2D = null

var _rigs: Array = []
var _rig_idx := 0
var _sparks: Array = []
var _spark_idx := 0
var _flash_rect: ColorRect
var _shake := 0.0
var _shake_power := 0.0

func _ready() -> void:
	z_index = 20
	var glow: Texture2D = Art.glow_tex(32)
	var spark_tex: Texture2D = Art.spark_tex(9)
	for i in RIGS:
		_rigs.append(_make_rig(glow, spark_tex))
	for i in SPARKS:
		_sparks.append(_make_spark(spark_tex))
	var cl := CanvasLayer.new()
	cl.layer = 50
	add_child(cl)
	_flash_rect = ColorRect.new()
	_flash_rect.color = Color(1, 1, 1, 0)
	_flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(_flash_rect)

func _make_particles(tex: Texture2D, amount: int, lifetime: float, color: Color,
		vel_min: float, vel_max: float, scale_min: float, scale_max: float, additive := true) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.amount = amount
	p.lifetime = lifetime
	p.one_shot = true
	p.explosiveness = 0.9
	p.texture = tex
	p.spread = 180.0
	p.initial_velocity_min = vel_min
	p.initial_velocity_max = vel_max
	p.damping_min = 40.0
	p.damping_max = 120.0
	p.scale_amount_min = scale_min
	p.scale_amount_max = scale_max
	p.color = color
	p.emitting = false
	if additive:
		var mat := CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		p.material = mat
	return p

func _make_rig(glow: Texture2D, spark_tex: Texture2D) -> Node2D:
	var rig := Node2D.new()
	var flash := _make_particles(glow, 3, 0.18, Color(2.5, 2.5, 2.5), 0, 10, 3.0, 5.0)
	flash.name = "flash"
	var debris := _make_particles(spark_tex, 26, 0.55, Color(2.2, 1.1, 0.35), 60, 240, 1.2, 2.2)
	debris.name = "debris"
	var smoke := _make_particles(glow, 12, 0.8, Color(0.45, 0.45, 0.48, 0.6), 20, 70, 1.5, 3.0, false)
	smoke.name = "smoke"
	rig.add_child(flash)
	rig.add_child(debris)
	rig.add_child(smoke)
	add_child(rig)
	return rig

func _make_spark(tex: Texture2D) -> CPUParticles2D:
	var p := _make_particles(tex, 8, 0.3, Color(2.0, 2.0, 2.0), 40, 150, 0.8, 1.4)
	add_child(p)
	return p

func explode(pos: Vector2, size := 1.0) -> void:
	var rig: Node2D = _rigs[_rig_idx]
	_rig_idx = (_rig_idx + 1) % RIGS
	rig.global_position = pos
	rig.scale = Vector2(size, size)
	for p in rig.get_children():
		p.restart()

func spark(pos: Vector2, color: Color) -> void:
	var p: CPUParticles2D = _sparks[_spark_idx]
	_spark_idx = (_spark_idx + 1) % SPARKS
	p.global_position = pos
	p.color = color * 2.0
	p.restart()

func shake(power: float, dur := 0.3) -> void:
	_shake = dur
	_shake_power = power

func flash(color: Color, peak := 0.8, dur := 0.3) -> void:
	_flash_rect.color = Color(color.r, color.g, color.b, 0)
	var tw := create_tween()
	tw.tween_property(_flash_rect, "color:a", peak, dur * 0.3)
	tw.tween_property(_flash_rect, "color:a", 0.0, dur * 0.7)

func slowmo(scale: float, dur: float) -> void:
	if OS.get_cmdline_user_args().has("--turbo"):
		return
	Engine.time_scale = scale
	await get_tree().create_timer(dur, false).timeout
	Engine.time_scale = 1.0

func bomb_effect(pos: Vector2) -> void:
	flash(Color(1, 1, 1), 0.9, 0.4)
	shake(14.0, 0.5)
	var ring := Sprite2D.new()
	ring.texture = Art.ring_tex(64)
	ring.global_position = pos
	ring.modulate = Color(2.5, 2.2, 1.5)
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	ring.material = mat
	add_child(ring)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(ring, "scale", Vector2(16, 16), 0.55).from(Vector2(0.5, 0.5))
	tw.tween_property(ring, "modulate:a", 0.0, 0.55)
	tw.set_parallel(false)
	tw.tween_callback(ring.queue_free)

func _process(dt: float) -> void:
	if camera == null:
		return
	if _shake > 0.0:
		_shake -= dt
		var p := _shake_power * clampf(_shake * 4.0, 0.0, 1.0)
		camera.offset = Vector2(randf_range(-p, p), randf_range(-p, p))
	else:
		camera.offset = Vector2.ZERO
