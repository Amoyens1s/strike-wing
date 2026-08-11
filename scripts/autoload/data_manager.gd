extends Node

const PATH := "user://records.json"
const MAX_RUNS := 30

var hi := 0
var runs: Array = []
var ach := {}

func _ready() -> void:
	_load()

func add_run(r: Dictionary) -> void:
	r["date"] = Time.get_datetime_string_from_system(false, true)
	runs.push_front(r)
	if runs.size() > MAX_RUNS:
		runs.resize(MAX_RUNS)
	if int(r.get("score", 0)) > hi:
		hi = int(r["score"])
	save_now()

func save_now() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"hi": hi, "runs": runs, "ach": ach}))

func _load() -> void:
	if not FileAccess.file_exists(PATH):
		return
	var f := FileAccess.open(PATH, FileAccess.READ)
	if not f:
		return
	var data: Variant = JSON.parse_string(f.get_as_text())
	if data is Dictionary:
		hi = int(data.get("hi", 0))
		runs = data.get("runs", [])
		ach = data.get("ach", {})
