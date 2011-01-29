package com.aircapsule.cd
{
	import com.aircapsule.geom.Vector2D;
	
	import flash.display.Sprite;
	
	import nl.demonsters.debugger.MonsterDebugger;

	public class Simplex extends Sprite
	{
		public var a:SimplexVertex;
		
		public var b:SimplexVertex;
		
		public var c:SimplexVertex;
		
		protected var _length:uint;
		
		//check to protected
		public var _sd:Vector2D;
		
		public function Simplex()
		{
			_length = 1;
		}
		
		public function updatePoint():void{
			_sd = a.vertex;
			_sd.reverse();
		}
		
		public function updateLine():void{
			var A:Vector2D = a.vertex;
			var B:Vector2D = b.vertex;
			
			var AO:Vector2D = A.clone();
			AO.reverse();
			
			var AB:Vector2D = B.subNew(A);
			
			// AO.AB = |AO|*|AB|*cos(theta) = |AP|*|AB|
			// That means we need to divide the AO.AB by |AB|^2 to get the barycentric coordinate "v" if the projection is on segment AB
			// if on A or B(which is impossible), the barycentric coordinate for minimum norm P is always 1
			
			//TODO: optimize this, only do the division when needed. In the update simplex stage we only care the sign of the barycentric coordinate.
			var dottedAB:Number = AB.dot(AB);
			var v:Number = AO.dot(AB)/dottedAB;
			var u:Number = 1-v;
			
			//in the vertex A's voronoi region, it is impossible in B's
			if(v <= 0){
				// a did not change
//				a = a;
				// update barycentric coordinate for pair of closet points calculation
				a.bc = 1;
				_length = 1;
				
				// update search direction
				_sd = AO.clone();
				return;
			}
			
			// P must on the segment AB
			// the minimum simplex vertice to contains P do not change, but the barycentric coordinate of P may be changed.
			a.bc = u;
			b.bc = v;
			_length = 2;
			
			// update search direction
			_sd = AB.getPerp(AO);
		}
		
		public function updateTriangle():void{
			//using barycentric coordinate
			var A:Vector2D = a.vertex;
			var B:Vector2D = b.vertex
			var C:Vector2D = c.vertex;
			
			// Calculate barycentric coordinate u, v and w. (P is the origin)
			//
			// P = uA + vB + wC, and because u = 1-v-w, therefore:
			// P = (1-v-w)A + vB + wC = A + v(B-A) + w(C-A)  ===>   v(B-A) + w(C-A) = P-A
			// replace vector: B-A, C-A, and P-A with v0, v1 and v2, the we get:
			//		v*v0 + w*v1 = v2.
			// If we dot two sides with v0 and v1, we get two equations:
			//		v*(v0.v0) + w*(v1.v0) = v2.v0
			//		v*(v0.v1) + w*(v1.v1) = v2.v1
			//
			// we can form a matrix multiplication here:
			// 		[d00 d10]  *  [v]  =  [d20] 
			//		[d01 d11]     [w]     [d21]
			// d00 is the dot product: v0.v0, others "dxx" variable are represented as similar dot product.
			//
			// Therefore, we can use "Caramer's rule" to solve v and w, and u = 1 - v - w
			// 		v = |d20 d10|  /  |d00 d10|  
			//			|d21 d11|     |d01 d11|
			//
			// 		w = |d00 d20|  /  |d00 d10|
			//			|d01 d21|	  |d01 d11|
			// Note that: d01 == d10, d21 == d12, d20 == d02
			//
			//
			//
			// We can also use another system:
			// 		u*Ax + v*Bx + w*Cx = Px
			// 		u*Ay + v*By + w*Cy = Py
			// 		u + v + w = 1
			// Using Caramer's rule, we will be able to get u, v and w.
			
			//v0
			var AB:Vector2D = B.subNew(A);
			//v1
			var AC:Vector2D = C.subNew(A);
			//v2
			var AO:Vector2D = A.clone();
			AO.reverse();
			
			//only use line related barycentric coordinate for detecting vertex A voronoi region.
			var dottedAB:Number = AB.dot(AB);
			var vAB:Number = AO.dot(AB)/dottedAB;
			var uAB:Number = 1-vAB;
			
			var dottedAC:Number = AC.dot(AC);
			var vAC:Number = AO.dot(AC)/dottedAC;
			var uAC:Number = 1-vAC;
			
			
			//region A, only when vAB <= 0 and vAC <= 0
			if(vAB <= 0 && vAC <=0){
				//simplex vertex A does not change, just lose the B and C point
				_length = 1;
				
				a.bc = 1;
				
				// update search direction
				_sd = AO.clone();
				
				return;
			}
			
			//if not in the vertex A voronoi region then minimum norm P must on AB, AC or in ABC region. Using the barycentric coordinate related the triangle ABC
			var d00:Number = AB.dot(AB);
			var d10:Number = AC.dot(AB);
			var d11:Number = AC.dot(AC);
			var d21:Number = AO.dot(AC);
			var d20:Number = AO.dot(AB);
			
			var denominator:Number = d00*d11 - d10*d10;
			
			var vNumerator:Number = d20*d11 - d21*d10;
			var wNumerator:Number = d00*d21 - d10*d20;
			
			var vABC:Number = vNumerator/denominator;
			var wABC:Number = wNumerator/denominator;
			var uABC:Number = 1 - vABC - wABC;
			
			
			
			//region AB
			if(vAB > 0 && wABC <=0){
				//the minimum vertice to express P, is a and b, only need to get rid of c by change the length of the simplex
				_length = 2;
				
				// update barycentric coordinate for minimum vertices(which is a line)
				//      vAB        uAB
				//       |          |
				// A _________P___________ B
				// 
				// note that uAB is a coefficient for A, but it actually express PB's magnitude
				// That's why a.bc should be uAB not vAB.
				a.bc = uAB;
				b.bc = vAB;
				
				// update search direction
				_sd = AB.getPerp(AO);
				
				return;
			}
			
			//region AC
			if(vAC > 0 && vABC <=0){
				// minimum vertices changed into a and c.
				_length = 2;
				// b changed into c
				b = c;
				
				//	    vAC        uAC
				//       |          |
				// A _________P___________ C
				a.bc = uAC;
				b.bc = vAC;
				
				_sd = AC.getPerp(AO);
				
				return;
			}
			
			// otherwise, origin is in the ABC triangle, two shape collide, the barycentric coordinate then is related to the triangle ABC,
			// so a, b and c's barycentric coordinate are: uABC, vABC and wABC respectively.
			a.bc = uABC;
			b.bc = vABC;
			c.bc = wABC;
			_length = 3;
			
			
			
			//no need to do further search, since the origin is contained by the triangle ABC already
			_sd = null;
		}
		
		public function assignSimplexVertex($S:SimplexVertex):void{
			if(_length == 1){
				b = a;
				a = $S;
				_length = 2;
			}
			else if(_length == 2){
				c = b; 
				b = a;
				a = $S;
				
				_length = 3;
			}
		}
		
		public function get P():Vector2D{
			if(_length == 1){
				return a.vertex;
			}
			else if(_length == 2){
				var A:Vector2D = a.vertex;
				var B:Vector2D = b.vertex;
				
				//uA + vB = P
				return A.scaleNew(a.bc).addNew(B.scaleNew(b.bc))
			}
			else{
				var A:Vector2D = a.vertex;
				var B:Vector2D = b.vertex;
				var C:Vector2D = c.vertex;
				
				//uA + vB = P
				return A.scaleNew(a.bc).addNew(B.scaleNew(b.bc)).addNew(C.scaleNew(c.bc));
			}
		}
		
		public function get vertices():Vector.<Vector2D>{
			var vertices:Vector.<Vector2D> = new Vector.<Vector2D>();
			if(_length == 3){
				vertices[0] = a.vertex;
				vertices[1] = b.vertex;
				vertices[2] = c.vertex;
			}
			else if(_length == 2){
				vertices[0] = a.vertex;
				vertices[1] = b.vertex;
			}
			else{
				vertices[0] = a.vertex;
			}
			
			return vertices;
		}
		
		public function get sd():Vector2D{
			return _sd;
		}
		
		public function get length():uint{
			return _length;
		}
		
		public function getClosetPoints():Vector.<Vector2D>{
			var vertexA:Vector2D;
			var vertexB:Vector2D;
			
			if(_length == 1){
				vertexA = a.vertexA.scaleNew(a.bc);
				vertexB = a.vertexB.scaleNew(a.bc);
				
				
				
			}
			else if(_length == 2){
				vertexA = a.vertexA.scaleNew(a.bc);
				vertexA.add(b.vertexA.scaleNew(b.bc));
					
				vertexB = a.vertexB.scaleNew(a.bc);
				vertexB.add(b.vertexB.scaleNew(b.bc));
				
				
				
			}
			else{
				
			}
			
			
			
			var vertices:Vector.<Vector2D> = new Vector.<Vector2D>();
			vertices[0] = vertexA;
			vertices[1] = vertexB;
			
			return vertices;
		}
	}
}