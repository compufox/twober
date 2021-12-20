extends Control

var mic
var spectrum
var active: bool = false
var activation_energy = 0.4
var idleTexture: Texture
var activeTexture: Texture
var current = 0.0
var spectrum_delay = 0.05
onready var tween = $tween

signal talking(is_talking)

# Called when the node enters the scene tree for the first time.
func _ready():
	OptionsController.load_options()
	for k in OptionsController.keys():
		_on_settings_updated(k, OptionsController.get(k))
	
	if not OptionsController.get("hide_help"):
		hide_text_after_timer()
	
	if OptionsController.get("idle_img").begins_with("res"):
		idleTexture = $face.texture
		activeTexture = $face.texture
	else:
		idleTexture = OptionsController.texture_from_image(OptionsController.get("idle_img"))
		activeTexture = OptionsController.texture_from_image(OptionsController.get("active_img"))
	
	$face.texture = idleTexture
	
	var idx = AudioServer.get_bus_index("mic")
	mic = AudioServer.get_bus_effect(idx, 0)
	spectrum = AudioServer.get_bus_effect(idx, 1)
	spectrum.set_buffer_length(spectrum_delay)
	
	spectrum = AudioServer.get_bus_effect_instance(idx, 1)
	mic.set_recording_active(true)

func _input(_event):
	if Input.is_action_pressed("open_settings"):
		$SettingsDialog.popup_centered()

func _process(delta):
	current += delta
	
	if current >= spectrum_delay:
		current = 0
		var magnitude = spectrum.get_magnitude_for_frequency_range(0, (17 * 11050.0) / 16).length()
		var energy = clamp((60 + linear2db(magnitude)) / 60, 0, 1)
		if energy > activation_energy and not active:
			active = true
		elif energy < activation_energy and active:
			active = false
	
		emit_signal("talking", active)

func hide_text_after_timer():
	yield(get_tree().create_timer(30), "timeout")
	$helpText.visible = false

# catch settings when they get updated
func _on_settings_updated(name, new_value):
	if name == "bg_color":
		$greenScreen.color = Color(new_value)
	elif name == "idle_img":
		idleTexture = OptionsController.texture_from_image(new_value)
		_on_talking(active)
	elif name == "active_img":
		activeTexture = OptionsController.texture_from_image(new_value)
		_on_talking(active)
	elif name == "hide_help":
		$helpText.visible = not new_value
	elif name == "threshold_amt":
		activation_energy = (new_value / 100)
	elif name == "flip_h":
		$face.flip_h = new_value
	elif name == "flip_v":
		$face.flip_v = new_value


func _on_talking(is_talking):
	if is_talking:
		$face.texture = activeTexture
	else:
		$face.texture = idleTexture
