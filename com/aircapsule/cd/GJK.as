package com.aircapsule.cd
{
	import com.aircapsule.geom.Shape;
	import com.aircapsule.geom.Vector2D;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import nl.demonsters.debugger.MonsterDebugger;

	public class GJK extends Sprite
	{
		protected var _shape1:Shape;
		
		protected var _shape2:Shape;
		
		protected var _simplex:Simplex;
		
		protected var _container:Sprite;
		
		protected var _tolerence:Number = 0.1;
		
		protected var _collide:Boolean = false;
		
		
		protected var _fields:Vector.<TextField> = new Vector.<TextField>();
		
		public function GJK($container:Sprite, $shape1:Shape, $shape2:Shape)
		{
			_shape1 = $shape1;
			_shape2 = $shape2;
			_container = $container;
			
			this.graphics.clear();
		}
		
		public function start():void{
			this.removeFields();
			
			_collide = false;
			//initialize the simplex
			//TODO: warm start from the previous cached simplex
			_simplex = new Simplex();
			//add the simplex with one random point in the minkowski difference
			var rv1:Vector2D = _shape1.vertices[0];
			var rv2:Vector2D = _shape2.vertices[0];
			var R:SimplexVertex = new SimplexVertex();
			R.vertexA = rv1;
			R.vertexB = rv2;
			_simplex.a = R;
			
			
			
			
			
			//start solving the simplex. 
			for(var i:uint=0; i<7; ++i){
				//store old simplex, for duplication test.
				var oldVertices:Vector.<Vector2D> = _simplex.vertices;
				
				//reducing the simplex... check which region of the O lies in the simplex's voronoi region.
				//then reduce the simplex vertices to the minimum subset of the original simplex vertice set.
				//triangle simplex
				if(_simplex.length == 3){
					_simplex.updateTriangle();
				}
				//line simplex
				else if(_simplex.length == 2){
					_simplex.updateLine();
				}
				else{
					//0-simplex, the point itself is the P, the minimum norm of the simplex
					//so we can take the Point's reverse vector as the serach direction then calculate the support point S,
					//put it into the simplex, waiting for next loop to solve the line simplex.
					//so, simply do nothing here
					_simplex.updatePoint();
				}
				
				
				
				//if the simplex is a triangle, then it means two shape collide!
				if(_simplex.length == 3){
					_collide = true;
					return;
				}
				
				
				//near enough, then two object colide.
				if(_simplex.P.length() < _tolerence){
					_collide = true;
					return;
				}
				
				
				//calculate the new support point.
				var S:SimplexVertex = support();
				
//				this.createText(i+"", S.vertex.x, S.vertex.y);
				
				
				//touch collide
				if(S.vertex.isZero()){
					_collide = true;
					return;
				}
				
				//search duplication. if duplication is found, then we got the furthest point
				for each(var oldV:Vector2D in oldVertices){
					//we found a duplcated point, then we reaching the furthest point, so there is no intersection
					//and the current _P's length is two objects' distance.
					if(oldV.equalTo(S.vertex)){
						_collide = false;
						
						return;
					}
				}
				
				
				//we pass all test then we update the simplex to include the new support point, waiting for next loop to check validation and reduce it.
				_simplex.assignSimplexVertex(S);
				
				
			}
			
			this.graphics.endFill();
		}
		
//		/**
//		 * Update search direction, simplex, and the minimum norm P of the updated simplex 
//		 * 
//		 * 
//		 */
//		private function solveLineSimplex():void{
//			var AO:Vector2D = _simplex[1].clone();
//			AO.reverse();
//			var AB:Vector2D = _simplex[0].subNew(_simplex[1]);
//			//region 2
//			if(AO.dot(AB) > 0){
//				//simplex has no changes
//				
//				//update minimum norm, it is the projection of O
//				var n:Vector2D = AB.clone();
//				n.normalize();
//				_P = n.scaleNew(AO.dot(n)).subNew(AO);
//				
//				//update search direction
//				_sd = AB.getPerp(AO);
//			}
//			//region 1
//			else{
//				//update simplex
//				_simplex = new Array(_simplex[1].clone());
//				
//				//update minimun norm, 0-simplex itself is the minimum norm
//				_P = _simplex[0].clone();
//				
//				//search towards origin
//				_sd = AO.clone();
//				
//			}
//		}
//		
//		private function solveTriangleSimplex():void{
//			//using barycentric coordinate
//			var A:Vector2D = _simplex[2];
//			var B:Vector2D = _simplex[1];
//			var C:Vector2D = _simplex[0];
//			
//			// Calculate barycentric coordinate v and w. (P is the origin)
//			//
//			// P = uA + vB + wC, and because u = 1-v-w, therefore:
//			// P = (1-v-w)A + vB + wC = A + v(B-A) + w(C-A)  ===>   v(B-A) + w(C-A) = P-A
//			// replace vector: B-A, C-A, and P-A with v0, v1 and v2, the we get:
//			//		v*v0 + w*v1 = v2.
//			// If we dot two sides with v0 and v1, we get two equations:
//			//		v*(v0.v0) + w*(v1.v0) = v2.v0
//			//		v*(v0.v1) + w*(v1.v1) = v2.v1
//			//
//			// we can form a matrix multiplication here:
//			// 		[d00 d10]  *  [v]  =  [d20] 
//			//		[d01 d11]     [w]     [d21]
//			// d00 is the dot product: v0.v0, others "dxx" variable are represented as similar dot product.
//			//
//			// Therefore, we can use "Caramer's rule" to solve v and w, and u = 1 - v - w
//			// 		v = |d20 d10|  /  |d00 d10|  
//			//			|d21 d11|     |d01 d11|
//			//
//			// 		w = |d00 d20|  /  |d00 d10|
//			//			|d01 d21|	  |d01 d11|
//			// Note that: d01 == d10, d21 == d12, d20 == d02
//			//
//			//
//			//
//			// We can also use another system:
//			// 		u*Ax + v*Bx + w*Cx = Px
//			// 		u*Ay + v*By + w*Cy = Py
//			// 		u + v + w = 1
//			// Using Caramer's rule, we will be able to get u, v and w.
//			
//			//v0
//			var AB:Vector2D = B.subNew(A);
//			//v1
//			var AC:Vector2D = C.subNew(A);
//			//v2
//			var AO:Vector2D = A.clone();
//			AO.reverse();
//			
//			var d00:Number = AB.dot(AB);
//			var d10:Number = AC.dot(AB);
//			var d11:Number = AC.dot(AC);
//			var d21:Number = AO.dot(AC);
//			var d20:Number = AO.dot(AB);
//			
//			var denominator:Number = d00*d11 - d10*d10;
//			
//			var vNumerator:Number = d20*d11 - d21*d10;
//			var wNumerator:Number = d00*d21 - d10*d20;
//			
//			var vABC:Number = vNumerator/denominator;
//			var wABC:Number = wNumerator/denominator;
//			var uABC:Number = 1 - vABC - wABC;
//			
//			traceout("uABC: "+uABC +"  vABC: "+ vABC + "  wABC: "+ wABC +"  sum: "+(uABC+vABC+wABC));
//			
//			if(AO.dot(AB) <= 0 && AO.dot(AC) <=0){
//				_simplex = new Array(_simplex[2].clone());
//									
//				//update minimun norm, 0-simplex itself is the minimum norm
//				_P = _simplex[0].clone();
//									
//				_sd = AO.clone();
//				
//				return;
//			}
//			
//			
//			if(AO.dot(AB) > 0 && wABC <=0){
//				_simplex = new Array(_simplex[1].clone(), _simplex[2].clone());
//							
//				//projection
//				var n:Vector2D = AB.clone();
//				n.normalize();
//				_P = n.scaleNew(AO.dot(n)).subNew(AO);
//					
//				_sd = AB.getPerp(AO);
//				
//				return;
//			}
//			
//			if(AO.dot(AC) > 0 && vABC <=0){
//				_simplex = new Array(_simplex[0].clone(), _simplex[2].clone());
//									
//				//projection
//				var n:Vector2D = AC.clone();
//				n.normalize();
//				_P = n.scaleNew(AO.dot(n)).subNew(AO);
//									
//				_sd = AC.getPerp(AO);
//				return;
//			}
//		}
		
		public function drawSimplex():void{
			var vertices:Vector.<Vector2D> = _simplex.vertices;
			
			_container.graphics.clear();
			_container.graphics.beginFill(0xFF0000, 3);
			_container.graphics.lineStyle(1, 0xFF0000);
			_container.graphics.moveTo(vertices[0].x, vertices[0].y);
			for(var i:uint=1; i<vertices.length; ++i){
				_container.graphics.lineTo(vertices[i].x, vertices[i].y);
			}
			_container.graphics.lineTo(vertices[0].x, vertices[0].y);
		}
		
		public function getSimplex():Simplex{
			return _simplex;
		}
		
		public function get collide():Boolean{
			return _collide;
		}
		
		public function get P():Vector2D{
			return _simplex.P;
		}
		
		public function support():SimplexVertex{
			var sd:Vector2D = _simplex.sd.clone();
			var support1:Vector2D = _shape1.support(sd.clone());
			var reverseD:Vector2D = sd.clone();
			reverseD.reverse();
			var support2:Vector2D = _shape2.support(reverseD);
			
			var supportPoint:Vector2D = support1.subNew(support2);
			
			var S:SimplexVertex = new SimplexVertex();
			S.vertexA = support1;
			S.vertexB = support2;
			
			
			
			return S;
		}
		
		private function traceout($str:Object, $colour:uint=0x000000):void{
			MonsterDebugger.trace(this, $str, $colour);
		}
		
		private function createText($text:String, $x:Number, $y:Number):void{
			var tf:TextField = new TextField();
			tf.defaultTextFormat = new TextFormat("Arial", 12, 0x000000);
			tf.text = $text;
			tf.x = _container.x+$x+4;
			tf.y = _container.y+$y;
			tf.alpha = 0.5;
			tf.background = false;
			tf.mouseEnabled=false
			this.addChild(tf);
			_fields.push(tf);
		}
		
		private function removeFields():void{
			for each(var f:TextField in _fields){
				if(this.contains(f)){
					this.removeChild(f);
				}
			}
		}
	}
}