// Obstacle.pde
class Obstacle {
  PVector pos;
  float r;     // Taille de base (rayon ou demi-côté)
  int type;    // 0: Cercle, 1: Carré, 2: Rectangle, 3: Triangle

  Obstacle(float x, float y, float size, int type) {
    pos = new PVector(x, y);
    this.r = size;
    this.type = type;
  }
  
  void setPosition(float x, float y) {
    pos.set(x, y);
  }

  void display() {
    fill(0); 
    noStroke();
    rectMode(CENTER);
    
    if (type == 0) { // Cercle
      ellipse(pos.x, pos.y, r*2, r*2);
    } 
    else if (type == 1) { // Carré
      rect(pos.x, pos.y, r*2, r*2);
    } 
    else if (type == 2) { // Rectangle
      rect(pos.x, pos.y, r*4, r*2);
    } 
    else if (type == 3) { // Triangle
      triangle(pos.x, pos.y - r, pos.x - r, pos.y + r, pos.x + r, pos.y + r);
    }
  }
}
