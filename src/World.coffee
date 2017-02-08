
class @World
	constructor: ->
		@objects = []
		@gravity = 0.8
		@player_1_controller = new KeyboardController(false)
		# TODO: support both controllers at once
		# with a CoupledController or EitherController
		# @player_2_controller = new KeyboardController(true)
		@player_2_controller = new GamepadController()
		window.addEventListener "hashchange", (e)=>
			@generate()
	
	generate: ->
		window.debug_mode = location.hash.match /debug/
		
		if location.hash.match /test/
			return @generate_test_map()
		
		@objects = []
		
		@objects.push(ground = new Ground({y: 0, h: 1000}))
		block = (cx, cy, w, h)=>
			@objects.push(new Ground({x: cx - w/2, y: cy - h/2, w, h}))
			@objects.push(new Ground({x: -cx - w/2, y: cy - h/2, w, h})) unless cx is 0
		block(0, -100, 50, 100)
		block(200, -250, 50, 150)
		block(400, -250, 250, 50)
		block(500, -250, 50, 150)
		block(800, -125, 50, 150)
		block(1200, -500, 50, 1000)
		
		@objects.push(@player_1 = new Player({x: -150, y: ground.y, face: +1, color: "red", controller: @player_1_controller}))
		@objects.push(@player_2 = new Player({x: +150, y: ground.y, face: -1, color: "aqua", controller: @player_2_controller}))
		@player_1.find_free_position(@)
		@player_2.find_free_position(@)
		@players = [@player_1, @player_2]
	
	step: ->
		for object in @objects
			object.step?(@)
	
	draw: (ctx, view)->
		for object in @objects
			object.draw?(ctx, view)
