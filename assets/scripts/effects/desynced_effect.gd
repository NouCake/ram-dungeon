## Desynced effect: flips enemy↔ally targeting for all actions on target entity.
## Only restores original if targeting_override wasn't changed by another effect.
class_name DesyncedEffect

extends Effect

## Store original strategies to restore on expire
var _modified_actions: Dictionary = {}  # action -> {original_override, original_filters}

func _init() -> void:
	effect_type = "Desynced"
	duration = 5.0
	refresh_on_reapply = true

func _on_applied() -> void:
	print("Applying Desynced effect to " + target.name)
	
	# Find all BaseActionTargeting actions on target
	for child in target.get_children():
		if child is BaseActionTargeting:
			var action := child as BaseActionTargeting
			
			# Store original state
			_modified_actions[action] = {
				"original_override": action.targeting_override,
				"original_filters": action.target_filters.duplicate()
			}
			
			# Flip filters
			if action.target_filters.has("enemy"):
				print("  - Flipping " + action.name + ": enemy→ally")
				action.target_filters = ["ally"]
			elif action.target_filters.has("ally"):
				print("  - Flipping " + action.name + ": ally→enemy")
				action.target_filters = ["enemy"]

func _on_expired() -> void:
	print("Removing Desynced effect from " + target.name)
	
	# Restore original state only if not overwritten by another effect
	for action in _modified_actions.keys():
		if not is_instance_valid(action):
			continue
		
		var stored = _modified_actions[action]
		
		# Only restore if targeting_override is still what we set (or null)
		# If another effect changed it, leave it alone
		if action.targeting_override == stored["original_override"]:
			action.target_filters = stored["original_filters"]
			print("  - Restored " + action.name)
		else:
			print("  - Skipped " + action.name + " (override was changed by another effect)")
	
	_modified_actions.clear()
