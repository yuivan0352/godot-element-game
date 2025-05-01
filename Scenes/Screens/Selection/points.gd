extends Label

@onready var statAllocation = $"../StatAllocationMenu"

func _ready() -> void:
	self.text = "points: " + str(statAllocation.points)

func _on_points_changed(name: Variant, count: Variant) -> void:
	self.text = "points: " + str(statAllocation.points)
