extends WindowDialog

var configPath = "user://config.json"
var selection_type: String

# NAME will always be a string that relates to the variable name in the config
# NEW_VALUE is variadic, but will always be an appropriate type for the specific variable
signal settings_updated(name, new_value)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_settings_updated(name, new_value):
	## Update config file here
	pass # Replace with function body.


func _on_background_color_changed(color):
	emit_signal("settings_updated", "bg_color", color)


func _on_choose_btn_pressed(which):
	## Update proper textures here
	##  then emit the signal with the correct stuff
	
	selection_type = which + "_img"
	
	$FileDialog.popup_centered()
	


func _on_FileDialog_file_selected(path):
	## Update preview textures in settings
	emit_signal("settings_updated", selection_type, path)
	selection_type = ""
