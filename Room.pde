class Room {
  ArrayList<PVector> exits;
  float doorHeight;

  Room(float h) {
    exits = new ArrayList<PVector>();
    this.doorHeight = h;
  }
  
  void addExit(float x, float y) {
    float dL = x, dR = width - x, dT = y, dB = height - y;
    float m = min(min(dL, dR), min(dT, dB));
    PVector p = new PVector(x, y);
    if (m == dL) p.x = 0; else if (m == dR) p.x = width;
    else if (m == dT) p.y = 0; else if (m == dB) p.y = height;
    exits.add(p);
  }
  
  PVector getClosestExit(PVector agentPos) {
    if (exits.isEmpty()) return new PVector(0, height/2);
    PVector c = exits.get(0);
    float mD = PVector.dist(agentPos, c);
    for (PVector e : exits) {
      float d = PVector.dist(agentPos, e);
      if (d < mD) { mD = d; c = e; }
    }
    return c;
  }

  boolean isNearExit(PVector pos) {
    for (PVector e : exits) {
      if (e.x <= 0 || e.x >= width) {
        if (pos.y > e.y-doorHeight/2 && pos.y < e.y+doorHeight/2) return true;
      } else {
        if (pos.x > e.x-doorHeight/2 && pos.x < e.x+doorHeight/2) return true;
      }
    }
    return false;
  }

  boolean hasExited(PVector pos) {
    for (PVector e : exits) if (PVector.dist(pos, e) < 25) return true;
    return false;
  }

  void display() {
    stroke(0); strokeWeight(4);
    line(0,0,width,0); line(0,height,width,height);
    line(0,0,0,height); line(width,0,width,height);
    for (PVector e : exits) {
      fill(0, 0, 255); noStroke();
      ellipse(e.x, e.y, 15, 15);
    }
  }
}
