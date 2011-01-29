package com.aircapsule.geom
{
	public class Square extends Shape
	{
		private var _sideLength:Number;
		
		public function Square($sideLength:Number, $strokeColour:uint=0xFF0000, $fillColour:uint=0xCCCCCC, $fillAlpha:Number=0.2)
		{
			super($strokeColour, $fillColour, $fillAlpha);
			_sideLength = $sideLength;
			
			var v:Vector2D = new Vector2D();
			var inc:Vector2D = new Vector2D($sideLength, 0);
			for(var i:uint=0; i<4; ++i){
				_vertices.push(v);
				v = v.addNew(inc);
				
				inc.rotate(Math.PI/2);
			}
		}
	}
}