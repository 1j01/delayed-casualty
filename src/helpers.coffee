
@circle_intersects_rect = (circle, rect)->

	circleDistance_x = abs(circle.x - rect.x)
	circleDistance_y = abs(circle.y - rect.y)

	return false if (circleDistance_x > (rect.w/2 + circle.r))
	return false if (circleDistance_y > (rect.h/2 + circle.r))

	return true if (circleDistance_x <= (rect.w/2))
	return true if (circleDistance_y <= (rect.h/2))

	cornerDistance_sq =
		(circleDistance_x - rect.w/2) ** 2 +
		(circleDistance_y - rect.h/2) ** 2

	(cornerDistance_sq <= circle.r ** 2)

# @dist = (a, b)->
	# dx = a.x - b.x
	# dy = a.x - b.x
@dist = (dx, dy)->
	sqrt(dx*dx + dy*dy)
