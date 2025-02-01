extends Node

@onready var background_music: AudioStreamPlayer2D = $BackgroundMusic
var current_track = ""  # Track currently playing
var original_volum = 0

func _ready() -> void:
	original_volum = background_music.volume_db

# Function to play background music
func play_music(track_path: String):
	if current_track == track_path:
		return  # Don't restart the same track
		
	# fade out previous music
	if current_track != "": fade_out()

	# Load track dynamically
	current_track = track_path
	background_music.stream = load(track_path)
	
	# Play
	background_music.play()


# Function to fade out music smoothly
func fade_out(duration = 1.5):
	var tween = create_tween()
	tween.tween_property(background_music, "volume_db", -30, duration).from(background_music.volume_db)
	await tween.finished
	background_music.stop()


# Function to lower volum
func lower_volum(duration = 0.1):
	var tween = create_tween()
	tween.tween_property(background_music, "volume_db", original_volum - 30, duration).from(original_volum)
	await tween.finished

func reset_volum(duration = 0.3):
	var current_volum = background_music.volume_db
	
	var tween = create_tween()
	tween.tween_property(background_music, "volume_db", original_volum, duration).from(current_volum)
	await tween.finished
