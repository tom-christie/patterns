class Circle {

    //defined in terms of center and radius

    float xpos, ypos, radius;

    Circle() {
    }

    void init(float _xpos, float _ypos, float _radius) {
        xpos = _xpos;
        ypos = _ypos;
        radius = _radius;

    }

    void draw() {

        //draw circle
        pushMatrix();
        smooth();
        ellipseMode(CENTER);
        stroke(0);
        strokeWeight(1);
        noFill();
        ellipse(xpos, ypos, 2*radius, 2*radius);
        popMatrix();

    }
}

