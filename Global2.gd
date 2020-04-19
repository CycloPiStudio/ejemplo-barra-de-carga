extends Node

var loader 
var wait_frames
var time_max = 100 # msec
var current_scene
onready var pantalla_carga = preload("res://Pantallas/Pantalla_de_carga.tscn").instance()
func _ready():
    var root = get_tree().get_root()
    current_scene = root.get_child(root.get_child_count() -1)

func goto_scene(path): # solicitudes de juego para cambiar a esta escena
	var root = get_tree().get_root()
	loader = ResourceLoader.load_interactive(path)
	if loader == null: # check for errors
#        show_error()
        return
	set_process(true)

	current_scene.queue_free() # deshacerse de la vieja escena

    # start your "loading..." animation
	root.add_child(pantalla_carga)
	root.get_node("Pantalla_de_carga/animation").play("loading")

	wait_frames = 1
	
###############################################
func _process(time):
	if loader == null:
#        # no need to process anymore
#        # ya no es necesario procesar
		set_process(false)
		return

	if wait_frames > 0: # wait for frames to let the "loading" animation show up
        wait_frames -= 1
        return

	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max: # use "time_max" to control for how long we block this thread

        # poll your loader
        var err = loader.poll()

        if err == ERR_FILE_EOF: # Finished loading.
            var resource = loader.get_resource()
            loader = null
            set_new_scene(resource)
            break
        elif err == OK:
            update_progress()
        else: # error during loading
#            show_error()
            loader = null
            break
########################################
func update_progress():
	var root = get_tree().get_root()
	var progress = float(loader.get_stage()) / loader.get_stage_count()
#	print(progress)
	# Update your progress bar?
	root.get_node("Pantalla_de_carga/progress").value = progress
#	get_node("progress").set_progress(progress)
    # ... or update a progress animation?
#	var length = get_node("animation").get_current_animation_length()

    # Call this on a paused animation. Use "true" as the second argument to force the animation to update.
    # Llame a esto en una animación pausada. Use "verdadero" como segundo argumento para forzar la actualización de la animación.
#	get_node("animation").seek(progress * length, true)

func set_new_scene(scene_resource):
    current_scene = scene_resource.instance()
    get_node("/root").add_child(current_scene)