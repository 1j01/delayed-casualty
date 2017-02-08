
class @World
	constructor: ->
		@objects = []
		@gravity = 0.8
		window.addEventListener "hashchange", (e)=>
			@generate()
	
	generate: ->
		window.debug_mode = location.hash.match /debug/
		
		if location.hash.match /test/
			return @generate_test_map()
		
		@objects = []
		
		@objects.push(ground = new Ground({y: 50}))
		
		@objects.push(@player_1 = new Player({x: -150, y: ground.y, face: +1, color: "red", controller: new KeyboardController(false)}))
		@objects.push(@player_2 = new Player({x: +150, y: ground.y, face: -1, color: "aqua", controller: new KeyboardController(true)}))
		@player_1.find_free_position(@)
		@player_2.find_free_position(@)
		@players = [@player_1, @player_2]
	
	step: ->
		for object in @objects
			object.step?(@)
	
	draw: (ctx, view)->
		for object in @objects
			object.draw?(ctx, view)
