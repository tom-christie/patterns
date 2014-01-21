class PetalDiamond{
 //class for a petal and diamond (clockwise!), 
 //to hold coordinates of all the points found from them.

 int index; //which in order it is (0-n)
 
 //points
 float diamond_inner_x;//
 float diamond_inner_y;//
 float diamond_left_x;
 float diamond_left_y;
 float diamond_right_x;
 float diamond_right_y;
 float diamond_outer_x; //
 float diamond_outer_y; //
 
 float petal_inner_x;
 float petal_inner_y;
 float petal_left_inner_x;//
 float petal_left_inner_y;//
 float petal_right_inner_x; //
 float petal_right_inner_y; //
 float petal_left_outer_x;
 float petal_left_outer_y;
 float petal_right_outer_x;
 float petal_right_outer_y;
 float petal_outer_x;
 float petal_outer_y;
 
 
 PetalDiamond(){
    
 }

 void init(int _index){
     index = _index;
 }    
    
    
    
}
