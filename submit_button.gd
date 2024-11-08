extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#self.pressed.connect(func():print(disabled))
	pass # Replace with function body.

func _set_disabled(_disabled):
	self.disabled = _disabled
	queue_redraw()

func arc():
	var rect = get_rect()
	rect.position = Vector2.ZERO
	rect = rect.grow(0)
	
	
	var polygons = []
	polygons.append(rect.position)
	polygons.append(rect.position+Vector2(rect.size.x,0))
	polygons.append(rect.end)
	polygons.append(rect.position+Vector2(0,rect.size.y))
	polygons.append(polygons[0])
	
	polygons = AnimationSliceUtils.subdivide(6,polygons)
	
	
	
	var step = polygons.size()-1
	var animation_time = 1.0
	var per_time = animation_time/step
	
	var base_width = 5
	for j in polygons.size()-1:
		draw_animation_slice(animation_time,j*per_time,(j+1)*per_time)
		#var colors = []
		
		var color = Color.WHITE
		for i in polygons.size()-1:
			
			var index = (i+j)% (polygons.size()-1)
			
			var width = base_width - index
			#print("width = %s index = %s i= %s j=%s"%[width,index,i,j])
			
			#var color = gradient.sample(1.0/polygons.size()*(index+1))
			#colors.append(color)
			#print(width)
			if width > 0:
				draw_line(polygons[i],polygons[i+1],color,width)
	
func _draw():
	if disabled:
		arc()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
