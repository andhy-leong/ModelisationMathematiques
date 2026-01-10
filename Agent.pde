class Agent {
  PVector pos, vel, acc, lastPos;
  float r = 8.0; 
  float maxSpeed = 2.5;
  float maxForce = 0.15;
  int sidePreference = random(1) > 0.5 ? 1 : -1;
  int stuckTimer = 0;

  Agent(float x, float y) {
    pos = new PVector(x, y);
    vel = new PVector(random(-1,1), random(-1,1));
    acc = new PVector(0, 0);
    lastPos = pos.copy();
  }

  void run(ArrayList<Agent> agents, ArrayList<Obstacle> obstacles, Room room) {
    checkStuck();
    PVector forceExit = seek(room.getClosestExit(pos));
    PVector forceSep = separate(agents);
    PVector forceObs = avoidObstacles(obstacles);
    PVector forceWall = avoidWalls(room);
    
    applyForce(forceExit.mult(1.2));
    applyForce(forceSep.mult(2.5));
    applyForce(forceObs.mult(6.0));
    applyForce(forceWall.mult(5.0));
    
    update();
    display();
  }

  void checkStuck() {
    if (PVector.dist(pos, lastPos) < 0.2) stuckTimer++;
    else stuckTimer = 0;
    if (stuckTimer > 40) { sidePreference *= -1; stuckTimer = 0; }
    lastPos = pos.copy();
  }

  void applyForce(PVector force) { acc.add(force); }
  void update() { vel.add(acc); vel.limit(maxSpeed); pos.add(vel); acc.mult(0); }
  void display() { fill(255, 50, 50, 200); noStroke(); ellipse(pos.x, pos.y, r*2, r*2); }

  PVector seek(PVector target) {
    PVector d = PVector.sub(target, pos);
    d.setMag(maxSpeed);
    PVector s = PVector.sub(d, vel);
    s.limit(maxForce);
    return s;
  }

  PVector separate(ArrayList<Agent> agents) {
    float dS = r * 2.0;
    PVector sum = new PVector();
    int count = 0;
    for (Agent other : agents) {
      float d = PVector.dist(pos, other.pos);
      if ((d > 0) && (d < dS)) {
        PVector p = PVector.sub(pos, other.pos);
        p.setMag((dS - d) / 2);
        pos.add(p); 
        sum.add(PVector.sub(pos, other.pos).normalize().div(d));
        count++;
      }
    }
    if (count > 0) {
      sum.setMag(maxSpeed);
      PVector s = PVector.sub(sum, vel);
      s.limit(maxForce);
      return s;
    }
    return new PVector(0, 0);
  }

  PVector avoidObstacles(ArrayList<Obstacle> obstacles) {
    PVector tS = new PVector(0,0);
    for(Obstacle obs : obstacles) {
      PVector toO = PVector.sub(obs.pos, pos);
      float d = toO.mag();
      float mD = obs.r + r;
      if (d < mD + 20) {
        PVector lat = new PVector(-toO.y, toO.x).mult(sidePreference);
        lat.setMag(maxSpeed);
        PVector s = PVector.sub(lat, vel);
        s.limit(maxForce * 3);
        if (d < mD) {
           PVector p = PVector.sub(pos, obs.pos);
           p.setMag(mD); pos = PVector.add(obs.pos, p);
        }
        tS.add(s);
      }
    }
    return tS;
  }

  PVector avoidWalls(Room room) {
    PVector s = new PVector(0,0);
    float m = this.r + 2; 
    if (pos.y < m) { pos.y = m; s.add(new PVector(0, maxSpeed).sub(vel)); }
    else if (pos.y > height - m) { pos.y = height - m; s.add(new PVector(0, -maxSpeed).sub(vel)); }
    if (pos.x > width - m) { pos.x = width - m; s.add(new PVector(-maxSpeed, 0).sub(vel)); }
    else if (pos.x < m && !room.isNearExit(pos)) {
        pos.x = m; s.add(new PVector(maxSpeed, 0).sub(vel));
    }
    return s.limit(maxForce * 3);
  }
}
