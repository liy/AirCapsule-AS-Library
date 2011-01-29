package com.aircapsule.geom
{
	public class Vector2D
	{
		public var x:Number=0;
		
		public var y:Number=0;
		
		/**
		 * 
		 * @param $x
		 * @param $y
		 * 
		 */		
		public function Vector2D($x:Number=0, $y:Number=0)
		{
			x = $x;
			y = $y;
		}
		
		/**
		 * 
		 * @param $v
		 * @return 
		 * 
		 */		
		public function addNew($v:Vector2D):Vector2D{
			return new Vector2D(x+$v.x, y+$v.y);
		}
		
		/**
		 * 
		 * @param $v
		 * @return 
		 * 
		 */		
		public function add($v:Vector2D):void{
			this.x += $v.x;
			this.y += $v.y;
		}
		
		/**
		 * 
		 * @param $v
		 * @return 
		 * 
		 */		
		public function subNew($v:Vector2D):Vector2D{
			return new Vector2D(x-$v.x, y-$v.y);
		}
		
		/**
		 * 
		 * @param $v
		 * @return 
		 * 
		 */		
		public function sub($v:Vector2D):void{
			this.x -= $v.x;
			this.y -= $v.y;
		}
		
		/**
		 * 
		 * @param $v
		 * @return 
		 * 
		 */		
		public function dot($v:Vector2D):Number{
			return x*$v.x + y*$v.y;
		}
		
		/**
		 * 
		 * @param $v
		 * @return 
		 * 
		 */		
		public function cross($v:Vector2D):Number{
			return x*$v.y - y*$v.x;
		}
		
		/**
		 * 
		 * @param $s
		 * @return 
		 * 
		 */		
		public function scale($s:Number):void{
			this.x *= $s;
			this.y *= $s;
			
		}
		
		/**
		 * 
		 * @param $s
		 * @return 
		 * 
		 */		
		public function scaleNew($s:Number):Vector2D{
			return new Vector2D(x*$s, y*$s);
		}
		
		/**
		 * Rotate this vector by an angle.
		 * If you want to rotate to a specifc angle use setAngle instead.
		 * <p>
		 * <code>
		 * finalRadian = currentRadian + $radian ----> fr = cr + r</br>
		 * nx = scale&#42;cos(cr+r) ----> nx = scale&#42;cos(cr)&#42;cos(r) - scale&#42;sin(cr)&#42;sin(r)</br>
		 * ny = scale&#42;sin(cr+r) ----> ny = scale&#42;sin(cr)&#42;cos(r) + scale&#42;cos(cr)&#42;sin(r)</br>
		 * x = scale&#42;cos(cr)</br>
		 * y = scale&#42;sin(cr)</br>
		 * SO:</br>
		 * nx = x&#42;cos(r) - y&#42;sin(r)
		 * ny = y&#42;cos(r) + x&#42;sin(r)
		 * </code>
		 * </p>
		 * @param $radian Angle in radian.
		 * 
		 */		
		public function rotate($radian:Number):void{
			var cos:Number = Math.cos($radian);
			var sin:Number = Math.sin($radian);
			
			var nx:Number = x*cos - y*sin;
			var ny:Number = x*sin + y*cos;
			
			x = nx;
			y = ny;
		}
		
		/**
		 * Get a new vector perpendicular to this vector.
		 * 
		 * give you COUNTER CLOCKWISE normal
		 * 
		 * @return A normal vector.
		 * 
		 */
		public function getNormal():Vector2D{
			return new Vector2D(y, -x);
		}
		
		/**
		 * Get a perpendicular vector has the same length towards specific vector. 
		 * @param $v The vector
		 * @return A perpendicular vector toward the vector.
		 * 
		 */				
		public function getPerp($v:Vector2D):Vector2D{
			//if this vector is on the left of $v vector
			if(this.cross($v) > 0){
				return new Vector2D(-y, x);
			}
			//if this vector is on the right of $v vector
			else{
				return new Vector2D(y, -x);
			}
		}
		
		/**
		 * Check a vector is perpendicular to this vector.
		 * If their dot product is 0 (Since cos(0) is 0), then they are
		 * perpendicular to each other.
		 * @param $v A Vector2D instance.
		 * @return True if they are perpendicular to each other.
		 * 
		 */		
		public function isPerpTo($v:Vector2D):Boolean{
			return this.dot($v) == 0;
		}
		
		/**
		 * Set the length of the vector. If current vector's length is 0.
		 * After length is set, the vector will be a[$length, 0], since we assume
		 * that the 0 length vector's angle is 0.
		 * @param $length The target length.
		 * 
		 */		
		public function set length($length:Number):void{
			var len:Number = this.length;
			if(len!=0){
				var scale:Number = $length/len;
				x=x*scale;
				y=y*scale;
			}
			else
				this.x = $length;
		}
		
		/**
		 * Get the length of the vector
		 * @return 
		 * 
		 */		
		public function get length():Number{
			return Math.sqrt(x*x + y*y);
		}
		
		/**
		 * Get the squared length of the vector. 
		 * @return 
		 * 
		 */		
		public function get length2():Number{
			return x*x + y*y;
		}
		
		/**
		 * Make the new vector of length 1.
		 * 
		 */		
		public function getUnit():Vector2D{
			var n:Vector2D = this.clone();
			
			var len:Number = n.length;
			if(len != 0)
				n.scale(1/len);
			else
				n.x = 1;
			
			return n;
		}
		
		/**
		 * Set the vector length to 1/ 
		 * @return This vector
		 * 
		 */		
		public function normalize():Vector2D{
			this.length = 1;
			
			return this;
		}
		
		/**
		 * 
		 * @param $v
		 * @return 
		 * 
		 */		
		public function equalTo($v:Vector2D):Boolean{
			return x == $v.x && y == $v.y;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function isZero():Boolean{
			return x==0 && y==0;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function reverse():Vector2D{
			x=-x;
			y=-y;
			return this;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function clone():Vector2D{
			return new Vector2D(x,y);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function toString():String{
			return "[x: "+x+", y: "+y+"], length: "+this.length;
		}
	}
}