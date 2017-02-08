
@world = new World()

view = {cx: 0, cy: 0, scale: 2}

view_slowness = 8

paused = no
window.round_started = no
window.round_over = no
remaining_countdown_seconds = 0

countdown_el = document.createElement("div")
document.body.appendChild(countdown_el)
countdown_el.classList.add("countdown")

round_end_el = document.createElement("div")
document.body.appendChild(round_end_el)
round_end_el.classList.add("round-end")

count_down = ->
	if remaining_countdown_seconds > 0
		countdown_el.classList.remove("now-fight")
		countdown_el.textContent = "#{remaining_countdown_seconds}..."
		remaining_countdown_seconds--
		setTimeout count_down, 1000
	else
		countdown_el.textContent = "FIGHT!"
		window.round_started = yes
		countdown_el.classList.add("now-fight")
	console.log countdown_el.textContent

init_round = ->
	window.round_started = false
	window.round_over = false
	round_end_el.textContent = ""
	
	world.generate()
	remaining_countdown_seconds = if location.hash.match(/(quick|fast)( |-|)start/i) then 0 else 3
	count_down()

init_round()

animate ->
	return if loading
	world.step() unless paused
	{players} = world
	view.width = canvas.width
	view.height = canvas.height
	#view_bound_x = canvas.width / 3
	#view_bound_y = canvas.height / 3
	#move_view_to_x = (view.cx + player.x - max(min(player.x, view_bound_x), -view_bound_x))
	#move_view_to_cx = (view.cx + max(min(player.x - view.cx, view_bound_x), -view_bound_x))
	move_view_to_cx = 0
	move_view_to_cy = 0
	for player in players
		move_view_to_cx += player.x
		move_view_to_cy += player.y
	move_view_to_cx /= players.length
	move_view_to_cy /= players.length
	
	move_view_to_cx = min(400*16 - view.width/2, max(-400*16 + view.width/2, move_view_to_cx))
	#move_view_to_cy = min(400*16, max(-400*16, move_view_to_cy))
	view.cx += (move_view_to_cx - view.cx) / view_slowness
	view.cy += (move_view_to_cy - view.cy) / view_slowness
	# ctx.fillStyle = gloom # "#233"
	# ctx.fillRect(0, 0, canvas.width, canvas.height)
	# ctx.fillStyle = sunset
	# ctx.globalAlpha = 0.3
	ctx.fillStyle = "#a9bcd6"
	ctx.fillRect(0, 0, canvas.width, canvas.height)
	# for player in players when player.hitting
	# 	ctx.fillStyle = "rgba(0, 0, 0, 0.1)"
	# 	ctx.fillRect(0, 0, canvas.width, canvas.height)
	ctx.fillStyle = "#000"
	ctx.globalAlpha = min(1, max(0, view.cy / (100*16)))
	ctx.fillRect(0, 0, canvas.width, canvas.height)
	ctx.globalAlpha = 1
	ctx.save()
	ctx.translate(canvas.width/2, canvas.height/2)
	ctx.scale(view.scale, view.scale)
	ctx.translate(-view.cx, -view.cy)
	world.draw(ctx, view)
	ctx.restore()
	ctx.save()
	# ctx.globalCompositeOperation = "screen"
	ctx.fillStyle = "rgba(255, 0, 0, #{player.invincibility/150})"
	ctx.fillRect(0, 0, canvas.width, canvas.height)
	ctx.restore()
	
	for player in players
		if player.y > 100
			player.dead = true
		if player.dead
			unless window.round_over
				window.round_over = true
				setTimeout init_round, 1000
				round_end_el.textContent = "Round over!"


pause = ->
	paused = yes
	document.body.classList.add "paused"

unpause = ->
	paused = no
	document.body.classList.remove "paused"

toggle_pause = ->
	if paused then unpause() else pause()

window.addEventListener "keydown", (e)->
	console.log e.keyCode if e.altKey
	if e.keyCode is 80 # P
		toggle_pause()
