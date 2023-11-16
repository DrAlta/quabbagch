extends Node2D

const hex_size = 11

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func pointy_hex_corner(center, size, i):
	var angle_deg = 60 * i - 30
	var angle_rad = PI / 180 * angle_deg
	var ret = Vector2(
					center.x + size * cos(angle_rad),
					center.y + size * sin(angle_rad)
				)
#	print("ret:", ret)
	return(ret)

func draw_hex(center, size, color):
	var corners : Array
	for i in range(6):
		corners.append(pointy_hex_corner(center, size, i))
		
	draw_colored_polygon(corners, color)


func axial_round(q, r):
	var qgrid = round(q)
	var rgrid = round(r)
	q -= qgrid; r -= rgrid # remainder
	if abs(q) >= abs(r):
		return [qgrid + round(q + 0.5*r), rgrid]
	else:
		return [qgrid, rgrid + round(r + 0.5*q)]

func pixel_to_pointy_hex(point):
	var q = (sqrt(3)/3 * point.x  -  1.0/3 * point.y) / hex_size
	var r = (                        2.0/3 * point.y) / hex_size
	return axial_round(q, r)

func pointy_hex_to_pixel(q, r):
	var x = hex_size * (sqrt(3) * q  +  sqrt(3)/2 * r)
	var y = hex_size * ( 3.0/2 * r)
	return Vector2(x, y)

func _process(delta):
	update()

func _draw():
	var mouse_hex= pixel_to_pointy_hex(get_local_mouse_position())
	draw_hex(pointy_hex_to_pixel(mouse_hex[0],mouse_hex[1]) , 7, Color.red)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
