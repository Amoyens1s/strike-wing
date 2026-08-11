class_name HUD
extends CanvasLayer

const RED := Color("ff5040")
const YELLOW := Color("ffd23c")
const CYAN := Color("5ad2ff")
const WHITE := Color("f0f0f0")
const GRAY := Color("8890a0")

var score_tr: TextureRect
var hi_tr: TextureRect
var stage_tr: Label
var lv_tr: Label
var lives_box: Node2D
var bombs_box: Node2D
var boss_bar: Node2D
var boss_fill: TextureRect
var banner: Node2D
var banner_main: Label
var banner_sub: Label
var warning_tr: Label
var warn_t := 0.0
var warning_on := false
var overlay: Node2D
var life_icon: Texture2D
var bomb_icon: Texture2D
var main: Main = null
var paused := false
var pause_root: Node2D
var pause_btn: TextureRect
var pause_resume_tr: Label
var pause_quit_tr: Label
var boss_intro: Node2D
var bomb_btn: Sprite2D

func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_add(Art.cn_label("得分", RED, 12, 1), 10, 3)
	score_tr = Art.make_label("0000000", YELLOW, 2)
	_add(score_tr, 40, 4)
	_add(Art.cn_label("最高", RED, 12, 1), 208, 3)
	hi_tr = Art.make_label("0000000", CYAN, 2)
	_add(hi_tr, 238, 4)
	stage_tr = Art.cn_label("第 1 关", WHITE, 12, 1)
	stage_tr.position = Vector2(480 - 8 - Art.cn_width("第 1 关", 12, 1), 3)
	add_child(stage_tr)
	lv_tr = Art.cn_label("等级 1", YELLOW, 12, 2)
	lv_tr.position = Vector2(240 - Art.cn_width("等级 1", 12, 2) / 2.0, 680)
	add_child(lv_tr)
	life_icon = Art.player_ship_tex(Game.ship)
	var li := life_icon.get_image()
	li.resize(16, maxi(8, int(16.0 * li.get_height() / li.get_width())))
	life_icon = ImageTexture.create_from_image(li)
	bomb_icon = Art.badge_tex("B")
	lives_box = Node2D.new()
	lives_box.position = Vector2(12, 690)
	add_child(lives_box)
	bombs_box = Node2D.new()
	bombs_box.position = Vector2(480 - 8 - 17, 692)
	add_child(bombs_box)
	_build_boss_bar()
	_build_banner()
	_build_pause()
	pause_btn = Art.make_label("II", CYAN, 2)
	pause_btn.position = Vector2(480 - 8 - 22, 8)
	pause_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(pause_btn)
	bomb_btn = Sprite2D.new()
	bomb_btn.texture = Art.badge_tex("B")
	bomb_btn.scale = Vector2(2.0, 2.0)
	bomb_btn.position = Vector2(434, 656)
	bomb_btn.z_index = 40
	add_child(bomb_btn)
	Game.score_changed.connect(_on_score)
	Game.lives_changed.connect(_on_lives)
	Game.bombs_changed.connect(_on_bombs)
	Game.weapon_changed.connect(_on_weapon)
	_on_score(Game.score)
	_on_lives(Game.lives)
	_on_bombs(Game.bombs)
	_on_weapon(Game.weapon)

func _add(c: CanvasItem, x: float, y: float) -> void:
	c.position = Vector2(x, y)
	add_child(c)

func _on_score(v: int) -> void:
	Art.set_label(score_tr, "%07d" % v, YELLOW, 2)
	Art.set_label(hi_tr, "%07d" % Data.hi, CYAN, 2)

func _on_lives(v: int) -> void:
	for c in lives_box.get_children():
		c.queue_free()
	for i in v:
		var tr := TextureRect.new()
		tr.texture = life_icon
		tr.position = Vector2(i * 20, 0)
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lives_box.add_child(tr)

func _on_bombs(v: int) -> void:
	for c in bombs_box.get_children():
		c.queue_free()
	for i in v:
		var tr := TextureRect.new()
		tr.texture = bomb_icon
		tr.scale = Vector2(0.6, 0.6)
		tr.position = Vector2(-i * 18, 0)
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bombs_box.add_child(tr)

func set_bomb_cd(on: bool) -> void:
	for c in bombs_box.get_children():
		c.modulate = Color(0.35, 0.35, 0.4, 0.6) if on else Color(1, 1, 1, 1)

func _on_weapon(v: int) -> void:
	Art.set_cn_label(lv_tr, "等级 %d" % v, YELLOW, 12, 2)

func set_stage(n: int) -> void:
	Art.set_cn_label(stage_tr, "第 %d 关" % n, WHITE, 12, 1)
	stage_tr.position = Vector2(480 - 8 - Art.cn_width("第 %d 关" % n, 12, 1), 3)

func _build_boss_bar() -> void:
	boss_bar = Node2D.new()
	boss_bar.visible = false
	add_child(boss_bar)
	var label := Art.cn_label("首领", RED, 12, 2)
	label.position = Vector2(44, 46)
	boss_bar.add_child(label)
	var border := Art.ui_bar_border(Vector2(308, 24), Color(0.95, 0.92, 1.0))
	border.position = Vector2(124, 40)
	boss_bar.add_child(border)
	boss_fill = Art.ui_bar_fill(Vector2(300, 14), Color(1.0, 0.32, 0.22))
	boss_fill.position = Vector2(128, 45)
	boss_bar.add_child(boss_fill)

func show_boss_bar(on: bool) -> void:
	boss_bar.visible = on

func update_boss_hp(cur: float, max_hp: float) -> void:
	boss_fill.scale.x = clampf(cur / max_hp, 0.0, 1.0)

func _build_banner() -> void:
	banner = Node2D.new()
	banner.visible = false
	add_child(banner)
	banner_main = Art.cn_label("", WHITE, 12, 3)
	banner.add_child(banner_main)
	banner_sub = Art.cn_label("", YELLOW, 12, 2)
	banner.add_child(banner_sub)
	warning_tr = Art.cn_label("警告", RED, 12, 4)
	warning_tr.position = Vector2(240 - Art.cn_width("警告", 12, 4) / 2.0, 300)
	warning_tr.visible = false
	add_child(warning_tr)

func show_banner(main_text: String, sub_text := "", color := WHITE, dur := 2.5,
		main_scale := 3, sub_scale := 2) -> void:
	Art.set_cn_label(banner_main, main_text, color, 12, main_scale)
	banner_main.position = Vector2(240 - Art.cn_width(main_text, 12, main_scale) / 2.0, 330 if sub_text != "" else 300)
	banner_sub.visible = sub_text != ""
	if sub_text != "":
		Art.set_cn_label(banner_sub, sub_text, YELLOW, 12, sub_scale)
		banner_sub.position = Vector2(240 - Art.cn_width(sub_text, 12, sub_scale) / 2.0, 270)
	banner.visible = true
	banner.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(banner, "modulate:a", 1.0, 0.25)
	tw.tween_interval(dur)
	tw.tween_property(banner, "modulate:a", 0.0, 0.4)
	tw.tween_callback(banner.hide)

func show_boss_intro(boss_name: String) -> void:
	if boss_intro == null:
		boss_intro = Node2D.new()
		add_child(boss_intro)
	for c in boss_intro.get_children():
		c.queue_free()
	var bg := Art.ui_panel(Vector2(420, 130), Color(0.05, 0.07, 0.13, 0.92))
	bg.position = Vector2(30, 195)
	boss_intro.add_child(bg)
	var top_line := ColorRect.new()
	top_line.color = Color("ffd23c")
	top_line.size = Vector2(420, 3)
	top_line.position = Vector2(30, 195)
	top_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_intro.add_child(top_line)
	var bottom_line := ColorRect.new()
	bottom_line.color = Color("ffd23c")
	bottom_line.size = Vector2(420, 3)
	bottom_line.position = Vector2(30, 322)
	bottom_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_intro.add_child(bottom_line)
	var title := Art.cn_label(boss_name, RED, 12, 6)
	title.reset_size()
	title.pivot_offset = title.size / 2.0
	title.position = Vector2(240 - Art.cn_width(boss_name, 12, 6) / 2.0, 205)
	boss_intro.add_child(title)
	var sub := Art.cn_label("首领登场", YELLOW, 12, 2)
	sub.reset_size()
	sub.pivot_offset = sub.size / 2.0
	sub.position = Vector2(240 - Art.cn_width("首领登场", 12, 2) / 2.0, 290)
	boss_intro.add_child(sub)
	boss_intro.visible = true
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(title, "scale", Vector2.ONE, 0.4).from(Vector2(0.2, 0.2)) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(sub, "scale", Vector2.ONE, 0.35).from(Vector2(0.4, 0.4)) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(boss_intro, "modulate:a", 1.0, 0.2).from(0.0)

func hide_boss_intro() -> void:
	if is_instance_valid(boss_intro):
		boss_intro.visible = false

func show_warning() -> void:
	warning_on = true
	warn_t = 0.0
	warning_tr.visible = true

func hide_warning() -> void:
	warning_on = false
	warning_tr.visible = false

func show_overlay(lines: Array) -> void:
	hide_overlay()
	overlay = Node2D.new()
	add_child(overlay)
	var panel := Art.ui_panel(Vector2(320, 340), Color(0.12, 0.16, 0.28, 0.82))
	panel.position = Vector2(80, 100)
	overlay.add_child(panel)
	var y := 130.0
	for line in lines:
		var scale: int = line.get("scale", 2)
		var tr := Art.cn_label(line["text"], line.get("color", WHITE), 12, scale)
		tr.position = Vector2(240 - Art.cn_width(line["text"], 12, scale) / 2.0, y)
		overlay.add_child(tr)
		y += 20 * scale

func hide_overlay() -> void:
	if is_instance_valid(overlay):
		overlay.queue_free()
	overlay = null

func _build_pause() -> void:
	pause_root = Node2D.new()
	pause_root.visible = false
	add_child(pause_root)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.62)
	dim.size = Vector2(480, 720)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_root.add_child(dim)
	var title := Art.cn_label("暂停", YELLOW, 12, 5)
	title.position = Vector2(240 - Art.cn_width("暂停", 12, 5) / 2.0, 200)
	pause_root.add_child(title)
	pause_resume_tr = Art.cn_label("继续游戏", CYAN, 12, 3)
	pause_resume_tr.position = Vector2(240 - Art.cn_width("继续游戏", 12, 3) / 2.0, 320)
	pause_root.add_child(pause_resume_tr)
	pause_quit_tr = Art.cn_label("返回主菜单", GRAY, 12, 2)
	pause_quit_tr.position = Vector2(240 - Art.cn_width("返回主菜单", 12, 2) / 2.0, 400)
	pause_root.add_child(pause_quit_tr)

func _set_pause(p: bool) -> void:
	if paused == p:
		return
	paused = p
	get_tree().paused = p
	pause_root.visible = p
	bomb_btn.visible = not p and main != null and main.player != null and main.player.alive
	BGM.set_paused(p)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if paused:
			if _in_rect(event.position, 140, 300, 200, 52):
				_set_pause(false)
			elif _in_rect(event.position, 140, 392, 200, 52):
				_set_pause(false)
				if main != null:
					main.exit_to_menu()
		elif main != null and main.can_pause() and _in_rect(event.position, 440, 0, 40, 32):
			_set_pause(true)
		return
	if event.is_action_pressed("ui_cancel"):
		if paused:
			_set_pause(false)
		elif main != null and main.can_pause():
			_set_pause(true)
	elif paused and event.is_action_pressed("ui_accept"):
		_set_pause(false)
		main.exit_to_menu()

func _in_rect(pos: Vector2, x: float, y: float, w: float, h: float) -> bool:
	return pos.x >= x and pos.x <= x + w and pos.y >= y and pos.y <= y + h

func _process(dt: float) -> void:
	if warning_on:
		warn_t += dt
		warning_tr.visible = int(warn_t * 5.0) % 2 == 0
	if bomb_btn != null and main != null and main.player != null:
		bomb_btn.visible = main.player.alive
