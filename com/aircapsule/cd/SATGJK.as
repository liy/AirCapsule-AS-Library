package com.aircapsule.cd
{
	import com.aircapsule.geom.Shape;
	import com.aircapsule.geom.Vector2D;
	
	import flash.display.Sprite;
	
	import nl.demonsters.debugger.MonsterDebugger;

	public class SATGJK
	{
		protected var _shape1:Shape;
		
		protected var _shape2:Shape;
		
		protected var _simplex:Array = new Array();
		
		/**
		 * Search direction 
		 */		
		protected var _sd:Vector2D;
		
		protected var _container:Sprite;
		
		protected var _collided:Boolean = false;
		
		protected var _loopIndex:uint = 0;
		
		public function SATGJK($container:Sprite, $shape1:Shape, $shape2:Shape){
			_shape1 = $shape1;
			_shape2 = $shape2;
			_container = $container;
		}
		
		public function start():Boolean{
			_loopIndex = 0;
			
			_simplex = new Array();
			var rv1:Vector2D = _shape1.vertices[1];
			var rv2:Vector2D = _shape2.vertices[0];
			var rv:Vector2D = rv1.subNew(rv2);
			
			//init search direction towards O, origin.
			_sd = rv.clone();
			_sd.reverse();
			
			//calculate the support
			var A:Vector2D = support(_sd.clone());
			
			//update search direction to A.reverse(), since we have reach the furthest point in the minkowski sum along search direction.
			//the O point should be in the opposite direction.
			_sd = A.clone();
			_sd.reverse();
			_simplex.push(A.clone());
			
			while(true){
				_loopIndex++;
				A = support(_sd);
				
				//no intersection
				if(_sd.dot(A) < 0 || _loopIndex>100){
					_collided = false;
					
					_container.graphics.clear();
					_container.graphics.beginFill(0xFF4400, 0.3);
					_container.graphics.lineStyle(2, 0xFF4400);
					_container.graphics.drawCircle(_simplex[0].x, _simplex[0].y, 10);
					_container.graphics.moveTo(_simplex[0].x, _simplex[0].y);
					for(var i:uint=0; i<_simplex.length; ++i){
						_container.graphics.lineTo(_simplex[i].x, _simplex[i].y);
					}
					_container.graphics.lineTo(_simplex[0].x, _simplex[0].y);
					_container.graphics.endFill();
					
					return _collided;
				}
				else{
					//always makes sure the doSimplex function deal with line or triangle.
					_simplex.push(A);
					
					//find the intersection
					if(doSimplex()){
						
						_container.graphics.clear();
						_container.graphics.beginFill(0xFF9900, 0.8);
						_container.graphics.moveTo(_simplex[0].x, _simplex[0].y);
						_container.graphics.lineTo(_simplex[1].x, _simplex[1].y);
						_container.graphics.lineTo(_simplex[2].x, _simplex[2].y);
						_container.graphics.lineTo(_simplex[0].x, _simplex[0].y);
						_container.graphics.endFill();
						
						_collided = true;
						
						return _collided;
					}
					//else loop again
				}
			}
			//no way to get here.
			return false;
		}
		
		protected function doSimplex():Boolean{
			//line
			if(_simplex.length == 2){
				//create AO, AB
				var AO:Vector2D = _simplex[1].clone();
				AO.reverse();
				var AB:Vector2D = _simplex[0].subNew(_simplex[1]);
				//region 2
				if(AO.dot(AB) >= 0){
//					_sd = AB.tripleProduct(AB, AO, AB);
					_sd = AB.getPerp(AO);
					//simplex no change.
				}
				//region 1
				else{ 
					_simplex = new Array(_simplex[1].clone());
					_sd = AO.clone();
				}
				return false;
			}
			//triangle
			else{
				var AO:Vector2D = _simplex[2].clone();
				AO.reverse();
				var AC:Vector2D = _simplex[0].subNew(_simplex[2]);
				var AB:Vector2D = _simplex[1].subNew(_simplex[2]);
				
				//region 6, 5
				if(AC.cross(AO) > 0){
					//region 6
					if(AO.dot(AC) > 0){
						_simplex = new Array(_simplex[0].clone(), _simplex[2].clone());
						
						//_sd = AC.tripleProduct(AC, AO, AC);
						_sd = AC.getPerp(AO);
						/*
						var nAC:Vector2D = AC.clone();
						nAC.normalize();
						var pal:Vector2D = nAC.scaleNew(nAC.dot(AO));
						_sd = AO.subNew(pal);
						*/
					}
					//region 5
					else{
						_simplex = new Array(_simplex[2].clone());
						_sd = AO.clone();
					}
					//loop back
					return false;
				}
				//region 4, 5
				else if(AO.cross(AB) > 0){
					//region 4
					if(AB.dot(AO) > 0){
						_simplex = new Array(_simplex[1].clone(), _simplex[2].clone());
						
						//_sd = AB.tripleProduct(AB, AO, AB);
						_sd = AB.getPerp(AO);
						/*
						var nAB:Vector2D = AB.clone();
						nAB.normalize();
						var pal:Vector2D = nAB.scaleNew(nAB.dot(AO));
						_sd = AO.subNew(pal);
						*/
					}
					//region 5
					else{
						_simplex = new Array(_simplex[2].clone());
						_sd = AO.clone();
					}
					//loop back
					return false;
				}
				//region 7
				else{
					return true;
				}
			}
		}
		
		public function support($d:Vector2D):Vector2D{
			var support1:Vector2D = _shape1.support($d);
			var reverseD:Vector2D = $d.clone();
			reverseD.reverse();
			var support2:Vector2D = _shape2.support(reverseD);
			
			return support1.subNew(support2);
		}
		
		public function collided():Boolean{
			return _collided;
		}
		
		public function getSimplex():Array{
			return _simplex;
		}
		
		public function getShapeA():Shape{
			return _shape1;
		}
		
		public function getShapeB():Shape{
			return _shape2;
		}
		
		public function getContainer():Sprite{
			return _container;
		}
		
		/**
		 * Only call this method when two shape collides 
		 * @return 
		 * 
		 */		
//		public function genPenertration():Vector2D{
//			var AC:Vector2D = (_simplex[0] as Vector2D).subNew(_simple[2]);
//			var AB:Vector2D = (_simplex[1] as Vector2D).subNew(_simple[2]);
//			
//			if(AC.dot()
//		}
	}
}