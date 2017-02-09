
class @World
	constructor: ->
		@objects = []
		@gravity = 0.8
		@player_1_controller = new KeyboardController(false)
		@player_2_controller = new CoupledController(
			new KeyboardController(true)
			new GamepadController()
		)
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
		
		@objects.push(@player_1 = new Player({x: -150, y: ground.y, face: +1, name: "Player 1", color: "#DD4B39", controller: @player_1_controller}))
		@objects.push(@player_2 = new Player({x: +150, y: ground.y, face: -1, name: "Player 2", color: "#3C81F8", controller: @player_2_controller}))
		@player_1.find_free_position(@)
		@player_2.find_free_position(@)
		@players = [@player_1, @player_2]
	
	collision_point: (x, y, {type, filter}={})->
		for object in world.objects
			if type? and object not instanceof type
				continue # as in don't continue with this one
			if filter? and not filter(object)
				continue # as in don't continue with this one
			if (
				x < object.x + object.w and
				y < object.y + object.h and
				x > object.x and
				y > object.y
			)
				return object
	
	step: ->
		for object in @objects
			object.step?(@)
	
	draw: (ctx, view)->
		for object in @objects
			object.draw?(ctx, view)
		for object in @objects
			object.draw_fx?(ctx, view)
