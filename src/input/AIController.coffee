
class @AIController
	constructor: ->
		@aggro_player = null
		# @otherwise_moving_
	update: ->
		props = ["x", "start_jump", "extend_jump", "descend", "attack", "block", "genuflect"]
		for prop in props
			@[prop] = random() < 0.1
		
		if random() < 0.05
			@aggro_player = choose(player for player in world.players when player isnt @player and not player.dead)
		if random() < 0.02
			@aggro_player = null
		
		if @aggro_player
			@x = sign(@aggro_player.x - @player.x)
		else
			@x = @player.face # heh um sure
