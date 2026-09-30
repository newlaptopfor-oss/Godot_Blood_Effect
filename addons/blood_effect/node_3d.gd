extends Node3D


@onready var blood_particles: GPUParticles3D = $GPUParticles3D
@onready var camera: Camera3D = $Camera3D


@export var mouse_sensitivity := 0.0025
@export var camera_move_sensitivity := 0.01
@export var camera_zoom_sensitivity := 0.25


# =========================
# BLOOD BASE SETTINGS
# =========================

var base_speed_scale: float
var base_amount: int

var speed_multiplier := 1.0
var amount_multiplier := 1.0

var speed_step := 0.1
var amount_step := 0.25

var always_emitting := false

var camera_pitch := 0.0
var right_mouse_held := false

var instruction_panel: PanelContainer
var speed_label: Label
var amount_label: Label
var emitting_button: Button

var controls_visible := true


func _ready():

	# Current particle settings = BASE
	base_speed_scale = blood_particles.speed_scale
	base_amount = blood_particles.amount

	blood_particles.emitting = false

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	create_instruction_ui()


# =========================================================
# CREATE UI
# =========================================================

func create_instruction_ui():

	var canvas_layer := CanvasLayer.new()
	canvas_layer.name = "InstructionUI"
	add_child(canvas_layer)


	# Main control panel
	instruction_panel = PanelContainer.new()
	instruction_panel.name = "ControlPanel"

	instruction_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)

	# Keep complete panel inside the screen
	instruction_panel.position = Vector2(-385, 10)
	instruction_panel.size = Vector2(365, 0)

	instruction_panel.custom_minimum_size = Vector2(365, 0)

	canvas_layer.add_child(instruction_panel)


	var box := VBoxContainer.new()

	box.add_theme_constant_override(
		"separation",
		4
	)

	instruction_panel.add_child(box)


	# =========================
	# TITLE
	# =========================

	var title := Label.new()

	title.text = "BLOOD EFFECT CONTROLS"

	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	title.add_theme_font_size_override(
		"font_size",
		20
	)

	box.add_child(title)


	# =========================
	# SPEED
	# =========================

	var speed_title := Label.new()

	speed_title.text = "Blood Speed"

	box.add_child(speed_title)


	speed_label = Label.new()

	speed_label.text = "1.00x"

	speed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	speed_label.add_theme_font_size_override(
		"font_size",
		18
	)

	box.add_child(speed_label)


	# =========================
	# AMOUNT
	# =========================

	var amount_title := Label.new()

	amount_title.text = "Blood Amount"

	box.add_child(amount_title)


	amount_label = Label.new()

	amount_label.text = "1.00x"

	amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	amount_label.add_theme_font_size_override(
		"font_size",
		18
	)

	box.add_child(amount_label)


	# =========================
	# EMITTING
	# =========================

	var emitting_title := Label.new()

	emitting_title.text = "Emitting"

	box.add_child(emitting_title)


	emitting_button = Button.new()

	emitting_button.name = "EmittingButton"

	emitting_button.text = "OFF"

	emitting_button.custom_minimum_size = Vector2(0, 35)

	emitting_button.pressed.connect(
		_toggle_always_emitting
	)

	box.add_child(emitting_button)


	# =========================
	# SEPARATOR
	# =========================

	var separator := HSeparator.new()

	box.add_child(separator)


	# =========================
	# BETTER VIEW NOTE
	# =========================

	var view_note := Label.new()

	view_note.name = "BetterViewNote"

	view_note.text = "For better view → Press H to hide controls"

	view_note.position = Vector2(15, 10)

	view_note.add_theme_font_size_override(
		"font_size",
		16
	)

	canvas_layer.add_child(view_note)


	# =========================
	# EMITTING NOTE
	# =========================

	var emitting_note := Label.new()

	emitting_note.name = "EmittingNote"

	emitting_note.text = "SPACE = One Burst | ENTER = Always ON Emmiting"

	emitting_note.position = Vector2(16, 35)

	emitting_note.add_theme_font_size_override(
		"font_size",
		15
	)

	canvas_layer.add_child(emitting_note)
	
	# =========================
	# BLOOD AMOUNT NOTE
	# =========================

	var amount_note := Label.new()

	amount_note.name = "AmountNote"

	amount_note.text = "Press and hold A / D to decrease / increase Blood Amount."

	amount_note.position = Vector2(15, 610)

	amount_note.add_theme_font_size_override(
		"font_size",
		18
	)

	canvas_layer.add_child(amount_note)


	# =========================
	# INSTRUCTIONS
	# =========================

	var instruction_label := Label.new()

	instruction_label.text = """KEYBOARD

Q / E          Blood Speed - / +
A / D          Blood Amount - / +

SPACE          One Blood Burst
ENTER          Emitting Always ON
R              Reset Blood
H              Hide / Show Everything

ESC            Release Mouse

CAMERA

LMB + MOVE     Look Camera
RMB + MOVE     Move Camera
MOUSE WHEEL    Forward / Back"""

	instruction_label.add_theme_font_size_override(
		"font_size",
		14.5
	)

	box.add_child(instruction_label)


	update_ui()


# =========================================================
# SPEED
# =========================================================

func speed_down():

	speed_multiplier -= speed_step

	speed_multiplier = max(
		speed_multiplier,
		0.1
	)

	apply_blood_settings()


func speed_up():

	speed_multiplier += speed_step

	speed_multiplier = min(
		speed_multiplier,
		5.0
	)

	apply_blood_settings()


# =========================================================
# AMOUNT
# =========================================================

func amount_down():

	amount_multiplier -= amount_step

	amount_multiplier = max(
		amount_multiplier,
		0.25
	)

	apply_blood_settings()


func amount_up():

	amount_multiplier += amount_step

	amount_multiplier = min(
		amount_multiplier,
		150.0
	)

	apply_blood_settings()


# =========================================================
# APPLY SETTINGS
# =========================================================

func apply_blood_settings():

	# Speed
	blood_particles.speed_scale = (
		base_speed_scale * speed_multiplier
	)


	# Amount
	var new_amount := int(
		round(
			float(base_amount) * amount_multiplier
		)
	)

	blood_particles.amount = max(
		new_amount,
		1
	)


	update_ui()


# =========================================================
# UPDATE UI
# =========================================================

func update_ui():

	if speed_label:

		speed_label.text = (
			"Speed: %.2fx" % speed_multiplier
		)


	if amount_label:

		amount_label.text = (
			"Amount: %.2fx" % amount_multiplier
		)


# =========================================================
# RESET
# =========================================================

func reset_blood_settings():

	# Reset selected multipliers
	speed_multiplier = 1.0
	amount_multiplier = 1.0

	# Reset actual particle settings
	blood_particles.speed_scale = base_speed_scale
	blood_particles.amount = base_amount

	# Reset emitting
	always_emitting = false

	blood_particles.one_shot = true
	blood_particles.emitting = false

	# Reset button
	if emitting_button:
		emitting_button.text = "OFF"

	# Apply reset values
	# so next SPACE / ENTER uses 1.00x
	apply_blood_settings()

	# Make sure UI shows reset values
	update_ui()


# =========================================================
# EMITTING ON / OFF
# =========================================================

func _toggle_always_emitting():

	always_emitting = not always_emitting

	if always_emitting:

		blood_particles.one_shot = false
		blood_particles.emitting = true

		emitting_button.text = "ON"

	else:

		blood_particles.emitting = false
		blood_particles.one_shot = true

		emitting_button.text = "OFF"


# =========================================================
# PLAY BLOOD
# =========================================================

func play_blood():

	# Apply currently selected settings
	apply_blood_settings()


	# ALWAYS ON MODE
	if always_emitting:

		blood_particles.one_shot = false
		blood_particles.emitting = true

		return


	# ONE BURST MODE
	blood_particles.one_shot = true

	blood_particles.emitting = false

	blood_particles.restart()

	blood_particles.emitting = true


# =========================================================
# HIDE / SHOW EVERYTHING
# =========================================================

func toggle_controls():

	controls_visible = not controls_visible

	var canvas_layer := $InstructionUI

	for child in canvas_layer.get_children():

		child.visible = controls_visible


# =========================================================
# INPUT
# =========================================================

func _input(event):


	# =====================================================
	# MOUSE MOVEMENT
	# =====================================================

	if event is InputEventMouseMotion:

		# RIGHT MOUSE
		# CAMERA POSITION
		if right_mouse_held:

			camera.position.x += (
				event.relative.x
				* camera_move_sensitivity
			)

			camera.position.y -= (
				event.relative.y
				* camera_move_sensitivity
			)


		# NORMAL CAMERA LOOK
		elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:

			# Left / Right
			rotate_y(
				-event.relative.x
				* mouse_sensitivity
			)


			# Up / Down
			camera_pitch -= (
				event.relative.y
				* mouse_sensitivity
			)


			camera_pitch = clamp(
				camera_pitch,
				deg_to_rad(-89.0),
				deg_to_rad(89.0)
			)


			camera.rotation.x = camera_pitch


	# =====================================================
	# MOUSE BUTTONS
	# =====================================================

	if event is InputEventMouseButton:


		# LEFT CLICK
		# CAPTURE MOUSE
		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed:

				Input.set_mouse_mode(
					Input.MOUSE_MODE_CAPTURED
				)


		# RIGHT CLICK
		# CAMERA POSITION MODE
		if event.button_index == MOUSE_BUTTON_RIGHT:

			right_mouse_held = event.pressed


		# =================================================
		# MOUSE WHEEL
		# =================================================

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:

			camera.position.z -= (
				camera_zoom_sensitivity
			)


		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:

			camera.position.z += (
				camera_zoom_sensitivity
			)


	# =====================================================
	# KEYBOARD
	# =====================================================

	if event is InputEventKey:

		if not event.pressed:
			return


		# =================================================
		# ENTER = ALWAYS EMITTING TOGGLE
		# =================================================

		if (
			event.keycode == KEY_ENTER
			or event.keycode == KEY_KP_ENTER
		):

			_toggle_always_emitting()

			return


		# =================================================
		# ESC
		# =================================================

		if event.keycode == KEY_ESCAPE:

			Input.set_mouse_mode(
				Input.MOUSE_MODE_VISIBLE
			)

			right_mouse_held = false


		# =================================================
		# SPACE
		# =================================================

		if event.keycode == KEY_SPACE:

			play_blood()


		# =================================================
		# R = RESET
		# =================================================

		if event.keycode == KEY_R:

			reset_blood_settings()


		# =================================================
		# Q = SPEED DOWN
		# =================================================

		if event.keycode == KEY_Q:

			speed_down()


		# =================================================
		# E = SPEED UP
		# =================================================

		if event.keycode == KEY_E:

			speed_up()


		# =================================================
		# A = AMOUNT DOWN
		# =================================================

		if event.keycode == KEY_A:

			amount_down()


		# =================================================
		# D = AMOUNT UP
		# =================================================

		if event.keycode == KEY_D:

			amount_up()


		# =================================================
		# H = HIDE / SHOW EVERYTHING
		# =================================================

		if event.keycode == KEY_H:

			toggle_controls()
