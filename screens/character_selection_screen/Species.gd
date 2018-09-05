extends CenterContainer

export (String) var left = "A"
export (String) var right = "D"
export (String) var fire = "1"
export (String) var species = "ROBOLORDS"
export (int) var side = -1

signal selected 

var disabled = false
var selected = false

onready var controls_label=$VBoxContainer/Controls/Label
onready var controls_container=$VBoxContainer/Controls/CenterContainer
onready var character_container=$VBoxContainer/MarginContainer/HBoxContainer/CharacterContainer
onready var characterSprite = $VBoxContainer/MarginContainer/HBoxContainer/CharacterContainer/Sprite
onready var selRectSprite = $VBoxContainer/MarginContainer/HBoxContainer/CharacterContainer/SelRect

func _ready():
	# set shortcut for left and right
	# https://github.com/godotengine/godot/issues/15979
	# left
	var hotkey = InputEventKey.new() 
	if left != "A":
		hotkey.scancode = KEY_LEFT
	else:
		hotkey.scancode = KEY_A
	var shortcut = ShortCut.new()
	shortcut.set_shortcut(hotkey)
	# and then on BaseButton
	$VBoxContainer/MarginContainer/HBoxContainer/Previous.set_shortcut(shortcut)
	
	#right
	hotkey = InputEventKey.new() 
	if right != "D":
		hotkey.scancode = KEY_RIGHT
	else:
		hotkey.scancode = KEY_D
	shortcut = ShortCut.new()
	shortcut.set_shortcut(hotkey)
	# and then on BaseButton
	$VBoxContainer/MarginContainer/HBoxContainer/Next.set_shortcut(shortcut)

	# setting controls for the right species
	$VBoxContainer/Controls/CenterContainer/HBoxContainer/Right/CenterContainer/Panel/Key.text = right
	$VBoxContainer/Controls/CenterContainer/HBoxContainer/Left/CenterContainer/Panel/Key.text = left
	$VBoxContainer/Controls/CenterContainer/HBoxContainer/Fire/CenterContainer/Panel/Key.text = fire
	
	# Called when the node is added to the scene for the first time.
	# Initialization here
	var ship = $VBoxContainer/CenterContainer/NinePatchRect/Sprite
	
	ship.position = Vector2(50,50)
	ship.scale = Vector2(0.5, 0.5)
	characterSprite.position = Vector2(65,200)
	characterSprite.scale = Vector2(0.43, 0.43)
	selRectSprite.position = Vector2(65,200)
	selRectSprite.scale = Vector2(0.43, 0.43)
	
	# adjust selection rect position if flipped
	if side != 0:
		selRectSprite.position = Vector2(55,200)
	
	# set species from available_species
	species = global.available_species[global.chosen_species[name.to_lower()]]
	change_species(species)
	
	# if CPU or fixed choice
	if disabled:
		disable_choice()
	
	# rotate of the ship and flip it
	if side != 0:
		ship.get_node("AnimationPlayer").play("standby")
	else:
		ship.get_node("AnimationPlayer").play_backwards("standby")
	
	ship.flip_h = not side
	characterSprite.flip_h = side
	
	# set controls to keyboard 2 if flipped
	if side != 0:
		$VBoxContainer/Controls/Label.text = 'KEYBOARD 2'

func change_species(new_species):
	species = new_species.to_lower()
	var ship = $VBoxContainer/CenterContainer/NinePatchRect/Sprite
	$VBoxContainer/SpeciesName.text = species.to_upper()
	ship.texture = load("res://actors/"+species+"_ship.png")
	characterSprite.texture = load("res://assets/character_"+species+"_1.png")
	selRectSprite.texture = load("res://assets/character_selection_rect_"+species+".png")
	

func _input(event):
	if event.is_action_pressed(name.to_lower()+"_fire") and not selected:
		disable_choice()
		selected = true
		var i = global.chosen_species[name.to_lower()]
		global.chosen_species[name.to_lower()] = i
		change_species(global.species[i])
		global.available_species.remove(i)
		emit_signal("selected")

func _on_Previous_pressed():
	var a = global.chosen_species[name.to_lower()] - 1
	var b = len(global.available_species)
	var i = mod(a,b)
	global.chosen_species[name.to_lower()] = i
	change_species(global.available_species[i])


func _on_Next_pressed():
	var i = (global.chosen_species[name.to_lower()] + 1) % len(global.available_species)
	global.chosen_species[name.to_lower()] = i
	change_species(global.available_species[i])

func disable_choice():
	$VBoxContainer/MarginContainer/HBoxContainer/Previous.disabled = true
	$VBoxContainer/MarginContainer/HBoxContainer/Next.disabled = true
	$VBoxContainer/MarginContainer/HBoxContainer/Previous.visible = false
	$VBoxContainer/MarginContainer/HBoxContainer/Next.visible = false

func mod(a,b):
	var ret = a%b
	if ret < 0: 
		return ret+b
	else:
		return ret