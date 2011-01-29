package com.aircapsule.geom
{
	public class Triangle extends Shape
	{
		private var _sideLength:Number;
		
		public function Triangle($sideLength:Number, $strokeColour:uint=0xFF0000, $fillColour:uint=0xCCCCCC, $fillAlpha:Number=0.2)
		{
			super($strokeColour, $fillColour, $fillAlpha);
			_sideLength = $sideLength;
			
			var v:Vector2D = new Vector2D();
			var inc:Vector2D = new Vector2D($sideLength, 0);
			for(var i:uint=0; i<3; ++i){
				_vertices.push(v);
				v = v.addNew(inc);
				
				inc.rotate(Math.PI-Math.PI/3);
			}
			
//			this.rotation = 60;
		}
	}
}