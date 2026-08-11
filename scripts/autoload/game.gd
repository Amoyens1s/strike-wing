extends Node

signal score_changed(v)
signal lives_changed(v)
signal bombs_changed(v)
signal weapon_changed(v)

const SHIP_NAMES := ["流浪者", "挑战者", "追踪者"]
const MAX_LIVES := 4
const MAX_BOMBS := 4
const MAX_WEAPON := 6

var ship := 0
var score := 0
var lives := 2
var bombs := 2
var weapon := 1
var stage := 1
var deaths := 0
var bombs_used := 0
var run_time := 0.0

var player: Player = null
var boss: Boss = null

func _ready() -> void:
	randomize()
	_register_inputs()

func _register_inputs() -> void:
	_add_key_action("move_up", [KEY_W, KEY_UP])
	_add_key_action("move_down", [KEY_S, KEY_DOWN])
	_add_key_action("move_left", [KEY_A, KEY_LEFT])
	_add_key_action("move_right", [KEY_D, KEY_RIGHT])
	_add_key_action("bomb", [KEY_SPACE])
	for pair in [["ui_up", KEY_W], ["ui_down", KEY_S], ["ui_left", KEY_A], ["ui_right", KEY_D]]:
		var ev := InputEventKey.new()
		ev.physical_keycode = pair[1]
		if not InputMap.action_has_event(pair[0], ev):
			InputMap.action_add_event(pair[0], ev)

func _add_key_action(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		if not InputMap.action_has_event(action, ev):
			InputMap.action_add_event(action, ev)

func start_run(p_ship: int) -> void:
	ship = p_ship
	score = 0
	lives = 2
	bombs = 2
	weapon = 1
	stage = 1
	deaths = 0
	bombs_used = 0
	run_time = 0.0
	player = null
	boss = null

func add_score(v: int) -> void:
	score += v
	if score > Data.hi:
		Data.hi = score
	score_changed.emit(score)

func add_lives(v: int) -> void:
	lives = clampi(lives + v, 0, MAX_LIVES)
	lives_changed.emit(lives)

func add_bombs(v: int) -> void:
	bombs = clampi(bombs + v, 0, MAX_BOMBS)
	bombs_changed.emit(bombs)

func add_weapon(v: int) -> void:
	weapon = clampi(weapon + v, 1, MAX_WEAPON)
	if weapon >= MAX_WEAPON:
		Ach.on_max_weapon()
	weapon_changed.emit(weapon)
