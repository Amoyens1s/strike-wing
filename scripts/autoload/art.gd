extends Node

const FONT := {
	"0": [0x0E, 0x11, 0x13, 0x15, 0x19, 0x11, 0x0E],
	"1": [0x04, 0x0C, 0x04, 0x04, 0x04, 0x04, 0x0E],
	"2": [0x0E, 0x11, 0x01, 0x02, 0x04, 0x08, 0x1F],
	"3": [0x1F, 0x02, 0x04, 0x02, 0x01, 0x11, 0x0E],
	"4": [0x02, 0x06, 0x0A, 0x12, 0x1F, 0x02, 0x02],
	"5": [0x1F, 0x10, 0x1E, 0x01, 0x01, 0x11, 0x0E],
	"6": [0x06, 0x08, 0x10, 0x1E, 0x11, 0x11, 0x0E],
	"7": [0x1F, 0x01, 0x02, 0x04, 0x08, 0x08, 0x08],
	"8": [0x0E, 0x11, 0x11, 0x0E, 0x11, 0x11, 0x0E],
	"9": [0x0E, 0x11, 0x11, 0x0F, 0x01, 0x02, 0x0C],
	"A": [0x0E, 0x11, 0x11, 0x1F, 0x11, 0x11, 0x11],
	"B": [0x1E, 0x11, 0x11, 0x1E, 0x11, 0x11, 0x1E],
	"C": [0x0E, 0x11, 0x10, 0x10, 0x10, 0x11, 0x0E],
	"D": [0x1E, 0x11, 0x11, 0x11, 0x11, 0x11, 0x1E],
	"E": [0x1F, 0x10, 0x10, 0x1E, 0x10, 0x10, 0x1F],
	"F": [0x1F, 0x10, 0x10, 0x1E, 0x10, 0x10, 0x10],
	"G": [0x0E, 0x11, 0x10, 0x17, 0x11, 0x11, 0x0F],
	"H": [0x11, 0x11, 0x11, 0x1F, 0x11, 0x11, 0x11],
	"I": [0x0E, 0x04, 0x04, 0x04, 0x04, 0x04, 0x0E],
	"J": [0x07, 0x02, 0x02, 0x02, 0x02, 0x12, 0x0C],
	"K": [0x11, 0x12, 0x14, 0x18, 0x14, 0x12, 0x11],
	"L": [0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x1F],
	"M": [0x11, 0x1B, 0x15, 0x15, 0x11, 0x11, 0x11],
	"N": [0x11, 0x19, 0x15, 0x13, 0x11, 0x11, 0x11],
	"O": [0x0E, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0E],
	"P": [0x1E, 0x11, 0x11, 0x1E, 0x10, 0x10, 0x10],
	"Q": [0x0E, 0x11, 0x11, 0x11, 0x15, 0x12, 0x0D],
	"R": [0x1E, 0x11, 0x11, 0x1E, 0x14, 0x12, 0x11],
	"S": [0x0F, 0x10, 0x10, 0x0E, 0x01, 0x01, 0x1E],
	"T": [0x1F, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04],
	"U": [0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0E],
	"V": [0x11, 0x11, 0x11, 0x11, 0x11, 0x0A, 0x04],
	"W": [0x11, 0x11, 0x11, 0x15, 0x15, 0x1B, 0x11],
	"X": [0x11, 0x11, 0x0A, 0x04, 0x0A, 0x11, 0x11],
	"Y": [0x11, 0x11, 0x0A, 0x04, 0x04, 0x04, 0x04],
	"Z": [0x1F, 0x01, 0x02, 0x04, 0x08, 0x10, 0x1F],
	" ": [0, 0, 0, 0, 0, 0, 0],
	"-": [0, 0, 0, 0x0E, 0, 0, 0],
	":": [0, 0x0C, 0x0C, 0, 0x0C, 0x0C, 0],
	".": [0, 0, 0, 0, 0, 0x0C, 0x0C],
	"/": [0x01, 0x02, 0x02, 0x04, 0x08, 0x08, 0x10],
	"!": [0x04, 0x04, 0x04, 0x04, 0x04, 0, 0x04],
	"?": [0x0E, 0x11, 0x01, 0x02, 0x04, 0, 0x04],
	">": [0x08, 0x04, 0x02, 0x01, 0x02, 0x04, 0x08],
	"<": [0x02, 0x04, 0x08, 0x10, 0x08, 0x04, 0x02],
	"+": [0, 0x04, 0x04, 0x1F, 0x04, 0x04, 0],
	"=": [0, 0, 0x1F, 0, 0x1F, 0, 0],
}

const PLAYER_PAL := {
	"o": Color("0c1220"), "m": Color("4a7dff"), "h": Color("d8e6ff"),
	"s": Color("1e3a8c"), "g": Color("a8e8ff"), "e": Color("ff9a3c"),
}

func enemy_pal(style: String) -> Dictionary:
	if style == "r":
		return {"o": Color("180c0c"), "m": Color("a8463c"), "h": Color("f0b8a0"),
			"s": Color("5c2620"), "g": Color("ffe9b0"), "e": Color("ff6a3c")}
	return {"o": Color("101408"), "m": Color("6f8f52"), "h": Color("cfe6a8"),
		"s": Color("3a5230"), "g": Color("ffd9a0"), "e": Color("ff6a3c")}

func boss_pal(stage: int) -> Dictionary:
	var mains := ["7a8f52", "a8463c", "4a6fa8", "8f4aa8", "a8873c",
		"3ca89a", "a83c6e", "6e8f3c", "5c5ca8", "b03030"]
	var m := Color(mains[(stage - 1) % mains.size()])
	return {"o": m.darkened(0.82), "m": m, "h": m.lightened(0.55),
		"s": m.darkened(0.45), "g": Color("ffd9a0"), "e": Color("ff6a3c")}

func _px(img: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
		img.set_pixel(x, y, c)

# ---------------- pixel font ----------------

func text_width(text: String, scale := 1) -> int:
	return maxi(0, text.length() * 6 - 1) * scale

func text_texture(text: String, color: Color, scale := 1, shadow := Color(0, 0, 0, 0)) -> ImageTexture:
	text = text.to_upper()
	var w := maxi(1, text_width(text, scale))
	var h := 7 * scale + (scale if shadow.a > 0.0 else 0)
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var ox := 0
	for i in text.length():
		var glyph: Array = FONT.get(text[i], FONT["?"])
		for row in 7:
			var bits: int = glyph[row]
			for col in 5:
				if bits & (1 << (4 - col)):
					for sx in scale:
						for sy in scale:
							if shadow.a > 0.0:
								_px(img, ox + col * scale + sx, row * scale + sy + scale, shadow)
							_px(img, ox + col * scale + sx, row * scale + sy, color)
		ox += 6 * scale
	return ImageTexture.create_from_image(img)

func make_label(text: String, color: Color, scale := 1, shadow := true) -> TextureRect:
	var tr := TextureRect.new()
	tr.texture = text_texture(text, color, scale, Color(0, 0, 0, 0.7) if shadow else Color(0, 0, 0, 0))
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tr

func set_label(tr: TextureRect, text: String, color: Color, scale := 1, shadow := true) -> void:
	tr.texture = text_texture(text, color, scale, Color(0, 0, 0, 0.7) if shadow else Color(0, 0, 0, 0))

# ---------------- CJK text (direct Label rendering with pixel font) ----------------

var _cn_font: Font = null

func _get_cn_font() -> Font:
	if _cn_font == null:
		var ff := FontFile.new()
		if ff.load_dynamic_font("res://assets/fonts/ark-pixel-12px-zh_cn.ttf") != OK:
			var sf := SystemFont.new()
			sf.font_names = PackedStringArray(["Microsoft YaHei", "SimHei", "Noto Sans CJK SC", "WenQuanYi Zen Hei"])
			_cn_font = sf
		else:
			ff.antialiasing = TextServer.FONT_ANTIALIASING_NONE
			_cn_font = ff
	return _cn_font

func cn_width(text: String, size := 12, scale := 2) -> int:
	return int(ceil(_get_cn_font().get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, int(size * scale)).x))

func cn_label(text: String, color: Color, size := 12, scale := 2, shadow := true) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", _get_cn_font())
	l.add_theme_font_size_override("font_size", int(size * scale))
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0))
	if shadow:
		l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
		l.add_theme_constant_override("shadow_offset_x", maxi(1, int(scale)))
		l.add_theme_constant_override("shadow_offset_y", maxi(1, int(scale)))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func set_cn_label(l: Label, text: String, color: Color, size := 12, scale := 2) -> void:
	l.text = text
	l.add_theme_color_override("font_color", color)

# ---------------- UI kit textures ----------------

func ui_panel(size: Vector2, color: Color) -> TextureRect:
	var tr := TextureRect.new()
	tr.texture = load("res://assets/ui/Panel02.png")
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.size = size
	tr.modulate = color
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tr

func ui_bar_fill(size: Vector2, color: Color) -> TextureRect:
	var tr := TextureRect.new()
	tr.texture = load("res://assets/ui/BarV1_ProgressBar.png")
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.size = size
	tr.modulate = color
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tr

func ui_bar_border(size: Vector2, color: Color) -> TextureRect:
	var tr := TextureRect.new()
	tr.texture = load("res://assets/ui/BarV1_ProgressBarBorder.png")
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.size = size
	tr.modulate = color
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tr



# ---------------- aircraft ----------------

func _profile_halfwidth(pts: Array, t: float) -> float:
	if t <= pts[0][0]:
		return pts[0][1]
	for i in range(pts.size() - 1):
		var a: Array = pts[i]
		var b: Array = pts[i + 1]
		if t <= b[0]:
			var k: float = (t - float(a[0])) / maxf(0.0001, float(b[0]) - float(a[0]))
			return lerpf(float(a[1]), float(b[1]), k)
	return pts[pts.size() - 1][1]

func _draw_profile(img: Image, pal: Dictionary, pts: Array, cx: float, w: int, h: int, y0: int, y1: int) -> void:
	for y in range(y0, y1 + 1):
		var t := float(y) / float(h - 1)
		var hw := _profile_halfwidth(pts, t) * (w * 0.5)
		if hw < 1.0:
			continue
		var x0 := int(round(cx - hw))
		var x1 := int(round(cx + hw))
		for x in range(x0, x1 + 1):
			var rel := (float(x) - cx) / hw
			var c: Color
			if x == x0 or x == x1 or y == y0 or y == y1:
				c = pal.o
			elif rel < -0.30:
				c = pal.h
			elif rel > 0.55:
				c = pal.s
			else:
				c = pal.m
			_px(img, x, y, c)

func _flip_pts(pts: Array) -> Array:
	var out := []
	for i in range(pts.size() - 1, -1, -1):
		out.append([1.0 - pts[i][0], pts[i][1]])
	return out

func aircraft_img(w: int, h: int, pal: Dictionary, opts := {}) -> Image:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var cx := (w - 1) * 0.5
	var flip: bool = opts.get("flip", false)
	var tail: Array = opts.get("tail", [[0.80, 0.06], [0.93, 0.26], [1.0, 0.08]])
	var wing: Array = opts.get("wing", [[0.36, 0.10], [0.55, 0.48], [0.70, 0.40], [0.85, 0.06]])
	var body: Array = opts.get("body", [[0.0, 0.04], [0.16, 0.11], [0.45, 0.17], [0.78, 0.18], [0.92, 0.13], [1.0, 0.08]])
	var cy: float = opts.get("cy", 0.30)
	if flip:
		tail = _flip_pts(tail)
		wing = _flip_pts(wing)
		body = _flip_pts(body)
		cy = 1.0 - cy
	_draw_profile(img, pal, tail, cx, w, h, int(h * 0.78), h - 1)
	_draw_profile(img, pal, wing, cx, w, h, int(h * 0.32), int(h * 0.86))
	_draw_profile(img, pal, body, cx, w, h, 0, h - 1)
	# panel lines
	for lt in [0.52, 0.68]:
		var ly := int(h * lt)
		var hw := _profile_halfwidth(body, lt) * (w * 0.5)
		for x in range(int(cx - hw) + 1, int(cx + hw)):
			_px(img, x, ly, pal.s.darkened(0.3))
	# cockpit
	var ccx := h * cy
	var rx: float = w * opts.get("crx", 0.085)
	var ry: float = h * opts.get("cry", 0.065)
	for y in range(int(ccx - ry - 2), int(ccx + ry + 3)):
		for x in range(int(cx - rx - 2), int(cx + rx + 3)):
			var dx := (x - cx) / rx
			var dy := (y - ccx) / ry
			var d := dx * dx + dy * dy
			if d <= 1.0:
				_px(img, x, y, pal.g if (dx < 0.15 and dy < 0.15) else pal.g.darkened(0.4))
			elif d <= 1.5:
				_px(img, x, y, pal.o)
	_px(img, int(cx - rx * 0.35), int(ccx - ry * 0.35), Color(1, 1, 1))
	# side pods
	if opts.get("pods", false):
		for side in [-1, 1]:
			var pxc := int(cx + side * w * 0.30)
			var pw := maxi(2, int(w * 0.07))
			for y in range(int(h * 0.42), int(h * 0.86)):
				for x in range(pxc - pw, pxc + pw + 1):
					var c: Color = pal.o
					if x > pxc - pw and x < pxc + pw and y > int(h * 0.42) and y < int(h * 0.86) - 1:
						c = pal.h if x < pxc else (pal.s if x > pxc else pal.m)
					_px(img, x, y, c)
	# nose prongs
	if opts.get("prongs", false):
		for side in [-1, 1]:
			var bxc := int(cx + side * w * 0.08)
			var y0 := 0 if not flip else int(h * 0.86)
			var y1 := int(h * 0.14) if not flip else h - 1
			for y in range(y0, y1 + 1):
				_px(img, bxc, y, pal.m)
				_px(img, bxc + side, y, pal.o)
	# engine nozzles (bottom for player-facing-up ships)
	if not flip:
		var nw := maxi(2, int(w * 0.08))
		for side in [-1, 1]:
			var nxc := int(cx + side * w * 0.13)
			for y in range(h - 4, h):
				for x in range(nxc - nw / 2, nxc + nw / 2 + 1):
					_px(img, x, y, pal.o if y == h - 1 else Color(0.16, 0.18, 0.22))
	return img

func aircraft(w: int, h: int, pal: Dictionary, opts := {}) -> ImageTexture:
	return ImageTexture.create_from_image(aircraft_img(w, h, pal, opts))

func player_ship_tex(ship: int) -> Texture2D:
	match ship:
		1:
			return aircraft(70, 40, PLAYER_PAL, {
				"tail": [[0.80, 0.10], [0.92, 0.26], [1.0, 0.08]],
				"wing": [[0.15, 0.30], [0.45, 0.80], [0.65, 0.72], [0.88, 0.30]],
				"body": [[0.0, 0.06], [0.2, 0.16], [0.5, 0.20], [0.8, 0.20], [1.0, 0.12]],
				"cy": 0.28, "crx": 0.09, "cry": 0.06, "prongs": true})
		2:
			return aircraft(62, 42, PLAYER_PAL, {
				"wing": [[0.40, 0.24], [0.60, 0.52], [0.78, 0.42], [0.90, 0.16]],
				"body": [[0.0, 0.07], [0.2, 0.16], [0.5, 0.20], [0.85, 0.20], [1.0, 0.12]],
				"cy": 0.30, "pods": true})
	return aircraft(66, 42, PLAYER_PAL, {
		"tail": [[0.78, 0.10], [0.92, 0.26], [1.0, 0.08]],
		"wing": [[0.30, 0.28], [0.55, 0.72], [0.72, 0.62], [0.88, 0.20]],
		"body": [[0.0, 0.08], [0.2, 0.20], [0.5, 0.26], [0.8, 0.26], [1.0, 0.15]],
		"cy": 0.30})

func enemy_tex(type: String, stage: int) -> ImageTexture:
	var pal := enemy_pal("r" if stage % 2 == 0 else "g")
	var img: Image
	match type:
		"drone":
			img = _xwing_img(pal)
		"weaver":
			img = aircraft_img(50, 52, pal, {
				"wing": [[0.30, 0.30], [0.52, 0.40], [0.72, 0.28], [0.88, 0.12]],
				"body": [[0.0, 0.08], [0.2, 0.18], [0.6, 0.22], [1.0, 0.12]],
				"cy": 0.32, "pods": true, "flip": true})
		"diver":
			img = aircraft_img(46, 54, pal, {
				"wing": [[0.30, 0.20], [0.55, 0.50], [0.78, 0.42], [0.90, 0.10]],
				"body": [[0.0, 0.05], [0.3, 0.13], [0.7, 0.17], [1.0, 0.09]],
				"cy": 0.30, "cry": 0.08, "flip": true})
			_decorate(img, "diver", pal)
		"gunship":
			img = _tie_img(pal)
		"tank":
			img = aircraft_img(86, 76, pal, {
				"tail": [[0.80, 0.16], [0.93, 0.38], [1.0, 0.14]],
				"wing": [[0.25, 0.30], [0.50, 0.52], [0.72, 0.50], [0.90, 0.22]],
				"body": [[0.0, 0.08], [0.2, 0.20], [0.6, 0.26], [1.0, 0.14]],
				"cy": 0.28, "crx": 0.07, "pods": true, "flip": true})
			_decorate(img, "tank", pal)
		"spinner":
			img = _turret_img(pal, 64)
		"shooter":
			img = aircraft_img(44, 46, pal, {
				"wing": [[0.45, 0.20], [0.65, 0.40], [0.85, 0.15]],
				"body": [[0.0, 0.07], [0.25, 0.18], [0.65, 0.22], [1.0, 0.12]],
				"cy": 0.30, "flip": true})
			_decorate(img, "shooter", pal)
		"burst":
			img = aircraft_img(56, 46, pal, {
				"wing": [[0.15, 0.85], [0.45, 0.80], [0.68, 0.62], [0.90, 0.28]],
				"body": [[0.0, 0.08], [0.25, 0.20], [0.6, 0.24], [1.0, 0.12]],
				"cy": 0.34, "flip": true})
			_decorate(img, "burst", pal)
		"bomber":
			img = aircraft_img(52, 44, pal, {
				"wing": [[0.30, 0.55], [0.55, 0.50], [0.75, 0.35], [0.90, 0.12]],
				"body": [[0.0, 0.14], [0.25, 0.30], [0.6, 0.32], [1.0, 0.18]],
				"cy": 0.30, "flip": true})
			_decorate(img, "bomber", pal)
		_:
			img = aircraft_img(44, 46, pal, {"flip": true})
	return ImageTexture.create_from_image(img)

func _xwing_img(pal: Dictionary, w := 46, h := 50) -> Image:
	var img := aircraft_img(w, h, pal, {
		"wing": [[0.45, 0.08], [0.62, 0.18], [0.85, 0.06]],
		"body": [[0.0, 0.03], [0.2, 0.11], [0.6, 0.14], [1.0, 0.07]],
		"cy": 0.32, "flip": true})
	var cx := (w - 1) * 0.5
	var mid := h * 0.45
	for side in [-1, 1]:
		for up in [-1, 1]:
			var len_: int = int(w * 0.30)
			for t in len_:
				var x := int(cx + side * (3.0 + t * 0.85))
				var y := int(mid + up * t * 0.55)
				for dx in 2:
					for dy in 2:
						var c: Color = pal.h if side < 0 else pal.s
						if t >= len_ - 3:
							c = pal.e
						_px(img, x + dx, y + dy, c)
					_px(img, x - 1, y, pal.o)
					_px(img, x + 2, y + 1, pal.o)
	return img

func _tie_img(pal: Dictionary, w := 68, h := 54) -> Image:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var cx := (w - 1) * 0.5
	var cy := (h - 1) * 0.5
	# 左右六角形翼板
	for side in [-1, 1]:
		var pcx := int(cx + side * 25)
		for y in h:
			for x in w:
				var dx := absf(x - pcx) / 11.0
				var dy := absf(y - cy) / 19.0
				if dx + dy <= 1.0:
					var c: Color = pal.m
					if dx + dy > 0.82:
						c = pal.o
					elif x < pcx:
						c = pal.h
					_px(img, x, y, c)
		# 翼板内竖线
		for y in range(int(cy - 14), int(cy + 15)):
			_px(img, int(pcx + side * 6), y, pal.s.darkened(0.2))
	# 中央球舱
	for y in h:
		for x in w:
			var d := Vector2(x - cx, y - cy).length()
			if d <= 11.0:
				var c: Color = pal.g if d < 10.0 else pal.o
				if d < 9.0 and x < cx and y < cy:
					c = pal.g.lightened(0.3)
				_px(img, x, y, c)
	_px(img, int(cx) - 4, int(cy) - 4, Color(1, 1, 1))
	# 连杆
	for y in range(int(cy) - 2, int(cy) + 3):
		for x in range(int(cx - 15), int(cx + 16)):
			_px(img, x, y, Color("20242c"))
	return img

func _decorate(img: Image, kind: String, pal: Dictionary) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var cx := (w - 1) * 0.5
	var hot := Color("e03030")
	match kind:
		"diver":
			for i in 2:
				for y in range(h - 8, h - 3):
					_px(img, int(cx - 8) + i, y, pal.e)
					_px(img, int(cx + 8) - i, y, pal.e)
			for y in range(int(h * 0.1), h - 4):
				_px(img, 2, y, pal.h)
				_px(img, w - 3, y, pal.h)
		"tank":
			for y in range(h - 10, h):
				_px(img, int(cx), y, Color("181820"))
				_px(img, int(cx) + 1, y, pal.o)
			for band in [0.30, 0.52, 0.72]:
				for x in w:
					_px(img, x, int(h * band), pal.s.darkened(0.35))
					_px(img, x, int(h * band) + 1, pal.o)
		"shooter":
			for side in [-1, 1]:
				var bx := int(cx + side * 6)
				for y in range(h - 7, h):
					_px(img, bx, y, pal.e)
		"burst":
			for side in [-1, 1]:
				var gx := 2 if side < 0 else w - 3
				for i in 2:
					for j in 2:
						_px(img, gx + i, 4 + j, pal.g)
			for y in range(h - 9, h - 2):
				for dx in 3:
					_px(img, int(cx) - 1 + dx, y, pal.o if dx == 0 or dx == 2 else Color("1c1c20"))
		"bomber":
			for x in w:
				_px(img, x, int(h * 0.42), hot)
				_px(img, x, int(h * 0.46), hot)
			for y in range(int(h * 0.06), int(h * 0.2)):
				_px(img, int(cx) - 2, y, hot)
				_px(img, int(cx) + 2, y, hot)

func _turret_img(pal: Dictionary, size := 64) -> Image:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c := (size - 1) * 0.5
	var r_body := size * 0.42
	for y in size:
		for x in size:
			var d := Vector2(x - c, y - c).length()
			if d <= r_body:
				var col: Color = pal.o
				if d < r_body - 1.0:
					if x < c and y < c:
						col = pal.h
					elif x > c + r_body * 0.2 or y > c + r_body * 0.2:
						col = pal.s
					else:
						col = pal.m
				_px(img, x, y, col)
	for i in 4:
		var ang := i * PI / 2.0
		for t in range(int(r_body) - 2, int(r_body) + 7):
			var px := int(c + cos(ang) * t)
			var py := int(c + sin(ang) * t)
			_px(img, px, py, pal.o)
			_px(img, px + int(cos(ang + PI / 2.0)), py + int(sin(ang + PI / 2.0)), pal.m)
	var core_r := 6.0
	for y in size:
		for x in size:
			var d := Vector2(x - c, y - c).length()
			if d <= core_r:
				_px(img, x, y, Color("ffb040") if d < core_r * 0.6 else Color("a83010"))
	_px(img, int(c) - 2, int(c) - 2, Color(1, 1, 1))
	return img

func boss_ship_tex(stage: int) -> ImageTexture:
	var pal := boss_pal(stage)
	var img := aircraft_img(150, 116, pal, {
		"tail": [[0.82, 0.18], [0.94, 0.40], [1.0, 0.16]],
		"wing": [[0.22, 0.22], [0.45, 0.50], [0.62, 0.48], [0.80, 0.20], [0.92, 0.08]],
		"body": [[0.0, 0.05], [0.15, 0.16], [0.40, 0.24], [0.75, 0.26], [0.92, 0.20], [1.0, 0.12]],
		"cy": 0.24, "crx": 0.07, "cry": 0.05, "pods": true, "flip": true})
	var w := img.get_width()
	var h := img.get_height()
	var cx := (w - 1) * 0.5
	# core gem
	var gy := int(h * 0.52)
	var gr := 11
	for y in range(gy - gr - 2, gy + gr + 3):
		for x in range(int(cx) - gr - 2, int(cx) + gr + 3):
			var d := Vector2(x - cx, y - gy).length()
			if d <= gr:
				var c := Color("ff3040") if d < gr * 0.7 else Color("7a1020")
				_px(img, x, y, c)
			elif d <= gr + 1.5:
				_px(img, x, y, pal.o)
	_px(img, int(cx) - 4, gy - 4, Color(1, 1, 1))
	_px(img, int(cx) - 3, gy - 4, Color(1, 1, 1))
	# gun barrels (boss faces down after flip)
	for side in [-1, 1]:
		for off in [0.24, 0.38]:
			var bx := int(cx + side * w * off)
			for y in range(h - 10, h):
				_px(img, bx, y, pal.o)
				_px(img, bx + side, y, Color(0.16, 0.18, 0.22))
	# extra wing pods
	for side in [-1, 1]:
		var pxc := int(cx + side * w * 0.42)
		for y in range(int(h * 0.45), int(h * 0.75)):
			for x in range(pxc - 4, pxc + 5):
				var c: Color = pal.o
				if x > pxc - 4 and x < pxc + 4 and y > int(h * 0.45) and y < int(h * 0.75) - 1:
					c = pal.h if x < pxc else (pal.s if x > pxc else pal.m)
				_px(img, x, y, c)
	return ImageTexture.create_from_image(img)

# ---------------- bullets / fx textures ----------------

func glow_tex(size := 32) -> ImageTexture:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c := (size - 1) * 0.5
	for y in size:
		for x in size:
			var d := Vector2(x - c, y - c).length() / c
			if d <= 1.0:
				var a := pow(1.0 - d, 2.2)
				_px(img, x, y, Color(1, 1, 1, a))
	return ImageTexture.create_from_image(img)

func spark_tex(size := 9) -> ImageTexture:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c := size / 2
	for i in size:
		_px(img, c, i, Color(1, 1, 1, 1.0 - absf(i - c) / c * 0.5))
		_px(img, i, c, Color(1, 1, 1, 1.0 - absf(i - c) / c * 0.5))
	_px(img, c, c, Color(1, 1, 1))
	return ImageTexture.create_from_image(img)

func ring_tex(size := 64) -> ImageTexture:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c := (size - 1) * 0.5
	var r := c - 2.0
	for y in size:
		for x in size:
			var d := absf(Vector2(x - c, y - c).length() - r)
			if d < 2.0:
				_px(img, x, y, Color(1, 1, 1, 1.0 - d * 0.5))
	return ImageTexture.create_from_image(img)

func bullet_tex(kind: String) -> ImageTexture:
	match kind:
		"shot":
			return _capsule_tex(8, 18, Color("fff6cc"), Color("ffcc33"), Color("ff9a00"))
		"shot_space":
			return _capsule_tex(8, 18, Color("eafffa"), Color("33e0ff"), Color("1a78c8"))
		"missile":
			return _missile_tex()
		"orb":
			return _orb_tex(7, Color(1, 1, 1), Color("ff44aa"), Color("ff44aa"))
		"orb_big":
			return _orb_tex(11, Color(1, 1, 1), Color("ff2288"), Color("ff44aa"))
		"diamond":
			return _diamond_tex(7, Color("f0ccff"), Color("c044ff"))
		"dot":
			return _orb_tex(5, Color(1, 1, 1), Color("ff5544"), Color("ff5544"))
		"bolt":
			return _capsule_tex(6, 14, Color("ffffff"), Color("66aaff"), Color("2244cc"))
	return _orb_tex(6, Color(1, 1, 1), Color("ff44aa"), Color("ff44aa"))

func _capsule_tex(w: int, h: int, core: Color, mid: Color, edge: Color) -> ImageTexture:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var cx := (w - 1) * 0.5
	for y in h:
		var ty := float(y) / (h - 1)
		var hw := (w * 0.5 - 0.5) * sin(PI * clampf(ty * 1.15, 0.0, 1.0))
		if hw < 0.5:
			hw = 0.5
		for x in w:
			var dx := absf(x - cx)
			if dx <= hw:
				var k := dx / hw
				var c := core if k < 0.35 else (mid if k < 0.75 else edge)
				c.a = 1.0 if k < 0.8 else 0.7
				_px(img, x, y, c)
	return ImageTexture.create_from_image(img)

func _orb_tex(r: int, core: Color, mid: Color, halo: Color) -> ImageTexture:
	var size := r * 2 + 6
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c := (size - 1) * 0.5
	for y in size:
		for x in size:
			var d := Vector2(x - c, y - c).length()
			if d <= r:
				var k := d / r
				var col := core if k < 0.4 else mid
				_px(img, x, y, col)
			elif d <= r + 3:
				var a := 0.45 * (1.0 - (d - r) / 3.0)
				_px(img, x, y, Color(halo.r, halo.g, halo.b, a))
	return ImageTexture.create_from_image(img)

func _diamond_tex(r: int, core: Color, mid: Color) -> ImageTexture:
	var size := r * 2 + 6
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c := (size - 1) * 0.5
	for y in size:
		for x in size:
			var d := absf(x - c) + absf(y - c)
			if d <= r:
				_px(img, x, y, core if d < r * 0.45 else mid)
			elif d <= r + 2.5:
				_px(img, x, y, Color(mid.r, mid.g, mid.b, 0.4 * (1.0 - (d - r) / 2.5)))
	return ImageTexture.create_from_image(img)

func _missile_tex() -> ImageTexture:
	var img := Image.create(8, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in 16:
		for x in 8:
			if y < 3:
				if x >= 3 and x <= 4:
					_px(img, x, y, Color("ff4030"))
			elif y < 12:
				if x >= 2 and x <= 5:
					_px(img, x, y, Color("ffe9c8") if x < 4 else Color("d8a060"))
			else:
				if x >= 1 and x <= 6 and (x == 1 or x == 6 or (x >= 3 and x <= 4)):
					_px(img, x, y, Color("ff9a3c"))
	return ImageTexture.create_from_image(img)

func flame_tex() -> ImageTexture:
	var img := Image.create(10, 18, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var cx := 4.5
	for y in 18:
		var t := float(y) / 17.0
		var hw := 4.0 * (1.0 - t) * sin(PI * clampf(t * 3.0, 0.0, 1.0)) + 0.4
		for x in 10:
			var dx := absf(x - cx)
			if dx <= hw:
				var k := dx / hw
				var c := Color(1, 1, 1) if k < 0.3 else (Color("ffcc33") if k < 0.65 else Color("ff6a1e"))
				c.a = (1.0 - t * 0.8) * (1.0 - k * 0.4)
				_px(img, x, y, c)
	return ImageTexture.create_from_image(img)

func shield_tex() -> ImageTexture:
	var size := 48
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c := (size - 1) * 0.5
	for y in size:
		for x in size:
			var d := absf(Vector2(x - c, y - c).length() - 20.0)
			if d < 3.0:
				var a := 1.0 - d / 3.0
				_px(img, x, y, Color(0.5, 0.9, 1.0, a * 0.9))
	return ImageTexture.create_from_image(img)

func badge_tex(letter: String) -> ImageTexture:
	var size := 28
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var gold := Color("ffd24a")
	var red := Color("c82828")
	var dark := Color("7a1414")
	for y in size:
		for x in size:
			var dx := mini(mini(x, size - 1 - x), 99)
			var dy := mini(y, size - 1 - y)
			var corner := (x < 4 and y < 4 and Vector2(x - 3.5, y - 3.5).length() > 3.5) \
				or (x > size - 5 and y < 4 and Vector2(x - (size - 4.5), y - 3.5).length() > 3.5) \
				or (x < 4 and y > size - 5 and Vector2(x - 3.5, y - (size - 4.5)).length() > 3.5) \
				or (x > size - 5 and y > size - 5 and Vector2(x - (size - 4.5), y - (size - 4.5)).length() > 3.5)
			if corner:
				continue
			if dx < 2 or dy < 2:
				_px(img, x, y, gold if (y < size / 2) else gold.darkened(0.25))
			else:
				_px(img, x, y, red if y < size / 2 else dark)
	for x in range(3, size - 3):
		_px(img, x, 3, Color("ffe9a8"))
	var scale := 1 if letter.length() > 1 else 2
	var lt := text_texture(letter, Color(1, 1, 1), scale, Color(0, 0, 0, 0.8))
	var li := lt.get_image()
	var lx := (size - li.get_width()) / 2
	var ly := (size - 7 * scale) / 2
	for y in li.get_height():
		for x in li.get_width():
			var c := li.get_pixel(x, y)
			if c.a > 0.0:
				_px(img, lx + x, ly + y, c)
	return ImageTexture.create_from_image(img)

# ---------------- background tiles ----------------

const TILE_W := 240
const TILE_H := 256

const THEMES := {
	"jungle": {"style": "veg", "far": ["07231a", "0d3a26", "125233"], "b1": ["0f4d2a", "1a6b38"], "b2": ["2f8f4a", "63c96f"]},
	"desert": {"style": "dune", "far": ["8a5a2a", "b98346", "d9a964"], "b1": ["9c6b33", "7a4f22"], "b2": ["e8c98a", "c8a05a"]},
	"ocean": {"style": "wave", "far": ["06203c", "0b3560", "12508a"], "b1": ["1a6aa8", "2f8ac8"], "b2": ["9adcf0", "e8fbff"]},
	"snow": {"style": "snow", "far": ["8fa8c8", "b8cce0", "e8f2fa"], "b1": ["c8dcf0", "a8c0dc"], "b2": ["ffffff", "dceefc"]},
	"base": {"style": "metal", "far": ["1c2026", "262c34", "313a44"], "b1": ["3a4450", "232a32"], "b2": ["ffd24a", "5a6672"]},
	"canyon": {"style": "dune", "far": ["5c2a1e", "7a3c28", "9c5436"], "b1": ["6e3424", "4c2016"], "b2": ["c87a4e", "a85c36"]},
	"storm": {"style": "wave", "far": ["041820", "073040", "0b4a5c"], "b1": ["0f5c6e", "14788c"], "b2": ["7ac8d8", "c8f0f8"]},
	"tundra": {"style": "snow", "far": ["2c3c54", "44587a", "5c749c"], "b1": ["6e88ac", "546e92"], "b2": ["c8dcf4", "a8c4e4"]},
	"fortress": {"style": "metal", "far": ["200c0c", "301414", "401c1c"], "b1": ["4c2424", "2c1212"], "b2": ["ff5040", "6e3030"]},
	"space": {"style": "space", "far": ["040410", "0a0a24", "141438"], "b1": ["2c2c5c", "1c1c44"], "b2": ["e8e8ff", "8a8ac8"]},
}

func bg_tile(theme: String, layer: int, seed_val: int) -> ImageTexture:
	var def: Dictionary = THEMES.get(theme, THEMES["jungle"])
	var img := Image.create(TILE_W, TILE_H, false, Image.FORMAT_RGBA8)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val * 131 + layer * 17 + 5
	img.fill(_flat_color(def, layer))
	match def["style"]:
		"veg":
			_veg(img, layer, rng, def)
		"dune":
			_dune(img, layer, rng, def)
		"wave":
			_wave(img, layer, rng, def)
		"snow":
			_snow(img, layer, rng, def)
		"metal":
			_metal(img, layer, rng, def)
		"space":
			_space(img, layer, rng, def)
	return ImageTexture.create_from_image(img)

func _flat_color(def: Dictionary, layer: int) -> Color:
	var base := Color(def["far"][1])
	if layer == 1:
		base = base.darkened(0.10)
	elif layer == 2:
		base = base.darkened(0.22)
	return base

func _circle_wrap(img: Image, x: float, y: float, r: float, col: Color, hl: Color) -> void:
	for oy in [-TILE_H, 0, TILE_H]:
		for ox in [-TILE_W, 0, TILE_W]:
			var ccx: float = x + ox
			var ccy: float = y + oy
			if ccx < -r or ccx > TILE_W + r or ccy < -r or ccy > TILE_H + r:
				continue
			for yy in range(int(ccy - r), int(ccy + r) + 1):
				for xx in range(int(ccx - r), int(ccx + r) + 1):
					var d := Vector2(xx - ccx, yy - ccy).length()
					if d <= r:
						var c := col
						if d > r - 1.5:
							c = col.darkened(0.35)
						elif xx < ccx - r * 0.25 and yy < ccy - r * 0.25:
							c = hl
						_px(img, xx, yy, c)

func _streak_wrap(img: Image, x: float, y: float, len_: int, w: int, col: Color) -> void:
	for oy in [-TILE_H, 0, TILE_H]:
		for yy in range(int(y + oy), int(y + oy) + len_):
			for xx in range(int(x), int(x) + w):
				_px(img, xx, yy, col)

func _veg(img: Image, layer: int, rng: RandomNumberGenerator, def: Dictionary) -> void:
	if layer == 0:
		for i in 7:
			_circle_wrap(img, rng.randf() * TILE_W, rng.randf() * TILE_H, rng.randf_range(17, 30),
				Color(def["b1"][1]).darkened(0.25), Color(def["b1"][0]))
	elif layer == 1:
		for i in 14:
			_circle_wrap(img, rng.randf() * TILE_W, rng.randf() * TILE_H, rng.randf_range(6, 12),
				Color(def["b1"][0]), Color(def["b2"][1]).darkened(0.2))
	else:
		for i in 22:
			_circle_wrap(img, rng.randf() * TILE_W, rng.randf() * TILE_H, rng.randf_range(2, 4),
				Color(def["b2"][0]), Color(def["b2"][1]))

func _dune(img: Image, layer: int, rng: RandomNumberGenerator, def: Dictionary) -> void:
	if layer == 0:
		for i in 6:
			_circle_wrap(img, rng.randf() * TILE_W, rng.randf() * TILE_H, rng.randf_range(20, 35),
				Color(def["b1"][0]).darkened(0.12), Color(def["b1"][0]).lightened(0.15))
	elif layer == 1:
		for i in 3:
			var base_y := rng.randf() * TILE_H
			var amp := rng.randf_range(7, 13)
			var period := 2 + i
			for x in TILE_W:
				var y := int(base_y + amp * sin(TAU * period * x / TILE_W))
				for th in 2:
					for oy in [-TILE_H, 0, TILE_H]:
						_px(img, x, y + th + oy, Color(def["b1"][1]).darkened(0.1))
	else:
		for i in 26:
			_streak_wrap(img, rng.randf() * TILE_W, rng.randf() * TILE_H, rng.randi_range(2, 4), 1,
				Color(def["b2"][rng.randi() % 2]))

func _wave(img: Image, layer: int, rng: RandomNumberGenerator, def: Dictionary) -> void:
	if layer == 0:
		for i in 5:
			_circle_wrap(img, rng.randf() * TILE_W, rng.randf() * TILE_H, rng.randf_range(18, 32),
				Color(def["b1"][0]).darkened(0.3), Color(def["b1"][0]).darkened(0.15))
	elif layer == 1:
		for i in 6:
			var base_y := i * (TILE_H / 6) + 10
			var amp := 5.0
			for x in TILE_W:
				var y := int(base_y + amp * sin(TAU * 4 * x / TILE_W + i))
				for oy in [-TILE_H, 0, TILE_H]:
					_px(img, x, y + oy, Color(def["b1"][1]))
	else:
		for i in 24:
			_streak_wrap(img, rng.randf() * TILE_W, rng.randf() * TILE_H, rng.randi_range(1, 3), rng.randi_range(1, 3),
				Color(def["b2"][rng.randi() % 2]))

func _snow(img: Image, layer: int, rng: RandomNumberGenerator, def: Dictionary) -> void:
	if layer == 0:
		for i in 6:
			_circle_wrap(img, rng.randf() * TILE_W, rng.randf() * TILE_H, rng.randf_range(19, 33),
				Color(def["b1"][0]), Color(def["b1"][0]).lightened(0.12))
	elif layer == 1:
		for i in 4:
			var base_y := rng.randf() * TILE_H
			for x in TILE_W:
				var y := int(base_y + 8.0 * sin(TAU * 2 * x / TILE_W + i * 2.0))
				for oy in [-TILE_H, 0, TILE_H]:
					_px(img, x, y + oy, Color(def["b1"][1]))
	else:
		for i in 30:
			_streak_wrap(img, rng.randf() * TILE_W, rng.randf() * TILE_H, rng.randi_range(1, 2), rng.randi_range(1, 2),
				Color(def["b2"][rng.randi() % 2]))

func _metal(img: Image, layer: int, rng: RandomNumberGenerator, def: Dictionary) -> void:
	if layer == 0:
		var line := Color(def["b1"][1]).darkened(0.2)
		for y in range(0, TILE_H, 32):
			for x in TILE_W:
				_px(img, x, y, line)
		for x in range(0, TILE_W, 32):
			for y in TILE_H:
				_px(img, x, y, line)
		for gy in range(16, TILE_H, 32):
			for gx in range(16, TILE_W, 32):
				_px(img, gx, gy, Color(def["b2"][1]).lightened(0.2))
	elif layer == 1:
		for band in range(0, TILE_H, 64):
			for x in TILE_W:
				var stripe := int((x + band) / 8) % 2 == 0
				var c := Color(def["b2"][0]) if stripe else Color(def["b1"][1])
				for th in 3:
					_px(img, x, band + th, c.darkened(0.15))
		for i in 5:
			var vx := rng.randf() * TILE_W
			var vy := rng.randf() * TILE_H
			for yy in 6:
				for xx in 10:
					if xx % 2 == 0:
						_px(img, int(vx) + xx, int(vy) + yy, Color(def["b1"][0]))
	else:
		for i in 18:
			_streak_wrap(img, rng.randf() * TILE_W, rng.randf() * TILE_H, rng.randi_range(2, 5), 1,
				Color(def["b2"][0]).darkened(rng.randf() * 0.5))

func _space(img: Image, layer: int, rng: RandomNumberGenerator, def: Dictionary) -> void:
	if layer == 0:
		for i in 4:
			_circle_wrap(img, rng.randf() * TILE_W, rng.randf() * TILE_H, rng.randf_range(20, 40),
				Color(def["b1"][rng.randi() % 2]), Color(def["b1"][0]).lightened(0.1))
		for i in 40:
			_px(img, rng.randi() % TILE_W, rng.randi() % TILE_H, Color(def["b2"][0]).darkened(0.4))
	elif layer == 1:
		for i in 60:
			var b := rng.randf_range(0.3, 1.0)
			_px(img, rng.randi() % TILE_W, rng.randi() % TILE_H, Color(b, b, b * 1.05))
	else:
		for i in 30:
			_streak_wrap(img, rng.randf() * TILE_W, rng.randf() * TILE_H, rng.randi_range(2, 4), 1,
				Color(def["b2"][rng.randi() % 2]))
