
class @Character extends MobileEntity
	
	run_frames =
		for n in [1..6]
			load_frame "run/#{n}"
	
	images = run_frames.concat [
		stand_frame = load_frame "stand"
		stand_wide_frame = load_frame "stand-wide"
		crouch_frame = load_frame "crouch"
		slide_frame = load_frame "floor-slide"
		jump_frame = load_frame "jump"
		wall_slide_frame = load_frame "wall-slide"
		fall_forwards_frame = load_frame "fall-forwards"
		fall_downwards_frame = load_frame "fall-downwards"
	]
	
	segments = [
		{name: "head", a: "rgb(174, 55, 58)", b: "rgb(253, 31, 43)"}
		{name: "torso", a: "rgb(253, 31, 43)", b: "rgb(226, 0, 19)"}
		{name: "front-upper-arm", a: "rgb(28, 13, 251)", b: "rgb(228, 53, 252)"}
		{name: "front-forearm", a: "rgb(228, 53, 252)", b: "rgb(60, 255, 175)"}
		{name: "front-hand", a: "rgb(60, 255, 175)", b: "rgb(79, 210, 157)"}
		{name: "back-upper-arm", a: "rgb(44, 77, 92)", b: "rgb(93, 43, 91)"}
		{name: "back-forearm", a: "rgb(93, 43, 91)", b: "rgb(44, 152, 40)"}
		{name: "back-hand", a: "rgb(44, 152, 40)", b: "rgb(79, 149, 75)"}
		{name: "front-upper-leg", a: "rgb(226, 0, 19)", b: "rgb(253, 107, 29)"}
		{name: "front-lower-leg", a: "rgb(253, 107, 29)", b: "rgb(224, 239, 105)"}
		{name: "front-foot", a: "rgb(228, 255, 51)", b: "rgb(224, 239, 105)"}
		{name: "back-upper-leg", a: "rgb(226, 0, 19)", b: "rgb(151, 70, 35)"}
		{name: "back-lower-leg", a: "rgb(151, 70, 35)", b: "rgb(126, 119, 24)"}
		{name: "back-foot", a: "rgb(170, 161, 30)", b: "rgb(126, 119, 24)"}
	]
	for segment in segments
		segment.image = load_silhouette "segments/#{segment.name}"
	
	constructor: ->
		@jump_velocity ?= 12
		@jump_velocity_air_control ?= 0.36
		@air_control ?= 0.1
		@sword_health ?= 100
		super
		@normal_h = @h
		@crouched_h = @h / 2
		@crouched = no
		@sliding = no
		@y -= @h
		@invincibility = 0
		# @liveliness_animation_time = 0
		@run_animation_time = 0
		@face = 1
		@facing = 1
		@descend_pressed_last = no
		@descend = 0
		@descended = no
		@descended_wall = no
		@animator = new Animator {segments}
		
		@hitting_player = null
		@hit_power = 0
		@attacking = no
		@blocking = no
		@time_until_hit_effect = 0
		@being_hit = no
		
		@swing_radius = 50
		@swing_inner_radius = 20
		@swing_from_x = @w/2
		@swing_from_y = @h/5
	
	step: (world)->
		@invincibility -= 1
		@controller.update()
		if @controller.descend
			if (not @descend_pressed_last) or @descend > 0
				@descend = 15
		else if @descended_wall
			@descend = 0
			@descended_wall = no
		if @descended
			@descend = 0
			@descended = no
		@descend -= 1
		@descend_pressed_last = @controller.descend
		
		@footing = @collision(world, @x, @y + 1, detecting_footing: yes)
		@grounded = not not @footing
		@against_wall_left = @collision(world, @x - 1, @y) and @collision(world, @x - 1, @y - @h + 5)
		@against_wall_right = @collision(world, @x + 1, @y) and @collision(world, @x + 1, @y - @h + 5)
		
		check_for_player_hit = =>
			for angle in [0..Math.PI*2] by 0.1
				for radius in [0..@swing_radius] by 5
					for player in world.players when player isnt @
						x = @x + @swing_from_x + Math.sin(angle) * radius
						y = @y + @swing_from_y + Math.cos(angle) * radius
						if (
							x < player.x + player.w and
							y < player.y + player.h and
							x > player.x and
							y > player.y
						)
							return player
		
		calculate_hit_power = (player)=>
			
			dist = hypot(
				(player.x + player.swing_from_x) - (@x + @swing_from_x)
				(player.y + player.swing_from_y) - (@y + @swing_from_y)
			)
			angle = atan2(player.y - @y, player.x - @x)
			
			a = angle / TAU
			# we want to transform 3/4..0..1/4 to 0%..100%
			# we want to transform 3/4..1/2..1/4 to 0%..100%
			# we can rotate to simplify
			a = (a - 1/4) %% 1
			# now...
			# we want to transform 0..1/4..1/2 to 0%..100%
			# we want to transform 1..3/4..1/2 to 0%..100%
			if a > 1/2
				# from the left
				angle_factor = 1 - ((1-a) * 2)
			else
				# from the right
				angle_factor = 1 - (a * 2)
			
			# TODO: should probably use vector length (or might want to do something else later like just vx or vy)
			# or might not want absolute vertical velocity or whatever
			speed = abs(@vx) + abs(@vy)
			speed_factor = speed / (@max_vx + @max_vy)
			
			dist_factor = dist / @swing_radius # TODO: 1 should probably mean the player's *hitbox* is just within swing distance, not their center
			power = (angle_factor + dist_factor + speed_factor) / 3
			
			percent = (v)-> (v*100).toFixed() + "%"
			console.log "Power:", percent(power)
			console.log "  Angle factor:", percent(angle_factor)
			console.log "  Dist factor:", percent(dist_factor)
			console.log "  Speed factor:", percent(speed_factor)
			
			return power
		
		take_swing = (hit_type)=>
			hit_player = check_for_player_hit()
			if hit_player
				@hit_power = calculate_hit_power(hit_player)
				@hit_power += 0.2 if hit_type is "block"
				@hitting_player = hit_player
				@swing_effect = true
				hit_player.being_hit = true
				hit_player.time_until_hit_effect = @time_until_hit_effect =
					Math.max(hit_player.time_until_hit_effect, @time_until_hit_effect, 30)
				switch hit_type
					when "attack" then @attacking = true
					when "block" then @blocking = true
			else
				console.log "and misses"
		
		if @controller.attack
			console.log "Player attacks"
			take_swing("attack")
		
		if @controller.block
			console.log "Player blocks"
			take_swing("block")
		
		if @grounded
			if @controller.start_jump
				# normal jumping
				@vy = -@jump_velocity
				@vx += @controller.x
			else if @controller.genuflect
				unless @crouched
					@h = @crouched_h
					@y += @normal_h - @crouched_h
					@crouched = yes
					@sliding = abs(@vx) > 5
			else
				# normal movement
				@vx += @controller.x
		else if @controller.start_jump
			# wall jumping
			if @against_wall_right
				@vx = @jump_velocity * -0.7 unless @controller.x > 0
				@vy = -@jump_velocity
			else if @against_wall_left
				@vx = @jump_velocity * +0.7 unless @controller.x < 0
				@vy = -@jump_velocity
			@face = sign(@vx)
		else
			# air control
			@vx += @controller.x * @air_control
			if @controller.extend_jump
				@vy -= @jump_velocity_air_control
			if @against_wall_right or @against_wall_left
				if @descend > 0
					@descended_wall = yes
				else
					@vy *= 0.5 if @vy > 0
			if @against_wall_right
				@face = +1
			if @against_wall_left
				@face = -1
		
		if @crouched
			unless @controller.genuflect and @grounded and ((not @sliding) or (@sliding and abs(@vx) > 2))
				# TODO: check for collision before uncrouching
				@h = @normal_h
				@y -= @normal_h - @crouched_h
				@crouched = no
				@sliding = no
		
		super
	
	draw: (ctx, view)->
		@face = +1 if @controller.x > 0
		@face = -1 if @controller.x < 0
		@facing += (@face - @facing) / 6
		ctx.save()
		ctx.translate(@x + @w/2, @y + @h + 2)
		
		unless window.animation_data?
			data = {}
			for image in images
				data[image.srcID] = {width: image.width, height: image.height, dots: image.dots}
			window.animation_data = data
			console.log "animation_data = #{JSON.stringify window.animation_data, null, "\t"};\n"
		
		run_frame = @animator.lerp_animation_frames(run_frames, @run_animation_time, "run")
		# liveliness_frame = @animator.lerp_animation_frames(run_frames, @liveliness_animation_time, "liveliness")
		# @liveliness_animation_time += 1/20
		
		fall_frame = @animator.lerp_frames(fall_downwards_frame, fall_forwards_frame, min(1, max(0, abs(@vx)/12)), "fall")
		air_frame = @animator.lerp_frames(jump_frame, fall_frame, min(1, max(0, 1-(6-@vy)/12)), "air")
		
		weighty_frame =
			if @grounded
				if abs(@vx) < 2
					if @crouched
						crouch_frame
					else if @footing?.vx
						stand_wide_frame
					else
						stand_frame
				else
					if @sliding
						slide_frame
					else
						@run_animation_time += abs(@vx) / 60
						run_frame
			else
				@run_animation_time = 0
				if @against_wall_right or @against_wall_left
					wall_slide_frame
				else
					air_frame
		
		@animator.weight weighty_frame, 1
		# @animator.weight liveliness_frame, 0.1 unless weighty_frame is run_frame
		# @animator.weight liveliness_frame, 0.3 if weighty_frame in [jump_frame, fall_forwards_frame, fall_downwards_frame]
		
		root_frames = [stand_frame, stand_wide_frame, crouch_frame, slide_frame, wall_slide_frame, air_frame, run_frame]
		draw_height = @normal_h * 1.6
		@animator.draw ctx, draw_height, root_frames, @face, @facing
		
		if @swing_effect
			ctx.save()
			ctx.beginPath()
			ctx.fillStyle = "white" #@color
			ctx.globalAlpha = 0.8
			player = @hitting_player
			angle = atan2(player.y - @y, player.x - @x)
			# arc_length = Math.PI * 0.7
			arc_length_a = Math.PI * 0.3
			arc_length_b = Math.PI * 0.2
			# ctx.arc(@x + @swing_from_x, @y + @swing_from_y, @swing_radius, angle - arc_length/2, angle + arc_length/2)
			# ctx.arc(@x + @swing_from_x, @y + @swing_from_y, @swing_inner_radius, angle + arc_length/2, angle - arc_length/2, true)
			if player.x > @x
				ctx.arc(@x + @swing_from_x, @y + @swing_from_y, @swing_radius, angle - arc_length_a, angle + arc_length_b)
				ctx.arc(@x + @swing_from_x, @y + @swing_from_y, @swing_inner_radius, angle + arc_length_b, angle - arc_length_a, true)
			else
				ctx.arc(@x + @swing_from_x, @y + @swing_from_y, @swing_radius, angle - arc_length_b, angle + arc_length_a)
				ctx.arc(@x + @swing_from_x, @y + @swing_from_y, @swing_inner_radius, angle + arc_length_a, angle - arc_length_b, true)
			ctx.fill()
			ctx.restore()
			@swing_effect = no
		
		if @time_until_hit_effect > 0
			@time_until_hit_effect--
		else
			# console.log "mkay"
			if @hitting_player
				console.log @color, "vs", @hitting_player.color
				console.log "power:", @hit_power, "vs", @hitting_player.hit_power
				if @hit_power > @hitting_player.hit_power + 0.001
					if @attacking
						console.log "KILL"
					else
						console.log "BLOCKED"
				else if @hit_power < @hitting_player.hit_power - 0.001
					if @hitting_player.attacking
						console.log "DEAD"
					else
						console.log "BLOCKED"
				else
					console.log "DRAW"
			
			@hitting_player = null
			setTimeout => # FIXME HACK XXX
				@hit_power = 0
				@blocking = no
				@attacking = no
		
		if window.debug_mode
			ctx.save()
			ctx.beginPath()
			ctx.fillStyle = @color
			ctx.globalAlpha = 0.3
			ctx.arc(@x + @swing_from_x, @y + @swing_from_y, @swing_radius, 0, Math.PI * 2)
			ctx.arc(@x + @swing_from_x, @y + @swing_from_y, @swing_inner_radius, 0, Math.PI * 2, true)
			ctx.fill()
			ctx.restore()
		
		# if window.debug_mode
		# 	ctx.save()
		# 	ctx.font = "16px sans-serif"
		# 	ctx.fillStyle = "#f0f"
		# 	ctx.fillText @level_y, @x, @y
		# 	ctx.restore()
