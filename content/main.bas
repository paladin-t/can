REM Canned Monsters - Procedurally generated monsters in a sardines can.
REM Entry program.
REM License: CC-BY.
REM Press Ctrl+R to run.
REM Click a monster to regenerate it.

REM Initializes the driver.

drv = driver()
print drv, ", detail type is: ", typeof(drv);

REM Constants.

' Game stages.
INTRO = 0
LOADING = 1
PLAYING = 2
' Logic.
X_COUNT = 16
Y_COUNT = 12
TOTAL_COUNT = X_COUNT * Y_COUNT

REM Resources.

title_bg = load_resource("title_bg.quantized")
title_txt = load_resource("title_txt.quantized")
sardine = load_resource("sardine.quantized")
arrow_left = load_resource("arrow_left.quantized")
can = load_resource("can.quantized")

REM Variables.

' Logic.
stage = INTRO
t = 0
mouse_down = false
var_x = 0
var_y = 0
gen = nil
monsters = list()

REM Functions.

' Generates one.
def generate_one(i)
	co = coroutine
	(
		lambda ()
		(
			' Initializes the frames.
			srnd(ticks() + tan(i) * 1000)
			cl = rnd(1, 15)
			sprite = load_blank("sprite", 8, 8, 2)
			for var_x = 0 to 7
				for var_y = 0 to 7
					sset sprite, 1, var_x, var_y, cl
					sset sprite, 2, var_x, var_y, cl
				next
			next
			yield
			' Hair or ears.
			for var_x = 0 to 3
				if rnd(100) < 15 then
					sset sprite, 1, var_x, 0, 0
					sset sprite, 1, 7 - var_x, 0, 0
					sset sprite, 2, var_x, 0, 0
					sset sprite, 2, 7 - var_x, 0, 0
				endif
			next
			yield
			' Feet.
			if rnd(100) < 35 then
				for var_x = 0 to 3
					if rnd(100) < 25 then
						sset sprite, 1, var_x, 7, 0
						sset sprite, 1, 7 - var_x, 7, 0
					endif
				next
				for var_x = 0 to 3
					if rnd(100) < 25 then
						sset sprite, 2, var_x, 7, 0
						sset sprite, 2, 7 - var_x, 7, 0
					endif
				next
			else
				for var_x = 0 to 3
					if rnd(100) < 25 then
						sset sprite, 1, var_x, 7, 0
						sset sprite, 2, 7 - var_x, 7, 0
					endif
					sset sprite, 1, 7 - var_x, 7, 0
					sset sprite, 2, var_x, 7, 0
				next
			endif
			yield
			' Shoulders or ankles.
			for var_x = 0 to 2
				if rnd(100) < 15 then
					sset sprite, 1, var_x, 1, 0
					sset sprite, 1, 7 - var_x, 1, 0
					sset sprite, 2, var_x, 1, 0
					sset sprite, 2, 7 - var_x, 1, 0
				endif
			next
			for var_x = 0 to 1
				if rnd(100) < 15 then
					sset sprite, 1, var_x, 6, 0
					sset sprite, 1, 7 - var_x, 6, 0
					sset sprite, 2, var_x, 6, 0
					sset sprite, 2, 7 - var_x, 6, 0
				endif
			next
			yield
			' Eyes.
			var_x = rnd(1, 3)
			var_y = rnd(1, 4)
			sset sprite, 1, var_x, var_y, 7
			sset sprite, 1, 7 - var_x, var_y, 7
			sset sprite, 2, var_x, var_y, 7
			sset sprite, 2, 7 - var_x, var_y, 7
			sset sprite, 1, var_x, var_y + 1, 1
			sset sprite, 1, 7 - var_x, var_y + 1, 1
			sset sprite, 2, var_x, var_y + 1, 1
			sset sprite, 2, 7 - var_x, var_y + 1, 1
			yield
			' Mouth or nose.
			if rnd(100) < 75 then
				var_x = rnd(1, 3)
				var_y = rnd(5, 6)
				sset sprite, 1, var_x, var_y, 8
				sset sprite, 1, 7 - var_x, var_y, 8
			endif
			yield
			' Seals the sprite.
			sprite.play()
			set(monsters, i, sprite)
			gen = nil
		)
	)
	return co
enddef

' Generates all.
def generate_all()
	set_fps(drv, 120, 120)
	start
	(
		coroutine
		(
			lambda ()
			(
				while len(monsters) < TOTAL_COUNT
					push(monsters, nil)
					co = generate_one(len(monsters) - 1)
					while move_next(co)
						yield get(co)
					wend
					yield
				wend
				set_fps(drv, 60, 30)
			)
		)
	)
enddef

' Intro stage.
def title(delta)
	' Ticks.
	t = t + delta
	if not shown then
		d = t * 2
		if d > 1 then
			shown = true
			d = 1
		endif
		by = -30
		ey = (128 - 30) / 2 - 28
		y = by + (ey - by) * d
	endif
	' Shows visuals.
	img title_bg, 0, 0
	img title_txt, (160 - 96) / 2, y
	img sardine, 24, 66
	img sardine, 28, 86
	img sardine, 40, 76
	' Shows tips and accepts input.
	if shown then
		x = 140
		if t * 2 mod 2 then x = 142
		img arrow_left, x, 32
		img arrow_left, x, 80
		touch 0, tx, ty, md
		if md then
			if not mouse_down then
				mouse_down = true
				var_x = tx
				var_y = ty
			endif
		elseif mouse_down then
			mouse_down = false
			tx = tx - var_x
			if tx < 0 then
				t = 160
				stage = LOADING
				sfx 2, 1860, 0.2
				generate_all()
			endif
		endif
	endif
enddef

' Loading stage.
def abroaching(delta)
	' Shows visuals.
	img title_bg, 0, 0
	img title_txt, (160 - 96) / 2, 21
	img sardine, 24, 66
	img sardine, 28, 86
	img sardine, 40, 76
	rectfill t, 0, 159, 127, rgba(0, 0, 0)
	' Ticks.
	t = t - delta * 100
	if t < 0 then
		t = 160
		stage = PLAYING
	endif
enddef

' Playing stage.
def crowding(delta)
	' Shows visuals.
	n = len(monsters)
	img can, 0, 0
	for i = 0 to n - 1
		sprite = get(monsters, i)
		if sprite <> nil then
			x = (i mod X_COUNT + 1) * 9
			y = floor(i / X_COUNT + 1) * 9 + 2
			spr sprite, x, y
		endif
	next
	if t >= 0 then
		t = t - delta * 100
		rectfill 0, 0, t, 127, rgba(0, 0, 0)
	endif
	' Generates new monster when clicked.
	if n < TOTAL_COUNT then return
	touch 0, tx, ty, md
	if md then
		if not mouse_down then
			mouse_down = true
			var_x = tx
			var_y = ty
		endif
	elseif mouse_down then
		mouse_down = false
		var_x = floor(var_x / 9) - 1
		var_y = floor((var_y - 2) / 9) - 1
		if var_x >= 0 and var_x < X_COUNT and var_y >= 0 and var_y < Y_COUNT then
			i = var_x + var_y * X_COUNT
			sfx 1, 1960, 0.05
			gen = generate_one(i)
			start(gen)
		endif
	endif
enddef

' Enters the main loop.
update_with
(
	drv,
	lambda (delta)
	(
		if stage = INTRO then
			title(delta)
		elseif stage = LOADING then
			abroaching(delta)
		elseif stage = PLAYING then
			crowding(delta)
		endif
	)
)
