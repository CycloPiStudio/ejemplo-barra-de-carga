extends Node

var loader # cargador 
var wait_frames # dejar frames
var time_max = 100 # msec
var escena_actual # escena actual
# instancio la pantalla de carga 
onready var pantalla_carga = preload("res://Pantallas/Pantalla_de_carga.tscn").instance()

# la escena actual necesita ser recuperada en la función _ready().
# La escena actual (el que tiene el botón) como global.gd son hijos de root,
# pero los nodos autocargados son siempre los primeros. 
# Esto significa que el último hijo de root es siempre la escena cargada (var escena_actual).
func _ready():
	var root = get_tree().get_root()
	escena_actual = root.get_child(root.get_child_count() -1)
	
	
func goto_scene(path): # solicitudes de juego para cambiar a esta escena
	var root = get_tree().get_root()
	# Solicita un cargador interactivo
	loader = ResourceLoader.load_interactive(path)
	if loader == null: # check for errors
#        show_error() # funcion para mostrar que no hay nada q cargar (en construccion)
        return
	set_process(true) # llama set_process(true)para comenzar a sondear el cargador en la _process devolución de llamada.

	escena_actual.queue_free() # deshacerse de la vieja escena

    # comienza tu animación de "cargando ..."
	root.add_child(pantalla_carga)
	root.get_node("Pantalla_de_carga/animation").play("loading")

	wait_frames = 10
	
# _process es donde se sondea el cargador. poll se llama, y ​​luego tratamos con el valor de retorno de esa llamada
# También tenga en cuenta que omitimos un cuadro (a través de wait_frames, configurado en la goto_scenefunción) 
# para permitir que aparezca la pantalla de carga. 

func _process(time):

	if loader == null:
#        # no need to process anymore
#        # ya no es necesario procesar
		set_process(false)
		return

	if wait_frames > 0: # espere a que los marcos permitan que aparezca la animación "cargando"
        wait_frames -= 1
        return

	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max: # usa "time_max" para controlar por cuánto tiempo bloqueamos este hilo

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
	
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	
	# Update your progress bar?
	pantalla_carga.get_node("progress").set_value(progress)
	print(pantalla_carga.get_node("progress").value)
#	get_node("progress").set_progress(progress)
    # ... or update a progress animation?
#	var length = get_node("animation").get_current_animation_length()

    # Call this on a paused animation. Use "true" as the second argument to force the animation to update.
    # Llame a esto en una animación pausada. Use "verdadero" como segundo argumento para forzar la actualización de la animación.
#	get_node("animation").seek(progress * length, true)

func set_new_scene(scene_resource):
	pantalla_carga.get_node("progress").set_value(1)
#	print(pantalla_carga.get_node("progress").value)
	escena_actual = scene_resource.instance()
	get_node("/root").add_child(escena_actual)
	
	pantalla_carga.queue_free() # deshacerse de la pantalla de carga
	