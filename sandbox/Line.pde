class Line{
    //class to define a line from two points 
    //that extends off the end of the end of the screen
    //NOT a line segment
    //and keeps track of what it intersects with.
    
    //initially defined in terms of two points
    
    float x1, y1, x2, y2;
    
    float[][] intersections;
    
    Line(){ 
    }
    
    void init(float _x1, float _y1, float _x2, float _y2){
        x1 = _x1;
        y1 = _y1;
        x2 = _x2;
        y2 = _y2;
        
        intersections = new float[50][2];
        
    }
    
    void sort_intersections(){
        
        
    }
    
    
    void draw(){
        pushMatrix();
        smooth();
        stroke(0);
        strokeWeight(1);
        line(x1,y1,x2,y2);
        popMatrix();
    }

    void draw(color c){
        pushMatrix();
        smooth();
        stroke(c);
        strokeWeight(10);
        line(x1,y1,x2,y2);
        popMatrix();
    }
    

    
}


