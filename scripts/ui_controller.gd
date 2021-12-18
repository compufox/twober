extends Control

var mic
var spectrum
var active: bool = false
export var activation_energy = 0.4

signal talking(is_talking)

# Called when the node enters the scene tree for the first time.
func _ready():
	var idx = AudioServer.get_bus_index("mic")
	mic = AudioServer.get_bus_effect(idx, 0)
	spectrum = AudioServer.get_bus_effect(idx, 1)
	spectrum.set_buffer_length(0.5)
	
	spectrum = AudioServer.get_bus_effect_instance(idx, 1)
	mic.set_recording_active(true)

func _input(event):
	if Input.is_action_pressed("open_settings"):
		$SettingsDialog.popup_centered()

func _process(delta):
	var prev_hz = 0
	for i in range(1, 17):
		var hz = i * 11050.0 / 16
		var magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy = clamp((60 + linear2db(magnitude)) / 60, 0, 1)
		if energy > activation_energy and not active:
			active = true
			emit_signal("talking", true)
		elif energy < activation_energy and active:
			active = false
			emit_signal("talking", false)


# catch settings when they get updated
func _on_settings_updated(name, new_value):
	if name == "bg_color":
		$greenScreen.color = new_value
	elif name == "idle_img":
		var new_texture = ImageTexture.new()
		var image = Image.new()
		image.load(new_value)
		new_texture.create_from_image(image)
		$idleFace.texture = new_texture


func _on_talking(is_talking):
	if is_talking:
		$idleFace.visible = false
		$activeFace.visible = true
	else:
		$idleFace.visible = true
		$activeFace.visible = false
