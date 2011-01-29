package com.aircapsule.cd
{
	import com.aircapsule.geom.Vector2D;

	public class SimplexVertex
	{
		protected var _vertexA:Vector2D;
		
		protected var _vertexB:Vector2D;
		
		/**
		 * Barycentric coordinate ratio: u v w 
		 */		
		public var bc:Number=1;
		
		public function SimplexVertex()
		{
		}
		
		public function get vertexA():Vector2D{
			return _vertexA;
		}
		
		public function set vertexA($value:Vector2D):void{
			_vertexA = $value;
		}
		
		public function get vertexB():Vector2D{
			return _vertexB;
		}
		
		public function set vertexB($value:Vector2D):void{
			_vertexB = $value;
		}
		
		public function get vertex():Vector2D{
			return _vertexA.subNew(_vertexB);
		}
		
		public function clone():SimplexVertex{
			var sv:SimplexVertex = new SimplexVertex();
			sv.vertexA = this.vertexA.clone();
			sv.vertexB = this.vertexB.clone();
			return sv;
		}
		
		public function toString():String{
			return "{ vA: "+_vertexA.toString() + "  vb: "+_vertexB.toString()+" }";
		}
	}
}