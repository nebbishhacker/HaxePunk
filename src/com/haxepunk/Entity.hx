package com.haxepunk;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
//import flash.utils.getQualifiedClassName;
//import flash.utils.getDefinitionByName;
import com.haxepunk.graphics.Image;

/**
 * Main game Entity class updated by World.
 */
class Entity extends Tweener
{
	/**
	 * If the Entity should render.
	 */
	public var visible:Bool;
	
	/**
	 * If the Entity should respond to collision checks.
	 */
	public var collidable:Bool;
	
	/**
	 * X position of the Entity in the World.
	 */
	public var x:Float;
	
	/**
	 * Y position of the Entity in the World.
	 */
	public var y:Float;
	
	/**
	 * Width of the Entity's hitbox.
	 */
	public var width:Int;
	
	/**
	 * Height of the Entity's hitbox.
	 */
	public var height:Int;
	
	/**
	 * X origin of the Entity's hitbox.
	 */
	public var originX:Int;
	
	/**
	 * Y origin of the Entity's hitbox.
	 */
	public var originY:Int;
	
	/**
	 * The BitmapData target to draw the Entity to. Leave as null to render to the current screen buffer (default).
	 */
	public var renderTarget:BitmapData;
	
	/**
	 * Constructor. Can be usd to place the Entity and assign a graphic and mask.
	 * @param	x			X position to place the Entity.
	 * @param	y			Y position to place the Entity.
	 * @param	graphic		Graphic to assign to the Entity.
	 * @param	mask		Mask to assign to the Entity.
	 */
	public function new(x:Float = 0, y:Float = 0, graphic:Graphic = null, mask:Mask = null) 
	{
		visible = true;
		collidable = true;
		this.x = x;
		this.y = y;
		
		HITBOX = new Mask();
		_point = HXP.point;
		_camera = HXP.point2;
		
		if (graphic) this.graphic = graphic;
		if (mask) this.mask = mask;
		HITBOX.assignTo(this);
		_class = Class(getDefinitionByName(getQualifiedClassName(this)));
	}
	
	/**
	 * Override this, called when the Entity is added to a World.
	 */
	public function added()
	{
		
	}
	
	/**
	 * Override this, called when the Entity is removed from a World.
	 */
	public function removed()
	{
		
	}
	
	/**
	 * Updates the Entity.
	 */
	override public function update() 
	{
		
	}
	
	/**
	 * Renders the Entity. If you override this for special behaviour,
	 * remember to call super.render() to render the Entity's graphic.
	 */
	public function render() 
	{
		if (_graphic && _graphic.visible)
		{
			if (_graphic.relative)
			{
				_point.x = x;
				_point.y = y;
			}
			else _point.x = _point.y = 0;
			_camera.x = FP.camera.x;
			_camera.y = FP.camera.y;
			_graphic.render(renderTarget ? renderTarget : FP.buffer, _point, _camera);
		}
	}
	
	/**
	 * Checks for a collision against an Entity type.
	 * @param	type		The Entity type to check for.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @return	The first Entity collided with, or null if none were collided.
	 */
	public function collide(type:String, x:Float, y:Float):Entity
	{
		if (!_world) return null;
		
		var e:Entity = _world._typeFirst[type];
		if (!collidable || !e) return null;
		
		_x = this.x; _y = this.y;
		this.x = x; this.y = y;
		
		if (!_mask)
		{
			while (e)
			{
				if (x - originX + width > e.x - e.originX
				&& y - originY + height > e.y - e.originY
				&& x - originX < e.x - e.originX + e.width
				&& y - originY < e.y - e.originY + e.height
				&& e.collidable && e != this)
				{
					if (!e._mask || e._mask.collide(HITBOX))
					{
						this.x = _x; this.y = _y;
						return e;
					}
				}
				e = e._typeNext;
			}
			this.x = _x; this.y = _y;
			return null;
		}
		
		while (e)
		{
			if (x - originX + width > e.x - e.originX
			&& y - originY + height > e.y - e.originY
			&& x - originX < e.x - e.originX + e.width
			&& y - originY < e.y - e.originY + e.height
			&& e.collidable && e != this)
			{
				if (_mask.collide(e._mask ? e._mask : e.HITBOX))
				{
					this.x = _x; this.y = _y;
					return e;
				}
			}
			e = e._typeNext;
		}
		this.x = _x; this.y = _y;
		return null;
	}
	
	/**
	 * Checks for collision against multiple Entity types.
	 * @param	types		An Array or Vector of Entity types to check for.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @return	The first Entity collided with, or null if none were collided.
	 */
	public function collideTypes(types:Dynamic, x:Float, y:Float):Entity
	{
		if (!_world) return null;
		var e:Entity;
		var type:String;
		for (type in types)
		{
			if ((e = collide(type, x, y))) return e;
		}
		return null;
	}
	
	/**
	 * Checks if this Entity collides with a specific Entity.
	 * @param	e		The Entity to collide against.
	 * @param	x		Virtual x position to place this Entity.
	 * @param	y		Virtual y position to place this Entity.
	 * @return	The Entity if they overlap, or null if they don't.
	 */
	public function collideWith(e:Entity, x:Float, y:Float):Entity
	{
		_x = this.x; _y = this.y;
		this.x = x; this.y = y;
		
		if (x - originX + width > e.x - e.originX
		&& y - originY + height > e.y - e.originY
		&& x - originX < e.x - e.originX + e.width
		&& y - originY < e.y - e.originY + e.height
		&& collidable && e.collidable)
		{
			if (!_mask)
			{
				if (!e._mask || e._mask.collide(HITBOX))
				{
					this.x = _x; this.y = _y;
					return e;
				}
				this.x = _x; this.y = _y;
				return null;
			}
			if (_mask.collide(e._mask ? e._mask : e.HITBOX))
			{
				this.x = _x; this.y = _y;
				return e;
			}
		}
		this.x = _x; this.y = _y;
		return null;
	}
	
	/**
	 * Checks if this Entity overlaps the specified rectangle.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @param	rX			X position of the rectangle.
	 * @param	rY			Y position of the rectangle.
	 * @param	rWidth		Width of the rectangle.
	 * @param	rHeight		Height of the rectangle.
	 * @return	If they overlap.
	 */
	public function collideRect(x:Float, y:Float, rX:Float, rY:Float, rWidth:Float, rHeight:Float):Bool
	{
		if (x - originX + width >= rX && y - originY + height >= rY
		&& x - originX <= rX + rWidth && y - originY <= rY + rHeight)
		{
			if (!_mask) return true;
			_x = this.x; _y = this.y;
			this.x = x; this.y = y;
			FP.entity.x = rX;
			FP.entity.y = rY;
			FP.entity.width = rWidth;
			FP.entity.height = rHeight;
			if (_mask.collide(FP.entity.HITBOX))
			{
				this.x = _x; this.y = _y;
				return true;
			}
			this.x = _x; this.y = _y;
			return false;
		}
		return false;
	}
	
	/**
	 * Checks if this Entity overlaps the specified position.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @param	pX			X position.
	 * @param	pY			Y position.
	 * @return	If the Entity intersects with the position.
	 */
	public function collidePoint(x:Float, y:Float, pX:Float, pY:Float):Bool
	{
		if (pX >= x - originX && pY >= y - originY
		&& pX < x - originX + width && pY < y - originY + height)
		{
			if (!_mask) return true;
			_x = this.x; _y = this.y;
			this.x = x; this.y = y;
			FP.entity.x = pX;
			FP.entity.y = pY;
			FP.entity.width = 1;
			FP.entity.height = 1;
			if (_mask.collide(FP.entity.HITBOX))
			{
				this.x = _x; this.y = _y;
				return true;
			}
			this.x = _x; this.y = _y;
			return false;
		}
		return false;
	}
	
	/**
	 * Populates an array with all collided Entities of a type.
	 * @param	type		The Entity type to check for.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @param	array		The Array or Vector object to populate.
	 * @return	The array, populated with all collided Entities.
	 */
	public function collideInto(type:String, x:Float, y:Float, array:Dynamic)
	{
		if (!_world) return;
		
		var e:Entity = _world._typeFirst[type];
		if (!collidable || !e) return;
		
		_x = this.x; _y = this.y;
		this.x = x; this.y = y;
		var n:Int = array.length;
		
		if (!_mask)
		{
			while (e)
			{
				if (x - originX + width > e.x - e.originX
				&& y - originY + height > e.y - e.originY
				&& x - originX < e.x - e.originX + e.width
				&& y - originY < e.y - e.originY + e.height
				&& e.collidable && e != this)
				{
					if (!e._mask || e._mask.collide(HITBOX)) array[n ++] = e;
				}
				e = e._typeNext;
			}
			this.x = _x; this.y = _y;
			return;
		}
		
		while (e)
		{
			if (x - originX + width > e.x - e.originX
			&& y - originY + height > e.y - e.originY
			&& x - originX < e.x - e.originX + e.width
			&& y - originY < e.y - e.originY + e.height
			&& e.collidable && e != this)
			{
				if (_mask.collide(e._mask ? e._mask : e.HITBOX)) array[n ++] = e;
			}
			e = e._typeNext;
		}
		this.x = _x; this.y = _y;
		return;
	}
	
	/**
	 * Populates an array with all collided Entities of multiple types.
	 * @param	types		An array of Entity types to check for.
	 * @param	x			Virtual x position to place this Entity.
	 * @param	y			Virtual y position to place this Entity.
	 * @param	array		The Array or Vector object to populate.
	 * @return	The array, populated with all collided Entities.
	 */
	public function collideTypesInto(types:Dynamic, x:Float, y:Float, array:Dynamic)
	{
		if (!_world) return;
		var type:String;
		for (type in types) collideInto(type, x, y, array);
	}
	
	/**
	 * If the Entity collides with the camera rectangle.
	 */
	public var onCamera(getOnCamera, null):Bool;
	private function getOnCamera():Bool
	{
		return collideRect(x, y, FP.camera.x, FP.camera.y, FP.width, FP.height);
	}
	
	/**
	 * The World object this Entity has been added to.
	 */
	public var world(getWorld, null):World;
	private function getWorld():World
	{
		return _world;
	}
	
	/**
	 * Half the Entity's width.
	 */
	public var halfWidth(getHalfWidth, null):Float;
	private function getHalfWidth():Float { return width / 2; }
	
	/**
	 * Half the Entity's height.
	 */
	public var halfHeight(getHalfHeight, null):Float;
	private function getHalfHeight():Float { return height / 2; }
	
	/**
	 * The center x position of the Entity's hitbox.
	 */
	public var centerX(getCenterX, null):Float;
	private function getCenterX():Float { return x - originX + width / 2; }
	
	/**
	 * The center y position of the Entity's hitbox.
	 */
	public var centerY(getCenterY, null):Float;
	private function getCenterY():Float { return y - originY + height / 2; }
	
	/**
	 * The leftmost position of the Entity's hitbox.
	 */
	public var left(getLeft, null):Float;
	private function getLeft():Float { return x - originX; }
	
	/**
	 * The rightmost position of the Entity's hitbox.
	 */
	public var right(getRight, null):Float;
	private function getRight():Float { return x - originX + width; }
	
	/**
	 * The topmost position of the Entity's hitbox.
	 */
	public var top(getTop, null):Float;
	private function getTop():Float { return y - originY; }
	
	/**
	 * The bottommost position of the Entity's hitbox.
	 */
	public var bottom(getBottom, null):Float;
	private function getBottom():Float { return y - originY + height; }
	
	/**
	 * The rendering layer of this Entity. Higher layers are rendered first.
	 */
	public var layer(getLayer, setLayer):Int;
	private function getLayer():Int { return _layer; }
	private function setLayer(value:Int):Int
	{
		if (_layer == value) return _layer;
		if (!_added)
		{
			_layer = value;
			return _layer;
		}
		_world.removeRender(this);
		_layer = value;
		_world.addRender(this);
		return _layer;
	}
	
	/**
	 * The collision type, used for collision checking.
	 */
	public var type(getType, setType):String;
	private function getType():String { return _type; }
	private function setType(value:String):String
	{
		if (_type == value) return _type;
		if (!_added)
		{
			_type = value;
			return _type;
		}
		if (_type) _world.removeType(this);
		_type = value;
		if (value) _world.addType(this);
		return _type;
	}
	
	/**
	 * An optional Mask component, used for specialized collision. If this is
	 * not assigned, collision checks will use the Entity's hitbox by default.
	 */
	public var mask(getMask, setMask):Mask;
	private function getMask():Mask { return _mask; }
	private function setMask(value:Mask):Mask
	{
		if (_mask == value) return value;
		if (_mask) _mask.assignTo(null);
		_mask = value;
		if (value) _mask.assignTo(this);
		return _mask;
	}
	
	/**
	 * Graphical component to render to the screen.
	 */
	public var graphic(getGraphic, setGraphic):Graphic;
	private function getGraphic():Graphic { return _graphic; }
	private function setGraphic(value:Graphic):Graphic
	{
		if (_graphic == value) return value;
		_graphic = value;
		if (value && value._assign != null) value._assign();
		return _graphic;
	}
	
	/**
	 * Adds the graphic to the Entity via a Graphiclist.
	 * @param	g		Graphic to add.
	 */
	public function addGraphic(g:Graphic):Graphic
	{
		if (Std.is(graphic, Graphiclist)) cast(graphic, Graphiclist).add(g);
		else
		{
			var list:Graphiclist = new Graphiclist();
			if (graphic) list.add(graphic);
			graphic = list;
		}
		return g;
	}
	
	/**
	 * Sets the Entity's hitbox properties.
	 * @param	width		Width of the hitbox.
	 * @param	height		Height of the hitbox.
	 * @param	originX		X origin of the hitbox.
	 * @param	originY		Y origin of the hitbox.
	 */
	public function setHitbox(width:Int = 0, height:Int = 0, originX:Int = 0, originY:Int = 0)
	{
		this.width = width;
		this.height = height;
		this.originX = originX;
		this.originY = originY;
	}
	
	/**
	 * Sets the Entity's hitbox to match that of the provided object.
	 * @param	o		The object defining the hitbox (eg. an Image or Rectangle).
	 */
	public function setHitboxTo(o:Dynamic)
	{
		if (Std.is(o, Image) || Std.is(o, Rectangle)) setHitbox(o.width, o.height, -o.x, -o.y);
		else
		{
			if (o.hasOwnProperty("width")) width = o.width;
			if (o.hasOwnProperty("height")) height = o.height;
			if (o.hasOwnProperty("originX") && !Std.is(o, Graphic)) originX = o.originX;
			else if (o.hasOwnProperty("x")) originX = -o.x;
			if (o.hasOwnProperty("originY") && !Std.is(o, Graphic)) originX = o.originY;
			else if (o.hasOwnProperty("y")) originX = -o.y;
		}
	}
	
	/**
	 * Sets the origin of the Entity.
	 * @param	x		X origin.
	 * @param	y		Y origin.
	 */
	public function setOrigin(x:Int = 0, y:Int = 0)
	{
		originX = x;
		originY = y;
	}
	
	/**
	 * Center's the Entity's origin (half width & height).
	 */
	public function centerOrigin()
	{
		originX = width / 2;
		originY = height / 2;
	}
	
	/**
	 * Calculates the distance from another Entity.
	 * @param	e				The other Entity.
	 * @param	useHitboxes		If hitboxes should be used to determine the distance. If not, the Entities' x/y positions are used.
	 * @return	The distance.
	 */
	public function distanceFrom(e:Entity, useHitboxes:Bool = false):Float
	{
		if (!useHitboxes) return Math.sqrt((x - e.x) * (x - e.x) + (y - e.y) * (y - e.y));
		return FP.distanceRects(x - originX, y - originY, width, height, e.x - e.originX, e.y - e.originY, e.width, e.height);
	}
	
	/**
	 * Calculates the distance from this Entity to the point.
	 * @param	px				X position.
	 * @param	py				Y position.
	 * @param	useHitboxes		If hitboxes should be used to determine the distance. If not, the Entities' x/y positions are used.
	 * @return	The distance.
	 */
	public function distanceToPoint(px:Float, py:Float, useHitbox:Bool = false):Float
	{
		if (!useHitbox) return Math.sqrt((x - px) * (x - px) + (y - py) * (y - py));
		return FP.distanceRectPoint(px, py, x - originX, y - originY, width, height);
	}
	
	/**
	 * Calculates the distance from this Entity to the rectangle.
	 * @param	rx			X position of the rectangle.
	 * @param	ry			Y position of the rectangle.
	 * @param	rwidth		Width of the rectangle.
	 * @param	rheight		Height of the rectangle.
	 * @return	The distance.
	 */
	public function distanceToRect(rx:Float, ry:Float, rwidth:Float, rheight:Float):Float
	{
		return FP.distanceRects(rx, ry, rwidth, rheight, x - originX, y - originY, width, height);
	}
	
	/**
	 * Gets the class name as a string.
	 * @return	A string representing the class name.
	 */
	public function toString():String
	{
		var s:String = String(_class);
		return s.substring(7, s.length - 1);
	}
	
	/**
	 * Moves the Entity by the amount, retaining integer values for its x and y.
	 * @param	x			Horizontal offset.
	 * @param	y			Vertical offset.
	 * @param	solidType	An optional collision type to stop flush against upon collision.
	 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
	 */
	public function moveBy(x:Float, y:Float, solidType:String = null, sweep:Bool = false)
	{
		_moveX += x;
		_moveY += y;
		x = Math.round(_moveX);
		y = Math.round(_moveY);
		_moveX -= x;
		_moveY -= y;
		if (solidType)
		{
			var sign:Int, e:Entity;
			if (x != 0)
			{
				if (collidable && (sweep || collide(solidType, this.x + x, this.y)))
				{
					sign = x > 0 ? 1 : -1;
					while (x != 0)
					{
						if ((e = collide(solidType, this.x + sign, this.y)))
						{
							moveCollideX(e);
							break;
						}
						else
						{
							this.x += sign;
							x -= sign;
						}
					}
				}
				else this.x += x;
			}
			if (y != 0)
			{
				if (collidable && (sweep || collide(solidType, this.x, this.y + y)))
				{
					sign = y > 0 ? 1 : -1;
					while (y != 0)
					{
						if ((e = collide(solidType, this.x, this.y + sign)))
						{
							moveCollideY(e);
							break;
						}
						else
						{
							this.y += sign;
							y -= sign;
						}
					}
				}
				else this.y += y;
			}
		}
		else
		{
			this.x += x;
			this.y += y;
		}
	}
	
	/**
	 * Moves the Entity to the position, retaining integer values for its x and y.
	 * @param	x			X position.
	 * @param	y			Y position.
	 * @param	solidType	An optional collision type to stop flush against upon collision.
	 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
	 */
	public function moveTo(x:Float, y:Float, solidType:String = null, sweep:Bool = false)
	{
		moveBy(x - this.x, y - this.y, solidType, sweep);
	}
	
	/**
	 * Moves towards the target position, retaining integer values for its x and y.
	 * @param	x			X target.
	 * @param	y			Y target.
	 * @param	amount		Amount to move.
	 * @param	solidType	An optional collision type to stop flush against upon collision.
	 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
	 */
	public function moveTowards(x:Float, y:Float, amount:Float, solidType:String = null, sweep:Bool = false)
	{
		_point.x = x - this.x;
		_point.y = y - this.y;
		_point.normalize(amount);
		moveBy(_point.x, _point.y, solidType, sweep);
	}
	
	/**
	 * When you collide with an Entity on the x-axis with moveTo() or moveBy().
	 * @param	e		The Entity you collided with.
	 */
	public function moveCollideX(e:Entity)
	{
		
	}
	
	/**
	 * When you collide with an Entity on the y-axis with moveTo() or moveBy().
	 * @param	e		The Entity you collided with.
	 */
	public function moveCollideY(e:Entity)
	{
		
	}
	
	/**
	 * Clamps the Entity's hitbox on the x-axis.
	 * @param	left		Left bounds.
	 * @param	right		Right bounds.
	 * @param	padding		Optional padding on the clamp.
	 */
	public function clampHorizontal(left:Float, right:Float, padding:Float = 0)
	{
		if (x - originX < left + padding) x = left + originX + padding;
		if (x - originX + width > right - padding) x = right - width + originX - padding;
	}
	
	/**
	 * Clamps the Entity's hitbox on the y axis.
	 * @param	top			Min bounds.
	 * @param	bottom		Max bounds.
	 * @param	padding		Optional padding on the clamp.
	 */
	public function clampVertical(top:Float, bottom:Float, padding:Float = 0)
	{
		if (y - originY < top + padding) y = top + originY + padding;
		if (y - originY + height > bottom - padding) y = bottom - height + originY - padding;
	}
	
	// Entity information.
	private var _class:Class;
	private var _world:World;
	private var _added:Bool;
	private var _type:String;
	private var _layer:Int;
	private var _updatePrev:Entity;
	private var _updateNext:Entity;
	private var _renderPrev:Entity;
	private var _renderNext:Entity;
	private var _typePrev:Entity;
	private var _typeNext:Entity;
	private var _recycleNext:Entity;
	
	// Collision information.
	private var HITBOX:Mask;
	private var _mask:Mask;
	private var _x:Float;
	private var _y:Float;
	private var _moveX:Float;
	private var _moveY:Float;
	
	// Rendering information.
	private var _graphic:Graphic;
	private var _point:Point;
	private var _camera:Point;
}