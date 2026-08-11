extends Node

const ACH := [
	{"id": "gipsy_danger", "name": "危险流浪者", "desc": "流浪者无伤通过第 1 关", "icon": "危", "color": Color("4a7dff")},
	{"id": "desert_fox", "name": "沙漠飞狐", "desc": "无伤通过第 2 关", "icon": "狐", "color": Color("4a7dff")},
	{"id": "fish_in_water", "name": "如鱼得水", "desc": "无伤通过第 3 关", "icon": "鱼", "color": Color("4a7dff")},
	{"id": "one_vs_thousand", "name": "一骑当千", "desc": "无伤通过第 10 关", "icon": "千", "color": Color("4a7dff")},
	{"id": "mission_complete", "name": "任务完成", "desc": "通关全部 10 关", "icon": "完", "color": Color("4a7dff")},
	{"id": "zero_damage", "name": "零损伤", "desc": "全程无伤通关", "icon": "零", "color": Color("4a7dff")},
	{"id": "first_blood", "name": "第一滴血", "desc": "首杀敌机", "icon": "血", "color": Color("e03030")},
	{"id": "thousand_kills", "name": "千人斩", "desc": "累计击杀 1000 敌机", "icon": "千", "color": Color("e03030")},
	{"id": "pokemon_master", "name": "宝可梦大师", "desc": "击杀全部 9 种敌型", "icon": "梦", "color": Color("e03030")},
	{"id": "tiger_tank", "name": "虎式坦克", "desc": "累计击杀 50 个重甲", "icon": "虎", "color": Color("e03030")},
	{"id": "hunt_begin", "name": "讨伐开始", "desc": "首杀 Boss", "icon": "伐", "color": Color("e03030")},
	{"id": "red_cliff", "name": "火烧赤壁", "desc": "炸弹一次击杀 10 个以上敌人", "icon": "火", "color": Color("e03030")},
	{"id": "continue_coin", "name": "Continue?", "desc": "首次阵亡", "icon": "C", "color": Color("8890a0")},
	{"id": "habit_crash", "name": "习惯性坠机", "desc": "累计阵亡 50 次", "icon": "坠", "color": Color("8890a0")},
	{"id": "kamikaze_death", "name": "殉爆同归", "desc": "被自爆机炸死", "icon": "爆", "color": Color("8890a0")},
	{"id": "not_a_loss", "name": "这波不亏", "desc": "护盾挡下致命一击", "icon": "盾", "color": Color("8890a0")},
	{"id": "max_power", "name": "火力全开", "desc": "武器升到 Lv6", "icon": "力", "color": Color("ffd23c")},
	{"id": "saturation", "name": "饱和轰炸", "desc": "挑战者齐射击杀 Boss", "icon": "轰", "color": Color("ffd23c")},
	{"id": "funnel", "name": "浮游炮", "desc": "追踪者导弹雨击杀 Boss", "icon": "炮", "color": Color("ffd23c")},
	{"id": "one_punch", "name": "一拳超人", "desc": "用炸弹击杀 Boss", "icon": "拳", "color": Color("ffd23c")},
	{"id": "tetris", "name": "俄罗斯方块", "desc": "单次炸弹清除 50 发敌弹", "icon": "方", "color": Color("ffd23c")},
	{"id": "v50", "name": "V我50", "desc": "累计拾取 50 个道具", "icon": "V", "color": Color("3ec46a")},
	{"id": "extra_life", "name": "续命", "desc": "获得 1UP", "icon": "命", "color": Color("3ec46a")},
	{"id": "bomb_hero", "name": "手雷超人", "desc": "累计使用炸弹 20 次", "icon": "雷", "color": Color("3ec46a")},
	{"id": "konami", "name": "上上下下", "desc": "一局不用炸弹通关", "icon": "上", "color": Color("3ec46a")},
	{"id": "i_will_be_back", "name": "I'll be back", "desc": "阵亡后在本关击败 Boss", "icon": "T", "color": Color("3ec46a")},
]

var achieved := {}
var kills := 0
var tank_kills := 0
var kill_types := {}
var deaths := 0
var pickups := 0
var bombs := 0
var max_weapon := false
var last_skill_ship := -1
var last_skill_time := 0
var last_bomb_time := 0

var _queue: Array = []
var _showing := false
var _layer: CanvasLayer

func _ready() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 60
	add_child(_layer)
	var saved: Dictionary = Data.ach
	achieved = saved.get("achieved", {})
	var st: Dictionary = saved.get("stats", {})
	kills = int(st.get("kills", 0))
	tank_kills = int(st.get("tank", 0))
	kill_types = st.get("types", {})
	deaths = int(st.get("deaths", 0))
	pickups = int(st.get("pickups", 0))
	bombs = int(st.get("bombs", 0))

func _save() -> void:
	Data.ach = {
		"achieved": achieved,
		"stats": {
			"kills": kills, "tank": tank_kills, "types": kill_types,
			"deaths": deaths, "pickups": pickups, "bombs": bombs,
		},
	}
	Data.save_now()

func unlock(id: String) -> void:
	if achieved.has(id):
		return
	achieved[id] = true
	_save()
	var entry: Dictionary = _find(id)
	if not entry.is_empty():
		_queue.append(entry)
		_pump()

func _find(id: String) -> Dictionary:
	for a in ACH:
		if a["id"] == id:
			return a
	return {}

# ---------------- stat hooks ----------------

func add_kill(type: String) -> void:
	kills += 1
	kill_types[type] = true
	if type == "tank":
		tank_kills += 1
	_check_progress()
	_save()

func _check_progress() -> void:
	if kills == 1:
		unlock("first_blood")
	if kills >= 1000:
		unlock("thousand_kills")
	if tank_kills >= 50:
		unlock("tiger_tank")
	if kill_types.size() >= 9:
		unlock("pokemon_master")

func add_death() -> void:
	deaths += 1
	if deaths == 1:
		unlock("continue_coin")
	if deaths >= 50:
		unlock("habit_crash")
	_save()

func add_kamikaze() -> void:
	unlock("kamikaze_death")

func add_shield_block() -> void:
	unlock("not_a_loss")

func add_pickup(kind: String) -> void:
	pickups += 1
	if kind == "1UP":
		unlock("extra_life")
	if pickups >= 50:
		unlock("v50")
	_save()

func on_max_weapon() -> void:
	unlock("max_power")

func mark_skill(ship: int) -> void:
	last_skill_ship = ship
	last_skill_time = Time.get_ticks_msec()

func mark_bomb() -> void:
	last_bomb_time = Time.get_ticks_msec()

func add_bomb() -> void:
	bombs += 1
	if bombs >= 20:
		unlock("bomb_hero")
	_save()

func on_bomb_clear(count: int) -> void:
	if count >= 10:
		unlock("red_cliff")

func on_bomb_enemy_clear(count: int) -> void:
	if count >= 50:
		unlock("tetris")

func on_boss_killed(stage: int, died_in_stage: bool, ship: int) -> void:
	var now := Time.get_ticks_msec()
	if not achieved.has("hunt_begin"):
		unlock("hunt_begin")
	if stage == 1 and ship == 0 and not died_in_stage:
		unlock("gipsy_danger")
	if stage == 2 and not died_in_stage:
		unlock("desert_fox")
	if stage == 3 and not died_in_stage:
		unlock("fish_in_water")
	if stage == 10 and not died_in_stage:
		unlock("one_vs_thousand")
	if died_in_stage:
		unlock("i_will_be_back")
	if last_skill_ship == 1 and now - last_skill_time < 3000:
		unlock("saturation")
	if last_skill_ship == 2 and now - last_skill_time < 4000:
		unlock("funnel")
	if ship == 0 and now - last_bomb_time < 1500:
		unlock("one_punch")

func on_win(no_bomb_run: bool) -> void:
	unlock("mission_complete")
	if deaths == 0:
		unlock("zero_damage")
	if no_bomb_run:
		unlock("konami")

# ---------------- notification ----------------

func _pump() -> void:
	if _showing or _queue.is_empty():
		return
	_showing = true
	var a: Dictionary = _queue.pop_front()
	_show_notification(a)

func _show_notification(a: Dictionary) -> void:
	var root := Node2D.new()
	root.position = Vector2(480, 664)
	_layer.add_child(root)
	var panel := Art.ui_panel(Vector2(326, 52), Color(0.07, 0.09, 0.16, 0.94))
	panel.position = Vector2.ZERO
	root.add_child(panel)
	var icon_bg := Art.ui_panel(Vector2(40, 40), Color(a["color"]).darkened(0.35))
	icon_bg.position = Vector2(5, 6)
	root.add_child(icon_bg)
	var icon := Art.cn_label(a["icon"], Color(1, 1, 1), 12, 2)
	icon.reset_size()
	icon.pivot_offset = icon.size / 2.0
	icon.position = Vector2(25 - Art.cn_width(a["icon"], 12, 2) / 2.0, 6 + (40 - 12 * 2) / 2.0)
	root.add_child(icon)
	var name_label := Art.cn_label(a["name"], Color("ffd23c"), 12, 2)
	name_label.position = Vector2(52, 6)
	root.add_child(name_label)
	var desc_label := Art.cn_label(a["desc"], Color("c8d0dc"), 12, 1)
	desc_label.position = Vector2(52, 30)
	root.add_child(desc_label)
	var tw := create_tween()
	tw.tween_property(root, "position:x", 480.0 - 326.0 - 8.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(4.0)
	tw.tween_property(root, "position:x", 500.0, 0.35)
	tw.tween_callback(root.queue_free)
	tw.tween_callback(func():
		_showing = false
		_pump())
