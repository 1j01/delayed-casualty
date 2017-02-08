
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
	
	move_view_to_cx = 0
	move_view_to_cy = 0
	for player in players
		move_view_to_cx += player.x
		move_view_to_cy += player.y
	move_view_to_cx /= players.length
	move_view_to_cy /= players.length
	
	move_view_to_cx = min(400*16 - canvas.width/2, max(-400*16 + canvas.width/2, move_view_to_cx)) # https://github.com/atom/language-coffee-script/issues/112
	view.cx += (move_view_to_cx - view.cx) / view_slowness
	view.cy += (move_view_to_cy - view.cy) / view_slowness
	
	ctx.fillStyle = "#a9bcd6"
	ctx.fillRect(0, 0, canvas.width, canvas.height)
	
	ctx.save()
	ctx.translate(canvas.width/2, canvas.height/2)
	ctx.scale(view.scale, view.scale)
	ctx.translate(-view.cx, -view.cy)
	world.draw(ctx, view)
	ctx.restore()
	
	for player in players
		if player.y > 100
			player.dead = true
		if player.dead
			unless window.round_over
				window.round_over = true
				setTimeout init_round, 1000
				round_end_el.textContent = "Round over!"
				console.log round_end_el.textContent


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
