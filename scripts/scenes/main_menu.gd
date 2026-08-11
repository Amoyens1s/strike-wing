class_name MainMenu
extends Node2D

const YELLOW := Color("ffd23c")
const RED := Color("ff5040")
const CYAN := Color("5ad2ff")
const WHITE := Color("f0f0f0")
const GRAY := Color("8890a0")

const MENU_ITEMS := ["开始游戏", "战机选择", "敌人图鉴", "成就", "历史记录"]
const ACH_PER_PAGE := 8
const SHIP_DESC := {
	0: ["直线弹散射", "清屏炸弹保命", "均衡易上手"],
	1: ["密集平行弹道", "全弹齐射高伤爆发", "正面压制型"],
	2: ["平行弹道最高 3 发", "追踪飞弹+导弹雨", "飞弹偏离超限会脱靶"],
}
const BESTIARY := [
	{"type": "drone", "name": "无人机", "desc": ["快速直线俯冲的小型机", "会瞄准玩家射击"],
		"drops": "火力(P) 8%", "extra": true},
	{"type": "weaver", "name": "蛇形机", "desc": ["蛇形摆动前进", "双发瞄准射击"],
		"drops": "火力(P) 8%", "extra": true},
	{"type": "diver", "name": "俯冲机", "desc": ["高速俯冲撞击玩家", "自身不射击"],
		"drops": "火力(P) 8%", "extra": true},
	{"type": "gunship", "name": "炮艇", "desc": ["悬停横移的炮台", "扇形弹幕，装甲较厚"],
		"drops": "火力(P) 25%   护盾(S) 5%", "extra": false},
	{"type": "tank", "name": "重甲", "desc": ["缓慢推进的堡垒", "环形弹幕，装甲厚重"],
		"drops": "火力(P) 50%   护盾(S) 10%", "extra": false},
	{"type": "spinner", "name": "旋转炮台", "desc": ["悬停旋转发射环形弹幕", "高血量，中坚火力"],
		"drops": "火力(P) 8%", "extra": true},
	{"type": "shooter", "name": "连射兵", "desc": ["高速俯冲连射弹幕", "弹速极快"],
		"drops": "火力(P) 8%", "extra": true},
	{"type": "burst", "name": "扇形炮", "desc": ["从侧翼滑入悬停", "扇形弹幕扫射"],
		"drops": "火力(P) 8%", "extra": true},
	{"type": "bomber", "name": "自爆机", "desc": ["高速冲向玩家", "近身环形爆破"],
		"drops": "火力(P) 8%", "extra": true},
]

enum Screen { MENU, SELECT, BESTIARY, ACHIEVEMENTS, RECORDS }

var screen := Screen.MENU
var menu_idx := 0
var ship_idx := 0
var bestiary_idx := 0
var ach_page := 0
var menu_root: Node2D
var select_root: Node2D
var bestiary_root: Node2D
var ach_root: Node2D
var ach_list: Node2D
var ach_progress: Label
var ach_hint: Label
var records_root: Node2D
var items: Array = []
var cursor: TextureRect
var ship_sprite: Sprite2D
var ship_name_tr: Label
var ship_desc_trs: Array = []
var bestiary_items: Array = []
var bestiary_cursor: TextureRect
var bestiary_sprite: Sprite2D
var bestiary_name_tr: Label
var bestiary_desc_trs: Array = []
var bestiary_drop_tr: Label
var bestiary_extra_tr: Label

func _ready() -> void:
	Pool.reset()
	BGM.play_track("menu")
	var bg := Background.new()
	add_child(bg)
	bg.set_theme("space")
	menu_root = Node2D.new()
	add_child(menu_root)
	_add(menu_root, Art.cn_label("雷霆突袭", YELLOW, 12, 5), 240 - Art.cn_width("雷霆突袭", 12, 5) / 2.0, 70)
	_add(menu_root, Art.cn_label("垂直弹幕突击", CYAN, 12, 2), 240 - Art.cn_width("垂直弹幕突击", 12, 2) / 2.0, 165)
	for i in MENU_ITEMS.size():
		var tr := Art.cn_label(MENU_ITEMS[i], WHITE, 12, 2)
		_add(menu_root, tr, 240 - Art.cn_width(MENU_ITEMS[i], 12, 2) / 2.0, 300 + i * 40)
		items.append(tr)
	cursor = Art.make_label(">", YELLOW, 2)
	menu_root.add_child(cursor)
	_add(menu_root, Art.cn_label("最高分 %07d" % Data.hi, RED, 12, 2),
		240 - Art.cn_width("最高分 %07d" % Data.hi, 12, 2) / 2.0, 540)
	_add(menu_root, Art.cn_label("WASD/方向键 选择   回车 确认", GRAY, 12, 1),
		240 - Art.cn_width("WASD/方向键 选择   回车 确认", 12, 1) / 2.0, 690)
	_build_select()
	_build_bestiary()
	_build_achievements()
	_build_records()
	_update_cursor()

func _add(parent: Node, c: CanvasItem, x: float, y: float) -> void:
	c.position = Vector2(x, y)
	parent.add_child(c)

func _build_select() -> void:
	select_root = Node2D.new()
	select_root.visible = false
	add_child(select_root)
	_add(select_root, Art.cn_label("选择战机", YELLOW, 12, 3), 240 - Art.cn_width("选择战机", 12, 3) / 2.0, 46)
	var select_panel := Art.ui_panel(Vector2(280, 210), Color(0.14, 0.18, 0.32, 0.62))
	select_panel.position = Vector2(100, 365)
	select_root.add_child(select_panel)
	ship_sprite = Sprite2D.new()
	ship_sprite.scale = Vector2(2, 2)
	ship_sprite.position = Vector2(240, 230)
	select_root.add_child(ship_sprite)
	ship_name_tr = Art.cn_label("", YELLOW, 12, 4)
	select_root.add_child(ship_name_tr)
	for i in 3:
		var tr := Art.cn_label("", WHITE, 12, 2)
		select_root.add_child(tr)
		ship_desc_trs.append(tr)
	_add(select_root, Art.cn_label("左右方向键 切换战机", CYAN, 12, 2),
		240 - Art.cn_width("左右方向键 切换战机", 12, 2) / 2.0, 600)
	_add(select_root, Art.cn_label("回车 出击    ESC 返回", GRAY, 12, 1),
		240 - Art.cn_width("回车 出击    ESC 返回", 12, 1) / 2.0, 688)

func _build_bestiary() -> void:
	bestiary_root = Node2D.new()
	bestiary_root.visible = false
	add_child(bestiary_root)
	_add(bestiary_root, Art.cn_label("敌人图鉴", YELLOW, 12, 3), 240 - Art.cn_width("敌人图鉴", 12, 3) / 2.0, 46)
	for i in BESTIARY.size():
		var e: Dictionary = BESTIARY[i]
		var icon := Sprite2D.new()
		icon.texture = Art.enemy_tex(e["type"], 1)
		icon.scale = Vector2(0.5, 0.5)
		icon.position = Vector2(66, 118 + i * 52)
		bestiary_root.add_child(icon)
		var name_tr := Art.cn_label(e["name"], WHITE, 12, 2)
		name_tr.position = Vector2(90, 104 + i * 52)
		bestiary_root.add_child(name_tr)
		bestiary_items.append(name_tr)
	bestiary_cursor = Art.make_label(">", YELLOW, 2)
	bestiary_cursor.position = Vector2(44, 107)
	bestiary_root.add_child(bestiary_cursor)
	var detail := Node2D.new()
	detail.position = Vector2(240, 0)
	bestiary_root.add_child(detail)
	var detail_panel := Art.ui_panel(Vector2(210, 360), Color(0.14, 0.18, 0.32, 0.62))
	detail_panel.position = Vector2(-105, 90)
	detail.add_child(detail_panel)
	bestiary_sprite = Sprite2D.new()
	bestiary_sprite.position = Vector2(0, 150)
	bestiary_sprite.scale = Vector2(2, 2)
	detail.add_child(bestiary_sprite)
	bestiary_name_tr = Art.cn_label("", YELLOW, 12, 3)
	bestiary_name_tr.position = Vector2(-Art.cn_width("炮艇", 12, 3) / 2.0, 250)
	detail.add_child(bestiary_name_tr)
	for i in 2:
		var tr := Art.cn_label("", WHITE, 12, 2)
		tr.position = Vector2(-200, 300 + i * 30)
		detail.add_child(tr)
		bestiary_desc_trs.append(tr)
	bestiary_drop_tr = Art.cn_label("", CYAN, 12, 2)
	bestiary_drop_tr.position = Vector2(-200, 370)
	detail.add_child(bestiary_drop_tr)
	bestiary_extra_tr = Art.cn_label("", GRAY, 12, 1)
	bestiary_extra_tr.position = Vector2(-200, 640)
	detail.add_child(bestiary_extra_tr)
	_update_bestiary_view()

func _update_bestiary_view() -> void:
	for i in bestiary_items.size():
		Art.set_cn_label(bestiary_items[i], BESTIARY[i]["name"], YELLOW if i == bestiary_idx else WHITE, 12, 2)
	bestiary_cursor.position = Vector2(44, 107 + bestiary_idx * 52)
	var e: Dictionary = BESTIARY[bestiary_idx]
	bestiary_sprite.texture = Art.enemy_tex(e["type"], 1)
	Art.set_cn_label(bestiary_name_tr, e["name"], YELLOW, 12, 3)
	bestiary_name_tr.position = Vector2(-Art.cn_width(e["name"], 12, 3) / 2.0, 250)
	for i in 2:
		var line: String = e["desc"][i]
		Art.set_cn_label(bestiary_desc_trs[i], line, WHITE, 12, 2)
		bestiary_desc_trs[i].position = Vector2(-Art.cn_width(line, 12, 2) / 2.0, 310 + i * 32)
	Art.set_cn_label(bestiary_drop_tr, "掉落：" + e["drops"], CYAN, 12, 2)
	bestiary_drop_tr.position = Vector2(-Art.cn_width("掉落：" + e["drops"], 12, 2) / 2.0, 390)
	if e.get("extra", false):
		Art.set_cn_label(bestiary_extra_tr, "另有：支援(B) 1.3%   命(1UP) 0.4%", GRAY, 12, 1)
	else:
		Art.set_cn_label(bestiary_extra_tr, "", GRAY, 12, 1)

func _build_achievements() -> void:
	ach_root = Node2D.new()
	ach_root.visible = false
	add_child(ach_root)
	_add(ach_root, Art.cn_label("成就", YELLOW, 12, 3), 240 - Art.cn_width("成就", 12, 3) / 2.0, 46)
	ach_progress = Art.cn_label("", RED, 12, 2)
	ach_progress.position = Vector2(240 - Art.cn_width("已解锁 0 / 26", 12, 2) / 2.0, 92)
	ach_root.add_child(ach_progress)
	var panel := Art.ui_panel(Vector2(440, 500), Color(0.14, 0.18, 0.32, 0.62))
	panel.position = Vector2(20, 130)
	ach_root.add_child(panel)
	ach_list = Node2D.new()
	ach_root.add_child(ach_list)
	ach_hint = Art.cn_label("", GRAY, 12, 1)
	ach_hint.position = Vector2(240 - Art.cn_width("左右翻页   回车 返回", 12, 1) / 2.0, 640)
	ach_root.add_child(ach_hint)
	_update_achievements()

func _update_achievements() -> void:
	for c in ach_list.get_children():
		c.queue_free()
	var total := Ach.ACH.size()
	var unlocked := Ach.achieved.size()
	Art.set_cn_label(ach_progress, "已解锁 %d / %d" % [unlocked, total], RED, 12, 2)
	ach_progress.position = Vector2(240 - Art.cn_width("已解锁 %d / %d" % [unlocked, total], 12, 2) / 2.0, 92)
	var page_count := ceili(float(total) / ACH_PER_PAGE)
	ach_page = clampi(ach_page, 0, page_count - 1)
	Art.set_cn_label(ach_hint, "第 %d / %d 页   左右翻页   回车 返回" % [ach_page + 1, page_count], GRAY, 12, 1)
	ach_hint.position = Vector2(240 - Art.cn_width("第 %d / %d 页   左右翻页   回车 返回" % [ach_page + 1, page_count], 12, 1) / 2.0, 640)
	for i in ACH_PER_PAGE:
		var idx := ach_page * ACH_PER_PAGE + i
		if idx >= total:
			break
		var a: Dictionary = Ach.ACH[idx]
		var got: bool = Ach.achieved.has(a["id"])
		var row := Node2D.new()
		row.position = Vector2(30, 140 + i * 58)
		ach_list.add_child(row)
		var icon_bg := Art.ui_panel(Vector2(40, 40), Color(a["color"]).darkened(0.4) if got else Color(0.25, 0.28, 0.34))
		icon_bg.position = Vector2.ZERO
		row.add_child(icon_bg)
		var icon := Art.cn_label(a["icon"], Color(1, 1, 1) if got else Color(0.5, 0.52, 0.58), 12, 2)
		icon.position = Vector2(20 - Art.cn_width(a["icon"], 12, 2) / 2.0, (40 - 24) / 2.0)
		row.add_child(icon)
		var name_label := Art.cn_label(a["name"], YELLOW if got else Color(0.5, 0.52, 0.58), 12, 1.5)
		name_label.position = Vector2(52, 2)
		row.add_child(name_label)
		var desc_label := Art.cn_label(a["desc"], WHITE if got else Color(0.42, 0.44, 0.5), 12, 1.5)
		desc_label.position = Vector2(52, 24)
		row.add_child(desc_label)

func _build_records() -> void:
	records_root = Node2D.new()
	records_root.visible = false
	add_child(records_root)
	_add(records_root, Art.cn_label("历史记录", YELLOW, 12, 3), 240 - Art.cn_width("历史记录", 12, 3) / 2.0, 50)
	_add(records_root, Art.cn_label("最高分 %07d" % Data.hi, RED, 12, 2),
		240 - Art.cn_width("最高分 %07d" % Data.hi, 12, 2) / 2.0, 100)
	var records_panel := Art.ui_panel(Vector2(440, 350), Color(0.14, 0.18, 0.32, 0.62))
	records_panel.position = Vector2(20, 140)
	records_root.add_child(records_panel)
	if Data.runs.is_empty():
		_add(records_root, Art.cn_label("暂无记录", GRAY, 12, 2), 240 - Art.cn_width("暂无记录", 12, 2) / 2.0, 200)
	else:
		_add(records_root, Art.cn_label("序号  得分   关卡 战机  用时  结果", CYAN, 12, 1), 34, 150)
		for i in mini(10, Data.runs.size()):
			var r: Dictionary = Data.runs[i]
			var line := "%02d  %07d  第%d关  %s  %d秒  %s" % [
				i + 1, int(r.get("score", 0)), int(r.get("stage", 1)),
				String(r.get("ship", "?")), int(r.get("time", 0)),
				"通关" if r.get("clear", false) else "阵亡"]
			_add(records_root, Art.cn_label(line, WHITE, 12, 1), 34, 180 + i * 26)
	_add(records_root, Art.cn_label("回车 返回", GRAY, 12, 1), 240 - Art.cn_width("回车 返回", 12, 1) / 2.0, 690)

func _update_cursor() -> void:
	for i in items.size():
		Art.set_cn_label(items[i], MENU_ITEMS[i], YELLOW if i == menu_idx else WHITE, 12, 2)
	cursor.position = Vector2(240 - Art.cn_width(MENU_ITEMS[0], 12, 2) / 2.0 - 28, 300 + menu_idx * 40 + 9)

func _update_ship_view() -> void:
	ship_sprite.texture = Art.player_ship_tex(ship_idx)
	var ship_name: String = Game.SHIP_NAMES[ship_idx]
	Art.set_cn_label(ship_name_tr, ship_name, YELLOW, 12, 4)
	ship_name_tr.position = Vector2(240 - Art.cn_width(ship_name, 12, 4) / 2.0, 380)
	for i in 3:
		var line: String = SHIP_DESC[ship_idx][i]
		Art.set_cn_label(ship_desc_trs[i], line, WHITE, 12, 2)
		ship_desc_trs[i].position = Vector2(240 - Art.cn_width(line, 12, 2) / 2.0, 470 + i * 32)

func _unhandled_input(event: InputEvent) -> void:
	match screen:
		Screen.MENU:
			if event.is_action_pressed("ui_up"):
				menu_idx = (menu_idx + MENU_ITEMS.size() - 1) % MENU_ITEMS.size()
				SFX.play("ui_move")
				_update_cursor()
			elif event.is_action_pressed("ui_down"):
				menu_idx = (menu_idx + 1) % MENU_ITEMS.size()
				SFX.play("ui_move")
				_update_cursor()
			elif event.is_action_pressed("ui_accept"):
				SFX.play("ui_ok")
				match menu_idx:
					0, 1:
						ship_idx = 0
						_update_ship_view()
						_switch(Screen.SELECT)
					2:
						_switch(Screen.BESTIARY)
					3:
						_switch(Screen.ACHIEVEMENTS)
					4:
						_switch(Screen.RECORDS)
		Screen.ACHIEVEMENTS:
			if event.is_action_pressed("ui_left"):
				ach_page -= 1
				SFX.play("ui_move")
				_update_achievements()
			elif event.is_action_pressed("ui_right"):
				ach_page += 1
				SFX.play("ui_move")
				_update_achievements()
			elif event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
				SFX.play("ui_move")
				_switch(Screen.MENU)
		Screen.BESTIARY:
			if event.is_action_pressed("ui_up"):
				bestiary_idx = (bestiary_idx + BESTIARY.size() - 1) % BESTIARY.size()
				SFX.play("ui_move")
				_update_bestiary_view()
			elif event.is_action_pressed("ui_down"):
				bestiary_idx = (bestiary_idx + 1) % BESTIARY.size()
				SFX.play("ui_move")
				_update_bestiary_view()
			elif event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
				SFX.play("ui_move")
				_switch(Screen.MENU)
		Screen.SELECT:
			if event.is_action_pressed("ui_left"):
				ship_idx = (ship_idx + 2) % 3
				SFX.play("ui_move")
				_update_ship_view()
			elif event.is_action_pressed("ui_right"):
				ship_idx = (ship_idx + 1) % 3
				SFX.play("ui_move")
				_update_ship_view()
			elif event.is_action_pressed("ui_accept"):
				SFX.play("ui_ok")
				Game.start_run(ship_idx)
				get_tree().change_scene_to_file("res://scenes/main.tscn")
			elif event.is_action_pressed("ui_cancel"):
				SFX.play("ui_move")
				_switch(Screen.MENU)
		Screen.RECORDS:
			if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
				SFX.play("ui_move")
				_switch(Screen.MENU)

func _switch(to: Screen) -> void:
	screen = to
	menu_root.visible = to == Screen.MENU
	select_root.visible = to == Screen.SELECT
	bestiary_root.visible = to == Screen.BESTIARY
	ach_root.visible = to == Screen.ACHIEVEMENTS
	records_root.visible = to == Screen.RECORDS

var preview_t := 0.0

func _process(dt: float) -> void:
	if screen != Screen.SELECT:
		return
	preview_t -= dt
	if preview_t <= 0.0:
		preview_t = 0.18
		_preview_fire()

func _preview_fire() -> void:
	var pos := ship_sprite.global_position + Vector2(0, -ship_sprite.texture.get_height() * 1.5)
	var lv := 3
	match ship_idx:
		0:
			var dmg := 10.0 * (1.0 + 0.12 * (lv - 1))
			for i in 5:
				var ang := deg_to_rad(-90.0 + lerpf(-16.0, 16.0, float(i) / 4.0))
				Pool.fire_player(pos, Vector2(cos(ang), sin(ang)) * 540.0, dmg)
			SFX.play("shoot0")
		1:
			var dmg := 8.0 * (1.0 + 0.12 * (lv - 1))
			for i in 3:
				var ox := (float(i) - 1.0) * 11.0
				Pool.fire_player(pos + Vector2(ox, 0), Vector2(0, -580), dmg, "shot_space")
			SFX.play("shoot1")
		2:
			var dmg := 10.0 * (1.0 + 0.12 * (lv - 1))
			for i in 2:
				var ox := (float(i) - 0.5) * 11.0
				Pool.fire_player(pos + Vector2(ox, 0), Vector2(0, -580), dmg, "shot_space")
			SFX.play("shoot1")
			for i in 2:
				var spread := deg_to_rad(lerpf(-8.0, 8.0, float(i)))
				var dir := Vector2(cos(-PI / 2.0 + spread), sin(-PI / 2.0 + spread))
				Pool.fire_player(pos + dir * 10, dir * 340.0, 26.0, "missile",
					{"homing": true, "turn": 3.0, "max_angle": 2.0, "radius": 5.0, "orient": true, "life": 5.0})
			SFX.play("shoot2")
