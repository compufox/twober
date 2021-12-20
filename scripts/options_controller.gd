extends Node

var options = {
	bg_color = "00ff10",
	bg_presets = [],
	idle_img = "res://sprites/default.png",
	active_img = "res://sprites/default.png",
	flip_h = false,
	flip_v = false,
	threshold_amt = 0.4,
	hide_help = false
}

func load_options():
	var f = File.new()
	
	if f.open("user://options.json", File.READ) == OK:
		var result = JSON.parse(f.get_as_text())
		
		if result.error == OK:
			options = result.result
		
		f.close()

func save_options():
	var f = File.new()
	
	f.open("user://options.json", File.WRITE)
	var json = JSON.print(options)
	f.store_string(json)
	f.close()

func set(name, value):
	options[name] = value 

func get(name):
	return options[name]

func keys():
	return options.keys()

func texture_from_image(path):
	var new_texture = ImageTexture.new()
	var image = Image.new()
	image.load(path)
	new_texture.create_from_image(image)
	return new_texture

# apply an image from PATH into the texture member of NODE
func load_texture_onto_node(node, path):
	var new_texture = ImageTexture.new()
	var image = Image.new()
	image.load(path)
	new_texture.create_from_image(image)
	node.texture = new_texture
