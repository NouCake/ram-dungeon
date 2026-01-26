extends GdUnitTestSuite

func test_find_target():
	var runner := scene_runner("res://test/test_scene_targeting.tscn")

	var player: Node = runner.find_child("player")
	var enemy: Node = runner.find_child("ranged_enemy")
	
	assert_object(player).is_not_null()
	assert_object(enemy).is_not_null()
	assert_array(Targetable.Get(player).tags).contains("player")

	var enemy_detector := TargetDetectorComponent.Get(enemy)
	enemy_detector.search_interval = 0;
	await await_millis(200)

	var enemy_close := enemy_detector.find_all(["player"], 1000, true)
	assert_array(enemy_close).contains(player)

	var enemy_target = enemy_detector.find_closest(["player"], 1000, true)
	
	assert_object(enemy_target).is_not_null()
	assert_object(enemy_target).is_equal(player)

func test_find_target_without_filter():
	var runner := scene_runner("res://test/test_scene_targeting.tscn")

	var player: Node = runner.find_child("player")
	var enemy: Node = runner.find_child("ranged_enemy")
	
	assert_object(player).is_not_null()
	assert_object(enemy).is_not_null()
	assert_array(Targetable.Get(player).tags).contains("player")

	var enemy_detector := TargetDetectorComponent.Get(enemy)
	enemy_detector.search_interval = 0;
	await await_millis(200)

	var enemy_close := enemy_detector.find_all([], 1000, true)
	assert_array(enemy_close).contains(player)

	var enemy_target = enemy_detector.find_closest([], 1000, true)
	
	assert_object(enemy_target).is_not_null()
	assert_object(enemy_target).is_equal(player)

func test_find_target_wrong_filter():
	var runner := scene_runner("res://test/test_scene_targeting.tscn")
	
	var player: Node = runner.find_child("player")
	var enemy: Node = runner.find_child("ranged_enemy")
	
	assert_object(player).is_not_null()
	assert_object(enemy).is_not_null()
	assert_array(player.get_node("targetable").tags).contains("player")

	var enemy_detector := TargetDetectorComponent.Get(enemy)
	enemy_detector.search_interval = 0
	await await_millis(200)

	assert_array(enemy_detector.find_all([], 1000, true)).is_not_empty()
	assert_array(enemy_detector.find_all(["axolotl"], 1000, true)).is_empty()

	var enemy_target = enemy_detector.find_closest(["axolotl"], 1000, true)
	
	assert_object(enemy_target).is_null()
