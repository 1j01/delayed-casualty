
class @KeyboardController extends Controller
	constructor: (@is_player_2)->
		super
		# TODO: use `code` instead of `key` when browser support is good
		@keys = {}
		window.addEventListener "keydown", (e)=>
			@keys[e.key] = yes
		window.addEventListener "keyup", (e)=>
			delete @keys[e.key]
	
	update: ->
		keymap =
			right: if @is_player_2 then ["ArrowRight"] else ["D", "L"]
			left: if @is_player_2 then ["ArrowLeft"] else ["A", "J"]
			jump: if @is_player_2 then ["ArrowUp"] else ["W", "I", " "]
			descend: if @is_player_2 then ["ArrowDown"] else ["S", "K"]
			attack: if @is_player_2 then ["."] else ["G"]
			block: if @is_player_2 then ["/"] else ["H"]
			genuflect: if @is_player_2 then ["Shift", "Z"] else ["Control"]
		
		pressed = (control_name)=>
			for key_name in keymap[control_name]
				return yes if @keys[key_name]?
				if key_name.length is 1
					return yes if @keys[key_name.toLowerCase()]?
			return no
		
		@x = pressed("right") - pressed("left")
		@jump = pressed("jump")
		@descend = pressed("descend")
		@attack = pressed("attack")
		@block = pressed("block")
		@genuflect = pressed("genuflect")
		
		super
