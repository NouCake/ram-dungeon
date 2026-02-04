## Simple pause system handler.
## Attach to root node or autoload as singleton.
## Press ESC to toggle pause.
extends Node

var is_paused := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # Always process even when paused

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # ESC key
		toggle_pause()

func toggle_pause() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
	
	if is_paused:
		print("Game paused")
		_show_pause_menu()
	else:
		print("Game resumed")
		_hide_pause_menu()

func _show_pause_menu() -> void:
	# TODO: Show pause UI overlay
	# var pause_ui = load("res://ui/pause_menu.tscn").instantiate()
	# pause_ui.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	# add_child(pause_ui)
	pass

func _hide_pause_menu() -> void:
	# TODO: Hide/remove pause UI
	pass
