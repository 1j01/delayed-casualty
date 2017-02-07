
class @World
	constructor: ->
		@objects = []
		@gravity = 0.8
		window.addEventListener "hashchange", (e)=>
			@generate()
	
	generate: ->
		window.debug_levels = location.hash.match /debug-levels/
		
		if location.hash.match /test/
			return @generate_test_map()
		
		@objects = []
		
		@objects.push(new Platform({y: 50}))
		
		# @objects.push(@player = new Player({x: 50, y: @objects[0].y}))
		@objects.push(@player_1 = new Player({x: 50, y: 50}))
		@objects.push(@player_2 = new Player({x: 150, y: 50, is_player_2: yes}))
		@player_1.find_free_position(@)
		@player_2.find_free_position(@)
		@players = [@player_1, @player_2]
	
	step: ->
		for object in @objects
			object.step?(@)
	
	draw: (ctx, view)->
		for object in @objects
			object.draw?(ctx, view)
