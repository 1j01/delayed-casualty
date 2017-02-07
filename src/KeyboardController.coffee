
class @KeyboardController
	constructor: (@is_player_2)->
		@prev_keys = {}
		@keys = {}
		window.addEventListener "keydown", (e)=>
			@keys[e.keyCode] = yes
		window.addEventListener "keyup", (e)=>
			delete @keys[e.keyCode]
	
	update: ->
		# arrow keys, WASD, and IJKL
		key_codes =
			right: if @is_player_2 then [39] else [68, 76] # right, D, L
			left: if @is_player_2 then [37] else [65, 74] # left, A, J
			jump: if @is_player_2 then [38] else [87, 73, 32] # up, W, I, space
			descend: if @is_player_2 then [40] else [83, 75] # down, S, K
			genuflect: if @is_player_2 then [17, 90] else [16] # shift, Z, ctrl
		
		pressed = (key)=>
			for keyCode in key_codes[key]
				return yes if @keys[keyCode]?
			return no
		just_pressed = (key)=>
			for keyCode in key_codes[key]
				return yes if @keys[keyCode]? and not @prev_keys[keyCode]?
			return no
		
		@x = pressed("right") - pressed("left")
		@start_jump = just_pressed("jump")
		@extend_jump = pressed("jump")
		@descend = pressed("descend")
		@genuflect = pressed("genuflect")
		
		delete @prev_keys[k] for k, v of @prev_keys
		@prev_keys[k] = v for k, v of @keys
