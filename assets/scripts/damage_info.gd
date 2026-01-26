class_name DamageInfo

enum DamageType { BASIC, FIRE, POISON }

## When null, means environmental damage
var source: Entity
var target: Entity
var type: DamageType = DamageType.BASIC

var amount: int
var knockback_source_position: Vector3
var knockback_amount: float

func _init(_source: Entity, _target: Entity) -> void:
	self.source = _source
	self.target = _target

	amount = 0
	knockback_amount = 0.0
	knockback_source_position = Vector3.ZERO