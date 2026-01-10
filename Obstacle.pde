class Obstacle {
  PVector pos;
  float r;
  int type;

  Obstacle(float x, float y, float size, int type) {
    pos = new PVector(x, y);
    this.r = size;
    this.type = type;
  }
  
  void setPosition(float x, float y) { pos.set(x, y); }

  void display() {
    fill(0); 
    noStroke();
    rectMode(CENTER);
    if (type == 0) ellipse(pos.x, pos.y, r*2, r*2);
    else if (type == 1) rect(pos.x, pos.y, r*2, r*2);
    else if (type == 2) rect(pos.x, pos.y, r*4, r*2);
    else if (type == 3) triangle(pos.x, pos.y - r, pos.x - r, pos.y + r, pos.x + r, pos.y + r);
  }
}
