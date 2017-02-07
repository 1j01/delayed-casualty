
class @KeyboardController
	constructor: (@is_player_2)->
		@prev_keys = {}
		@keys = {}
		window.addEventListener "keydown", (e)=>
			# console.log e.keyCode
			@keys[e.keyCode] = yes
		window.addEventListener "keyup", (e)=>
			delete @keys[e.keyCode]
	
	update: ->
		# arrow keys, WASD, and IJKL
		# should really specify these without keycodes and corresponding comments
		key_codes =
			right: if @is_player_2 then [39] else [68, 76] # right; D, L
			left: if @is_player_2 then [37] else [65, 74] # left; A, J
			jump: if @is_player_2 then [38] else [87, 73, 32] # up; W, I, space
			descend: if @is_player_2 then [40] else [83, 75] # down; S, K
			attack: if @is_player_2 then [190] else [71] # ., G
			block: if @is_player_2 then [191] else [72] # /, H
			genuflect: if @is_player_2 then [17, 90] else [16] # shift, Z; ctrl
		
		pressed = (key_name)=>
			for key_code in key_codes[key_name]
				return yes if @keys[key_code]?
			return no
		just_pressed = (key_name)=>
			for key_code in key_codes[key_name]
				return yes if @keys[key_code]? and not @prev_keys[key_code]?
			return no
		
		@x = pressed("right") - pressed("left")
		@start_jump = just_pressed("jump")
		@extend_jump = pressed("jump")
		@descend = pressed("descend")
		@attack = just_pressed("attack")
		@block = just_pressed("block")
		@genuflect = pressed("genuflect")
		
		delete @prev_keys[k] for k, v of @prev_keys
		@prev_keys[k] = v for k, v of @keys
