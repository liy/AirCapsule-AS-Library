package com.aircapsule.geom
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import nl.demonsters.debugger.MonsterDebugger;

	public class Shape extends Sprite
	{
		public static const DEGREE_TO_RADIAN:Number = Math.PI/180;
		
		protected var _vertices:Vector.<Vector2D> = new Vector.<Vector2D>();
		
		protected var _strokeColour:Number;
		
		protected var _fillColour:Number;
		
		protected var _fillAlpha:Number;
			
		public function Shape($strokeColour:uint=0xFF0000, $fillColour:uint=0xCCCCCC, $fillAlpha:Number=0.2)
		{
			_strokeColour = $strokeColour;
			_fillColour = $fillColour;
			_fillAlpha = $fillAlpha;
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
			this.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseUpHandler, false, 0, true);
		}
		
		public function draw():void{
			this.graphics.clear();
			if(_vertices.length == 0){
				return;
			}
			
			this.graphics.beginFill(_fillColour, _fillAlpha);
			this.graphics.lineStyle(1, _strokeColour, _fillAlpha);
			this.graphics.moveTo(_vertices[0].x, _vertices[0].y);
			for(var i:uint=1; i<_vertices.length; ++i){
				this.graphics.lineTo(_vertices[i].x, _vertices[i].y);
			}
			this.graphics.endFill();
		}
		
		public function set vertices($vertices:Vector.<Vector2D>):void{
			_vertices = $vertices;
		}
		
		/**
		 * We need to improve this. But for testing purpose it is ok 
		 * @return 
		 * 
		 */		
		public function get vertices():Vector.<Vector2D>{
			var vertices:Vector.<Vector2D> = new Vector.<Vector2D>();
			for(var i:uint=0; i<_vertices.length; ++i){
				var v:Vector2D = new Vector2D(_vertices[i].x, _vertices[i].y);
				v.rotate(DEGREE_TO_RADIAN*this.rotation);
				v.add(new Vector2D(this.x, this.y));
				vertices.push(v);
			}
			return vertices;
		}
		
		/**
		 * Find a furthest point along the search direction.
		 * WRONG!!!!!!!!
		 * 
		 * @param $d A search direction vector
		 * @return A point furthest along a direction specified by the direction vector. Null, if no point is found.
		 * 
		 */		
//		public function support($from:Vector2D, $d:Vector2D):Vector2D{
//			//use the vertices included rotation and tranlations.
//			var vertices:Vector.<Vector2D> = this.vertices;
//			
//			(parent as Sprite).graphics.clear();
//			(parent as Sprite).graphics.beginFill(0xFF0000, 1);
//			
//			var nd:Vector2D = $d.clone();
//			nd.normalize();
//			var projVs:Vector.<Vector2D> = new Vector.<Vector2D>();
//			var maxProj:Vector2D = new Vector2D(0,0);
//			var maxIndex:int = -1;
//			
//			for(var i:uint=0; i<vertices.length; ++i){
//				if($d.dot(vertices[i].subNew($from)) < 0){
//					continue;
//				}
//				
//				var proj:Vector2D = nd.scaleNew(vertices[i].dot(nd));
//				
//				(parent as Sprite).graphics.drawCircle(proj.x, proj.y, 2);
//				
//				//find the larget length of vector along direct vector d.
//				//p.dot($d) ensure direction is correct pointed to same direction as search direction
//				if(proj.length() > maxProj.length() && proj.dot(nd)>0){
//					maxProj = proj;
//					maxIndex = i;
//				}
//			}
//			
//			(parent as Sprite).graphics.endFill();
//			
//			if(maxIndex == -1){
//				return null;
//			}
//			else{
//				return vertices[maxIndex];
//			}
//		}
		
		/**
		 * Taken from:
		 * 
		 * http://code.google.com/p/gjkd/source/browse/gjkSys.d
		 * Copyright (C) 2007-2008 Mason A. Green  
		 * 
		 * @param $d
		 * @return 
		 * 
		 */		
		public function support($d:Vector2D):Vector2D{
			(parent as Sprite).graphics.beginFill(0xFF0000, 1);
			
			//use the vertices included rotation and tranlations.
			var vertices:Vector.<Vector2D> = this.vertices;
			var furthest:Vector2D;
			var i:int = vertices.length-1;
			furthest = vertices[i--];
			
			//this is achieved by scan all the vector between two vertices, if vector is in the same direct as the
			//search direction(dot >= 0), it will lead us close to the furthest vertex in this shape. If firect is opposite,
			//that means this vertex will not lead to the furthest point, simply jump off this vertex.
			//kind of hill climbing approach
			while(i >= 0){
				//if vector between current two vertices is in the same direct as search direction
				if((vertices[i].subNew(furthest)).dot($d) > 0){
					//the minuend vertex is the furthest point along search direction for now.
					furthest = vertices[i];
				}
				--i;
			}
			
			(parent as Sprite).graphics.drawCircle(furthest.x, furthest.y, 2);
			(parent as Sprite).graphics.endFill();
			
			return furthest;
		}
		
//		public function support($d:Vector2D):Vector2D{
//			var vertices:Vector.<Vector2D> = this.vertices;
//			var bestValue:Number = vertices[0].dot($d);
//			var bestIndex:uint = 0;
//			
//			var len:uint=vertices.length;
//			for(var i:uint=0; i<len; ++i){
//				var value:Number = vertices[i].dot($d);
//				if(value>bestValue){
//					bestValue = value;
//					bestIndex = i;
//				}
//			}
//			
//			return vertices[bestIndex];
//		}
		
		private function mouseDownHandler($e:MouseEvent):void{
			this.startDrag(false);
		}
		
		private function mouseUpHandler($e:MouseEvent):void{
			this.stopDrag();
		}
		
		public function set fillColour($colour:uint):void{
			_fillColour = $colour;
		}
	}
}