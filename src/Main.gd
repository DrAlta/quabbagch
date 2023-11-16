extends Node2D

const hex_size = 11
const bias_vec = Vector2(sqrt(3)/2, 3/2)

const tiles={
	"boarder":[Color("#1c1c1c"), Color.black],
#	"boarder":"",#[Color.darkgray, Color.black],
	"dirt" : [
		Color("#a46647"), #dark
		Color("#bf8d53"),
	],
	"grass":[
		Color("#5d653b"),
		Color("#63763c")
	]
	
}
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var label 
var font

var map := {}

func save_map():
	var save_file = File.new()
	save_file.open("user://map.save", File.WRITE)
	var test = to_json(map)
	#print(test)
	save_file.store_line(test)
	save_file.close()

func load_map():
	print("cheackin for map")
	var saved_map = File.new()
	if not saved_map.file_exists("user://map.save"):
		print("no map file")
		return # Error! We don't have a save to load.
	saved_map.open("user://map.save", File.READ)
	var test=saved_map.get_line()
	#print(test)
	map = parse_json(test)
	saved_map.close()




# Called when the node enters the scene tree for the first time.
func _ready():
	label = Label.new()
	font = label.get_font("")
	load_map()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func pointy_hex_corner(center, size, i):
	var angle_deg = 60 * i - 30
	var angle_rad = PI / 180 * angle_deg
	var ret = Vector2(
					center.x + size * cos(angle_rad),
					center.y + size * sin(angle_rad)
				)
	#print("ret:", ret)
	return(ret)

func calc_s(q , r):
	return(-q-r)

func draw_hex(center, size, color):
	var corners : Array
	for i in range(6):
		corners.append(pointy_hex_corner(center, size, i))
		
	draw_colored_polygon(corners, color)

#	for x in range(6):
#		
#		draw_char (
#			font,
#			pointy_hex_corner(center, size*2/3, x),
#			str(x),
#			"",
#			Color.red
#			)

func axial_round(q, r):
	var qgrid = round(q)
	var rgrid = round(r)
	q -= qgrid; r -= rgrid # remainder
	if abs(q) >= abs(r):
		return [int(qgrid + round(q + 0.5*r)), int(rgrid)]
	else:
		return [int(qgrid), int(rgrid + round(r + 0.5*q))]

func pixel_to_pointy_hex(point):
	var q = (sqrt(3)/3 * point.x  -  1.0/3 * point.y) / hex_size
	var r = (                        2.0/3 * point.y) / hex_size
	return axial_round(q, r)

func pointy_hex_to_pixel(q, r):
	var x = hex_size * (sqrt(3) * q  +  sqrt(3)/2 * r)
	var y = hex_size * ( 3.0/2 * r)
	return Vector2(x, y)

func set_tile(q, r, type):
	q = str(q)
	r = str(r)
	print("setting " + q + ":" + r)
	if q in map:
		map[q][r] = type
	else:
		map[q]={r:type}



func get_tile(q, r):
	q = str(q)
	r = str(r)
	#print("getting")
	if q in map :
#		print("q")
		if r in map[q]:
			#return("boarder")
			return(map[q][r])
		else:
			return("grass")
	else:
		return("grass")

func _draw():
	print("drawing map")
	var mouse_hex= pixel_to_pointy_hex(get_local_mouse_position())
	for q in range(19):
		for r in range(13):
				
			if q % 2 == 1:
				draw_hex(pointy_hex_to_pixel(q,r), hex_size-1, tiles[get_tile(q,r)][0])
			else:
				if r % 2 == 1:
					draw_hex(pointy_hex_to_pixel(q,r), hex_size-1, tiles[get_tile(q,r)][0])
				else:
					draw_hex(pointy_hex_to_pixel(q,r), hex_size-1, tiles[get_tile(q,r)][1])

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		print("mouse button event at ", event.position)
		var mouse_hex= pixel_to_pointy_hex(get_local_mouse_position())
		set_tile(mouse_hex[0],mouse_hex[1],"dirt")
		update()
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_S:
			print("saving map")
			save_map()
