extends GdUnitTestSuite

func test_find_target():

	var runner := scene_runner("res://test/test_scene_targeting.tscn")

	var player: Node = runner.find_child("player")
	var enemy: Node = runner.find_child("ranged_enemy")
	
	assert_object(player).is_not_null()
	assert_array(player.get_node("targetable").tags).contains("player")

	assert_object(enemy).is_not_null()

	var enemy_finder := enemy.get_node("finder") as TargetFinderComponent;
	assert_array(enemy_finder.filter).contains("player")

	await await_millis(200)
	var enemy_close := enemy_finder._get_all_near_targets();
	assert_array(enemy_close).contains(player)

	print("Checking enemy target after wait...", enemy_finder._current_target)
	var enemy_target = enemy_finder.get_target()
	
	
	assert_object(enemy_target).is_not_null()
	assert_object(enemy_target).is_equal(player)

func test_find_target_without_filter():

	var runner := scene_runner("res://test/test_scene_targeting.tscn")

	var player: Node = runner.find_child("player")
	var enemy: Node = runner.find_child("ranged_enemy")
	
	assert_object(player).is_not_null()
	assert_array(player.get_node("targetable").tags).contains("player")

	assert_object(enemy).is_not_null()

	var enemy_finder := enemy.get_node("finder") as TargetFinderComponent;
	enemy_finder.filter = []

	await await_millis(200)
	var enemy_close := enemy_finder._get_all_near_targets();
	assert_array(enemy_close).contains(player)

	var enemy_target = enemy_finder.get_target()
	
	
	assert_object(enemy_target).is_not_null()
	assert_object(enemy_target).is_equal(player)

func test_find_target_wrong_filter():

	var runner := scene_runner("res://test/test_scene_targeting.tscn")
	
	var player: Node = runner.find_child("player")
	var enemy: Node = runner.find_child("ranged_enemy")
	
	assert_object(player).is_not_null()
	assert_array(player.get_node("targetable").tags).contains("player")

	assert_object(enemy).is_not_null()

	var enemy_finder := enemy.get_node("finder") as TargetFinderComponent;
	enemy_finder.filter = ["axolotl"]

	await await_millis(200)
	var enemy_close := enemy_finder._get_all_near_targets();
	assert_array(enemy_close).is_empty()

	var enemy_target = enemy_finder.get_target()
	
	assert_object(enemy_target).is_null()
