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
	OptionsController.set(name, new_value)
	OptionsController.save_options()


func _on_background_color_changed(color):
	emit_signal("settings_updated", "bg_color", color.to_html())


func _on_choose_btn_pressed(which):
	selection_type = which
	$FileDialog.popup_centered()


func _on_FileDialog_file_selected(path):
	## Update preview textures/paths in settings
	if selection_type == "idle":
		$TabContainer/Avatar/AvatarSettings/IdlePreview.texture = OptionsController.texture_from_image(path)
		$TabContainer/Avatar/AvatarSettings/IdleSettings/idlePath.text = path
	else:
		$TabContainer/Avatar/AvatarSettings/TalkingPreview.texture = OptionsController.texture_from_image(path)
		$TabContainer/Avatar/AvatarSettings/TalkingSettings/talkingPath.text = path
		
	
	emit_signal("settings_updated", selection_type + "_img", path)
	selection_type = ""


func _on_hideHelp_toggled(button_pressed):
	emit_signal("settings_updated", "hide_help", button_pressed)


func _on_threshold_value_changed(value):
	$TabContainer/Voice/VBoxContainer/thresholdSettings/Label2.text = String(value) + "%"
	emit_signal("settings_updated", "threshold_amt", value)

# ensure we have the correct values loaded when the user opens us
func _on_about_to_show():
	$TabContainer/Background/BackgroundSettings/helpOptions/hideHelp.pressed = OptionsController.get("hide_help")
	$TabContainer/Background/BackgroundSettings/colorSettings/ColorPicker.color = Color(OptionsController.get("bg_color"))
	for col in OptionsController.get("bg_presets"):
		$TabContainer/Background/BackgroundSettings/colorSettings/ColorPicker.add_preset(Color(col))
	$TabContainer/Voice/VBoxContainer/thresholdSettings/HSlider.value = OptionsController.get("threshold_amt")
	OptionsController.load_texture_onto_node($TabContainer/Avatar/AvatarSettings/IdlePreview, OptionsController.get("idle_img"))
	OptionsController.load_texture_onto_node($TabContainer/Avatar/AvatarSettings/TalkingPreview, OptionsController.get("active_img"))
	$TabContainer/Avatar/AvatarSettings/IdleSettings/idlePath.text = OptionsController.get("idle_img")
	$TabContainer/Avatar/AvatarSettings/TalkingSettings/talkingPath.text = OptionsController.get("active_img")
	$TabContainer/Avatar/AvatarSettings/FlipH/flipHbox.pressed = OptionsController.get("flip_h")
	$TabContainer/Avatar/AvatarSettings/FlipV/flipVbox.pressed = OptionsController.get("flip_v")

# if the user adds/removes a background preset we update our configs
func _on_presets_changed(_color):
	var new_presets = convert_color_presets_to_html($TabContainer/Background/BackgroundSettings/colorSettings/ColorPicker.get_presets())
	emit_signal("settings_updated", "bg_presets", new_presets)


func convert_color_presets_to_html(presets):
	var presets_html = []
	
	for col in presets:
		presets_html.push_back(col.to_html())
	return presets_html


func _on_flipHbox_toggled(button_pressed):
	emit_signal("settings_updated", "flip_h", button_pressed)


func _on_flipVbox_toggled(button_pressed):
	emit_signal("settings_updated", "flip_v", button_pressed)
