// Room.pde
class Room {
  PVector exitPos;
  float doorHeight;

  Room(PVector exit, float h) {
    this.exitPos = exit;
    this.doorHeight = h;
  }
  
  boolean hasExited(PVector pos) {
    return (PVector.dist(pos, exitPos) < 20);
  }

  void display() {
    stroke(0);
    strokeWeight(4);
    noFill();
    line(0, 0, width, 0);
    line(0, height, width, height);
    line(width, 0, width, height);
    
    float doorTop = exitPos.y - doorHeight/2;
    float doorBottom = exitPos.y + doorHeight/2;
    line(0, 0, 0, doorTop);
    line(0, doorBottom, 0, height);
    
    noStroke();
    fill(0, 0, 255);
    ellipse(exitPos.x, exitPos.y, 15, 15);
  }
}
