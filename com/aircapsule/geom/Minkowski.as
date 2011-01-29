package com.aircapsule.geom
{
	import flash.display.Sprite;
	
	import nl.demonsters.debugger.MonsterDebugger;

	public class Minkowski extends Sprite
	{
		protected var _shapeA:Shape;
		
		protected var _shapeB:Shape;
		
		protected var _vertices:Vector.<Vector2D>;
		
		public function Minkowski($shapeA:Shape, $shapeB:Shape)
		{
			_shapeA = $shapeA;
			_shapeB = $shapeB;
			
			this.mouseChildren = false;
			this.mouseEnabled = false;
		}
		
		public function draw():void{
			//create all vertices of two shapes' minkowski difference.
			_vertices = new Vector.<Vector2D>();
			var verticesA:Vector.<Vector2D> = _shapeA.vertices;
			var verticesB:Vector.<Vector2D> = _shapeB.vertices;
			for(var i:uint=0; i<verticesA.length; ++i){
				for(var j:uint=0; j<verticesB.length; ++j){
					_vertices.push(verticesA[i].subNew(verticesB[j]));
				}
			}
			
			var convexChain:Vector.<Vector2D> = createConvexChain();
			
			//draw points
			this.graphics.clear();
			for(var i:uint=0; i<_vertices.length; ++i){
				this.graphics.beginFill(0x335522, 0.8);
				this.graphics.drawCircle(_vertices[i].x, _vertices[i].y, 2);
			}
			this.graphics.endFill();
			
			
			this.graphics.lineStyle(0.5, 0x000000, 0.2);
			this.graphics.moveTo(convexChain[0].x , convexChain[0].y);
			for(var i:uint=1; i<convexChain.length; ++i){
				this.graphics.lineTo(convexChain[i].x, convexChain[i].y);
			}
			this.graphics.lineTo(convexChain[0].x , convexChain[0].y);
			this.graphics.endFill();
		}
		
		private function createConvexChain():Vector.<Vector2D>{
			//sort vertices arrange them from left to right, if x equal, then bottom to top
			_vertices.sort(sortVertices);
			
			var upperChain:Vector.<Vector2D> = createUpperChain();
			var lowerChain:Vector.<Vector2D> = createLowerChain();
			//get rid of the tail and head item in lower chain, then reverse, get ready for concatenation
			lowerChain.pop();
			lowerChain.shift();
			lowerChain.reverse();
			
			return upperChain.concat(lowerChain);
		}
		
		private function sortVertices(v1:Vector2D, v2:Vector2D):Number{
			if(v1.x < v2.x){
				return -1;
			}
			else if(v1.x > v2.x){
				return 1;
			}
			else{
				if(v1.y<v2.y){
					return 1;
				}
				else if(v1.y>v2.y){
					return -1;
				}
				else{
					return 0;
				}
			}
		}
		
		private function createUpperChain():Vector.<Vector2D>{
			var upperVertices:Vector.<Vector2D> = new Vector.<Vector2D>();
			upperVertices.push(_vertices[0]);
			upperVertices.push(_vertices[1]);
			
			for(var i:uint=2; i<_vertices.length; ++i){
				var edge:Vector2D = upperVertices[upperVertices.length-1].subNew(upperVertices[upperVertices.length-2]);
				var newPointEdge:Vector2D = _vertices[i].subNew(upperVertices[upperVertices.length-2]);
				if(newPointEdge.cross(edge) >= 0){
					rewindUpperChain(upperVertices, _vertices[i]);
				}
				else{
					upperVertices.push(_vertices[i]);
				}
			}
			
			return upperVertices;
		}
		
		private function rewindUpperChain($upperVertices:Vector.<Vector2D>, $newPoint:Vector2D):Vector.<Vector2D>{
			while($upperVertices.length>0){
				$upperVertices.pop();
				if($upperVertices.length == 1){
					$upperVertices.push($newPoint);
					break;
				}
				else{
					var edge:Vector2D = $upperVertices[$upperVertices.length-1].subNew($upperVertices[$upperVertices.length-2]);
					var newPointEdge:Vector2D = $newPoint.subNew($upperVertices[$upperVertices.length-2]);
					if(edge.cross(newPointEdge) > 0){
						$upperVertices.push($newPoint);
						break;
					}
				}
			}
			return $upperVertices;
		}
		
		
		private function createLowerChain():Vector.<Vector2D>{
			var lowerVertices:Vector.<Vector2D> = new Vector.<Vector2D>();
			lowerVertices.push(_vertices[0]);
			lowerVertices.push(_vertices[1]);
			
			for(var i:uint=2; i<_vertices.length; ++i){
				var edge:Vector2D = lowerVertices[lowerVertices.length-1].subNew(lowerVertices[lowerVertices.length-2]);
				var newPointEdge:Vector2D = _vertices[i].subNew(lowerVertices[lowerVertices.length-2]);
				
				//new point is on the right of the current edge
				//FIXME: equal to zero!?!?!?
				if(newPointEdge.cross(edge) <= 0){
					rewindLowerChain(lowerVertices, _vertices[i]);
				}
				else{
					lowerVertices.push(_vertices[i]);
				}
			}
			
			return lowerVertices;
		}
		
		private function rewindLowerChain($lowerVertices:Vector.<Vector2D>, $newPoint:Vector2D):Vector.<Vector2D>{
			while($lowerVertices.length>0){
				$lowerVertices.pop();
				if($lowerVertices.length == 1){
					$lowerVertices.push($newPoint);
					break;
				}
				else{
					var edge:Vector2D = $lowerVertices[$lowerVertices.length-1].subNew($lowerVertices[$lowerVertices.length-2]);
					var newPointEdge:Vector2D = $newPoint.subNew($lowerVertices[$lowerVertices.length-2]);
					if(edge.cross(newPointEdge) < 0){
						$lowerVertices.push($newPoint);
						break;
					}
				}
			}
			return $lowerVertices;
		}
	}
}