
class @Player extends MobileEntity
	
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
		@NORMAL_JUMP_VELOCITY ?= 7
		@LONG_WALL_JUMP_X_VELOCITY ?= 8
		@LONG_WALL_JUMP_Y_VELOCITY ?= 8
		@BIG_WALL_JUMP_X_VELOCITY ?= 8
		@BIG_WALL_JUMP_Y_VELOCITY ?= 10
		@HIGH_WALL_JUMP_X_VELOCITY ?= 4
		@HIGH_WALL_JUMP_Y_VELOCITY ?= 8
		# TODO: try having you descend after the wall stick timer runs out
		# and maybe having the descend control kick off downwards
		@DEFAULT_WALL_JUMP_X_VELOCITY ?= 0
		@DEFAULT_WALL_JUMP_Y_VELOCITY ?= 0
		# @DESCEND_WALL_JUMP_X_VELOCITY ?= 2
		# @DESCEND_WALL_JUMP_Y_VELOCITY ?= 1
		@CLIMBING_WALL_JUMP_X_VELOCITY ?= 2.1
		@CLIMBING_WALL_JUMP_Y_VELOCITY ?= 5.5
		
		# @VERTICAL_AIR_CONTROL ?= 0#0.36
		# @HORIZONTAL_AIR_CONTROL ?= 0#0.1
		@VERTICAL_AIR_CONTROL ?= 0.2
		@HORIZONTAL_AIR_CONTROL ?= 0.3
		
		@dead = no
		@sword_health ?= 100
		
		@w ?= 16*1
		@h ?= 16*2
		
		super
		
		@normal_h ?= @h
		@crouched_h ?= @h / 2
		
		@crouched = no
		@sliding = no
		
		@y -= @h
		
		@face ?= 1
		@facing ?= @face
		
		@invincibility = 0
		
		# @liveliness_animation_time = 0
		@run_animation_time = 0
		@animator = new Animator {segments}
		
		@descend = 0
		@descended = no
		@descended_wall = no
		@wall_stick_time = 0
		@sticking_to_wall = no
		@WALL_STICK_TIME = 10
		@GROUND_ACCELERATION = 0.5
		
		@hitting_player = null
		@hit_power = 0
		@attacking = no
		@blocking = no
		@time_until_hit_effect = 0
		@being_hit = no
		
		@swing_radius ?= 70
		@swing_inner_radius ?= 20
		@swing_from_x ?= @w/2
		@swing_from_y ?= @h/5
		@min_time_between_swings = 40
		@time_until_can_swing = 0
		@do_swing = no
		@do_swing_type = null
		
		@swing_effect = no
		@swing_effect_toward_player = null
		@swing_effect_type = null
		
		# @canvas = document.createElement("canvas")
		# @ctx = @canvas.getContext("2d")
	
	step: (world)->
		@invincibility -= 1
		@controller.update()
		if @controller.descend_pressed or (@controller.descend and @descend > 0)
			@descend = 15
		else if @descended_wall
			@descend = 0
			@descended_wall = no
		if @descended
			@descend = 0
			@descended = no
		@descend -= 1
		
		@footing = @collision(world, @x, @y + 1, detecting_footing: yes)
		@grounded = not not @footing
		@against_wall_left = @collision(world, @x - 1, @y) and @collision(world, @x - 1, @y - @h + 5)
		@against_wall_right = @collision(world, @x + 1, @y) and @collision(world, @x + 1, @y - @h + 5)
		@against_wall = @against_wall_left or @against_wall_right
		
		check_for_player_hit = =>
			got_in_the_way = null
			for angle in [0..Math.PI*2] by 0.1
				for radius in [0..@swing_radius] by 5
					x = @x + @swing_from_x + Math.sin(angle) * radius
					y = @y + @swing_from_y + Math.cos(angle) * radius
					for player in world.players when player isnt @
						player = world.collision_point(x, y, type: Player, filter: (player)=> player isnt @)
						if player
							for radius_2 in [0..radius] by 5
								x_2 = @x + @swing_from_x + Math.sin(angle) * radius_2
								y_2 = @y + @swing_from_y + Math.cos(angle) * radius_2
								object = world.collision_point(x_2, y_2, filter: (object)=> object not instanceof Player and not object.hit_thru)
								break if object
							if object
								got_in_the_way = object
							else
								return {hit_player: player}
			return {got_in_the_way}
		
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
				# hitting from the left
				angle_factor = 2 * a - 1
			else
				# hitting from the right
				angle_factor = 1 - a * 2
			
			# TODO: should probably use vector length (or might want to do something else later like just vx or vy)
			# or might not want absolute vertical velocity or whatever
			speed = abs(@vx) + abs(@vy)
			speed_factor = speed / (@max_vx + @max_vy)
			
			dist_factor = dist / @swing_radius # TODO: 1 should probably mean the player's *hitbox* is just within swing distance
			# FIXME: dist_factor can go over 100% (up to ~1.2 currently)
			power = (angle_factor + dist_factor * 2 + speed_factor) / 4
			
			percent = (v)-> (v*100).toFixed() + "%"
			console.log "Power:", percent(power)
			console.log "  Angle factor:", percent(angle_factor)
			console.log "  Dist factor:", percent(dist_factor)
			console.log "  Speed factor:", percent(speed_factor)
			
			return power
		
		take_swing = (hit_type)=>
			{hit_player, got_in_the_way} = check_for_player_hit()
			# TODO: maybe show different feedback if an object got in the way
			
			@swing_effect_type = hit_type
			@swing_effect = true
			
			if hit_player
				@hit_power = calculate_hit_power(hit_player)
				@hit_power += 0.3 if hit_type is "block"
				@hitting_player = hit_player
				@swing_effect_toward_player = hit_player
				hit_player.being_hit = true
				# FIXME: shouldn't really allow extending the hit timer, at least not indefinitely
				hit_player.time_until_hit_effect = @time_until_hit_effect =
					Math.max(hit_player.time_until_hit_effect, @time_until_hit_effect, 30)
				switch hit_type
					when "attack" then @attacking = true
					when "block" then @blocking = true
				@attacking = hit_type is "attack"
				@blocking = hit_type is "block"
			else if got_in_the_way
				console.log "but an object got in the way:", got_in_the_way
			else
				console.log "and misses"
		
		# FIXME: player continues moving when dead
		unless @dead or not round_started
			@face = +1 if @controller.x > 0
			@face = -1 if @controller.x < 0
			
			if @controller.attack_pressed
				console.log "#{@name} attacks"
				console.log "(delayed)" if @time_until_can_swing > 0
				@do_swing = true
				@do_swing_type = "attack"
			
			if @controller.block_pressed
				console.log "#{@name} blocks"
				console.log "(delayed)" if @time_until_can_swing > 0
				@do_swing = true
				@do_swing_type = "block"
			
			if @time_until_can_swing > 0
				@time_until_can_swing--
			else if @do_swing
				@do_swing = false
				@time_until_can_swing = @min_time_between_swings
				take_swing(@do_swing_type)
			
			if @grounded
				if @controller.jump_pressed
					# normal jumping
					@vy = -@NORMAL_JUMP_VELOCITY
					@vx += @controller.x
				else if @controller.genuflect
					unless @crouched
						@h = @crouched_h
						@y += @normal_h - @crouched_h
						@crouched = yes
						@sliding = abs(@vx) > 5
				else
					# normal movement
					@vx += @controller.x * @GROUND_ACCELERATION
			else
				if @against_wall_right
					@face = +1
				if @against_wall_left
					@face = -1
				
				if @against_wall
					if @sticking_to_wall and @descend <= 0 and @vy > -2
						if @wall_stick_time > 0
							@wall_stick_time--
							@vy *= 0.7
						else
							if @against_wall_right
								if @controller.x < 0 and @controller.jump
									@vx = -@BIG_WALL_JUMP_X_VELOCITY
									@vy = -@BIG_WALL_JUMP_Y_VELOCITY
								else if @controller.x < 0
									@vx = -@LONG_WALL_JUMP_X_VELOCITY
									@vy = -@LONG_WALL_JUMP_Y_VELOCITY
								else if @controller.x > 0 and @controller.jump
									@vx = -@CLIMBING_WALL_JUMP_X_VELOCITY
									@vy = -@CLIMBING_WALL_JUMP_Y_VELOCITY
								else if @controller.jump
									@vx = -@HIGH_WALL_JUMP_X_VELOCITY
									@vy = -@HIGH_WALL_JUMP_Y_VELOCITY
								else
									@vx = -@DEFAULT_WALL_JUMP_X_VELOCITY
									@vy = -@DEFAULT_WALL_JUMP_Y_VELOCITY
							else if @against_wall_left
								if @controller.x > 0 and @controller.jump
									@vx = +@BIG_WALL_JUMP_X_VELOCITY
									@vy = -@BIG_WALL_JUMP_Y_VELOCITY
								else if @controller.x > 0
									@vx = +@LONG_WALL_JUMP_X_VELOCITY
									@vy = -@LONG_WALL_JUMP_Y_VELOCITY
								else if @controller.x < 0 and @controller.jump
									@vx = +@CLIMBING_WALL_JUMP_X_VELOCITY
									@vy = -@CLIMBING_WALL_JUMP_Y_VELOCITY
								else if @controller.jump
									@vx = +@HIGH_WALL_JUMP_X_VELOCITY
									@vy = -@HIGH_WALL_JUMP_Y_VELOCITY
								else
									@vx = +@DEFAULT_WALL_JUMP_X_VELOCITY
									@vy = -@DEFAULT_WALL_JUMP_Y_VELOCITY
					else
						@sticking_to_wall = yes
						@wall_stick_time = @WALL_STICK_TIME
				else
					@sticking_to_wall = no
					# air control
					@vx += @controller.x * @HORIZONTAL_AIR_CONTROL
					if @controller.jump
						@vy -= @VERTICAL_AIR_CONTROL
					if @against_wall
						if @descend > 0
							@descended_wall = yes
						else
							@vy *= 0.5 if @vy > 0
			
			if @crouched
				unless @controller.genuflect and @grounded and ((not @sliding) or (@sliding and abs(@vx) > 2))
					# TODO: check for collision before uncrouching
					@h = @normal_h
					@y -= @normal_h - @crouched_h
					@crouched = no
					@sliding = no
		
		super
	
	draw: (ctx, view)->
		@facing += (@face - @facing) / 6
		
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
				if @against_wall
					wall_slide_frame
				else
					air_frame
		
		@animator.weight weighty_frame, 1
		# @animator.weight liveliness_frame, 0.1 unless weighty_frame is run_frame
		# @animator.weight liveliness_frame, 0.3 if weighty_frame in [jump_frame, fall_forwards_frame, fall_downwards_frame]
		
		root_frames = [stand_frame, stand_wide_frame, crouch_frame, slide_frame, wall_slide_frame, air_frame, run_frame]
		draw_height = @normal_h * 1.6
		# draw_resolution_scale = 5
		# @canvas.width = @w * draw_resolution_scale
		# @canvas.height = draw_height * draw_resolution_scale
		# @ctx.save()
		# @ctx.fillStyle = "red"
		# @ctx.fillRect(0, 0, 5, 5)
		# @ctx.fillRect(@canvas.width-5, @canvas.height-5, 5, 5)
		# # @ctx.translate()
		# # @ctx.translate(@w/2, 0)
		# @ctx.translate(-@w, -draw_height)
		# # @ctx.translate(@canvas.width/2 - @w/2, @canvas.height)
		# # @ctx.translate(-@canvas.width/2 + @w/2, -@canvas.height/2)
		# @ctx.translate(@canvas.width/2, @canvas.height)
		# @ctx.scale(draw_resolution_scale, draw_resolution_scale)
		# @animator.draw @ctx, draw_height, root_frames, @face, @facing
		# @ctx.restore()
		
		# ctx.save()
		# # ctx.translate(@x + @w/2, @y + @h + 2)
		# # ctx.translate(@x, @y + @h + 2)
		# # ctx.translate(@x, @y - @canvas.height/2 + 2)
		# ctx.translate(@x, @y - draw_height * 2 + 2)
		# ctx.scale(1/draw_resolution_scale, 1/draw_resolution_scale)
		# ctx.drawImage(@canvas, 0, 0)
		# ctx.restore()
		
		ctx.save()
		ctx.translate(@x + @w/2, @y + @h + 2)
		if @dead
			calc_frame = @animator.calc root_frames, @facing
			
			# TODO: some blood
			# TODO: maybe don't explode so completely ridiculously
			# TODO: place gibs in world coordinates (and probably assume some velocity from the player)
			unless @gibs
				@gibs = for segment in @animator.segments
					placement = calc_frame.dots[segment.a]
					towards = calc_frame.dots[segment.b]
					angle = atan2(towards.y - placement.y, towards.x - placement.x) - TAU/4
					# {x: placement.x, y: placement.y, angle, image: segment.image}
					# {placement, angle, image: segment.image}
					{
						x: placement.x, y: placement.y, angle
						x_vel: rand(-20, 20)
						y_vel: rand(-30, 10)
						angle_vel: rand(-1/3, 1/3)
						image: segment.image
					}
			
			ctx.save()
			ctx.scale(draw_height / calc_frame.height, draw_height / calc_frame.height)
			for gib in @gibs
				ctx.save()
				ctx.translate(gib.x - calc_frame.width/2, gib.y - calc_frame.height)
				ctx.rotate(gib.angle)
				ctx.scale(@face, 1)
				# ctx.translate(-pivot.x+segment.image.width/2, -pivot.y)
				# ctx.drawImage(gib.image, -gib.image.width/2, 0)
				ctx.drawImage(gib.image, -gib.image.width/2, -gib.image.height/2)
				ctx.restore()
				gib.angle += gib.angle_vel
				gib.x += gib.x_vel
				gib.y += gib.y_vel
				gib.y_vel += 1
			ctx.restore()
		else
			@animator.draw ctx, draw_height, root_frames, @face, @facing
		ctx.restore()
	
	draw_fx: (ctx, view)->
		# if @dead
		# 	ctx.save()
		# 	ctx.globalCompositeOperation = "screen"
		# 	ctx.fillStyle = "red"
		# 	ctx.fillRect(@x, @y - 10, @w, @h + 15)
		# 	ctx.restore()
		
		if @swing_effect
			player = @swing_effect_toward_player
			ctx.save()
			ctx.globalAlpha = 0.8
			
			if player
				angle = atan2(player.y - @y, player.x - @x)
				swing_right = player.x > @x
			# NOTE: probably shouldn't be able to attack while wall-sliding (or most characters shouldn't)
			else if @against_wall_left and not @against_wall_right
				angle = atan2(0, +1)
				swing_right = yes
			else if @against_wall_right and not @against_wall_left
				angle = atan2(0, -1)
				swing_right = no
			else
				angle = atan2(0, @face)
				swing_right = @face > 0
			
			arc_length_a = Math.PI * 0.3
			arc_length_b = Math.PI * 0.2
			
			ctx.translate(@x, @y)
			ctx.translate(@swing_from_x, @swing_from_y)
			if swing_right
				ctx.scale(-1, 1)
				angle = TAU/2-angle
			
			if @swing_effect_type is "attack"
				ctx.beginPath()
				
				ctx.arc(0, 0, @swing_radius,
					angle - arc_length_b,
					angle + arc_length_a, false)
				ctx.arc(0, 0, @swing_inner_radius,
					angle + arc_length_a,
					angle - arc_length_b, true)
				
				ctx.fillStyle = if player then "red" else "white"
				ctx.fill()
			else
				block_effect_radius = @swing_radius / 2
				ctx.beginPath()
				ctx.moveTo(
					cos(angle + arc_length_a) * block_effect_radius
					sin(angle + arc_length_a) * block_effect_radius
				)
				ctx.lineTo(
					cos(angle - arc_length_b) * block_effect_radius
					sin(angle - arc_length_b) * block_effect_radius
				)
				ctx.lineWidth = 3
				ctx.strokeStyle = if player then "yellow" else "white"
				ctx.stroke()
			ctx.restore()
			@swing_effect = no
			@swing_effect_toward_player = null
			@swing_effect_type = null
		
		if @time_until_hit_effect > 0
			@time_until_hit_effect--
		else
			if @hitting_player
				console.log @name, "vs", @hitting_player.name
				console.log "power:", @hit_power, "vs", @hitting_player.hit_power
				if @hit_power > @hitting_player.hit_power + 0.001
					if @attacking
						console.log "KILL"
						@hitting_player.dead = true
					else
						console.log "BLOCKED"
				else if @hit_power < @hitting_player.hit_power - 0.001
					if @hitting_player.attacking
						console.log "DEAD"
					else
						console.log "BLOCKED"
				else if @attacking and @hitting_player.attacking
					console.log "LETHAL DRAW"
					@hitting_player.dead = true
				else
					console.log "DRAW"
			
			@hitting_player = null
			setTimeout => # FIXME HACK XXX
				@hit_power = 0
				@blocking = no
				@attacking = no
		
		if window.debug_mode
			ctx.save()
			ctx.fillStyle = @color
			ctx.globalAlpha = 0.3
			ctx.beginPath()
			ctx.arc(@x + @swing_from_x, @y + @swing_from_y, @swing_radius, 0, Math.PI * 2)
			ctx.arc(@x + @swing_from_x, @y + @swing_from_y, @swing_inner_radius, 0, Math.PI * 2, true)
			ctx.fill()
			ctx.fillRect(@x, @y, @w, @h)
			ctx.restore()
		
		ctx.save()
		ctx.font = "12px sans-serif"
		ctx.textAlign = "center"
		ctx.fillStyle = @color
		# ctx.fillText @name, @x + @w/2, @y - @h/2
		# ctx.fillText @name, @x + @w/2, @y + @h * 1.8
		ctx.fillText @name, @x + @w/2, @y + @h + @normal_h * 0.5
		ctx.restore()
		
		# if window.debug_mode
		# 	ctx.save()
		# 	ctx.font = "16px sans-serif"
		# 	ctx.textAlign = "center"
		# 	ctx.fillStyle = "#f0f"
		# 	# ctx.fillText @level_y, @x, @y
		# 	# ctx.fillText @face, @x + @w/2, @y - @h/2
		# 	ctx.fillText @facing, @x + @w/2, @y - @h/2
		# 	ctx.restore()
