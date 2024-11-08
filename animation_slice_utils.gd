class_name AnimationSliceUtils

# i'm not sure this way is right?
static func subdivide(divide:int,vecs:Array)->Array:
	if divide<2:
		return vecs
	var per_step = 1.0/divide
	
	var result = []
	
	for i in vecs.size()-1:
		var pt1 = vecs[i]
		var pt2 = vecs[i+1]
		var at = 0
		result.append(pt1)
		for j in divide-1:
			at += per_step
			result.append(pt1.lerp(pt2,at))
		result.append(pt2)

	return result
	
static func rect_center(rect:Rect2,canvas_item:CanvasItem,font:Font,font_size:int,text:String,color:Color,string_size:Vector2 = Vector2.ZERO):
	if string_size == Vector2.ZERO:#for cache
		string_size = get_string_size(font,font_size,text)
		
	var pos = Vector2((rect.size.x - string_size.x)/2,
						(rect.size.y - string_size.y)/2)+rect.position
	point(pos,canvas_item,font,font_size,text,color)
static func point(pt:Vector2,canvas_item:CanvasItem,font:Font,font_size:int,text:String,color:Color,string_size:Vector2 = Vector2.ZERO):

	if string_size == Vector2.ZERO:#for cache
		string_size = get_string_size(font,font_size,text)
	
	var ascent = font.get_ascent  (font_size) # upper
	
	canvas_item.draw_string(font, Vector2(pt.x, pt.y+ascent), text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,color)
	
	return string_size

static func get_string_size(font:Font,font_size:int,text:String):
	return Vector2i(font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size))	

static func draw_text_in_rect(control,rect:Rect2,text:String,font,font_size,color):
	var text_size = AnimationSliceUtils.get_string_size(font,font_size,text)
	
	var pt = Vector2((rect.size.x - text_size.x)/2,
						(rect.size.y - text_size.y)/2)+rect.position
	
	point(pt,control,font,font_size,text,color)

static func get_text_rect(rect:Rect2,text,font,font_size):
	var text_size = AnimationSliceUtils.get_string_size(font,font_size,text)
	var pt = Vector2((rect.size.x - text_size.x)/2,
						(rect.size.y - text_size.y)/2)+rect.position
	return Rect2(pt.x,pt.y,text_size.x,text_size.y)	
	

static func draw_text(control,rect:Rect2,text:String,font,font_size,color):
	var text_size = AnimationSliceUtils.get_string_size(font,font_size,text)
	
	var pt = Vector2((rect.size.x - text_size.x)/2,
						(rect.size.y - text_size.y)/2)+rect.position
	
	AnimationSliceUtils.point(pt,control,font,font_size,text,color)
