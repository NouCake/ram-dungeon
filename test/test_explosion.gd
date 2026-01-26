extends GdUnitTestSuite

# func test_explosion():
# 	var runner := scene_runner("res://test/test_scene_explosion.tscn")

# 	var explosion: Node = runner.find_child("explosion")
# 	var player: Node = runner.find_child("player")
	
# 	assert_object(explosion).is_not_null()
# 	assert_object(player).is_not_null()

# 	var player_health := player.get_node("health") as HealthComponent
# 	var start_health := player_health.current_health

# 	assert_int(start_health).is_greater(0)
# 	await await_millis(100)

# 	var end_health := player_health.current_health
# 	assert_int(end_health).is_less(start_health)
# 	assert_object(explosion).is_null()
