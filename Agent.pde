// Agent.pde
class Agent {
  PVector pos, vel, acc;
  float r = 8.0;
  float maxSpeed = 3.0;
  float maxForce = 0.2;

  Agent(float x, float y) {
    pos = new PVector(x, y);
    vel = new PVector(random(-1,1), random(-1,1));
    acc = new PVector(0, 0);
  }

  void run(ArrayList<Agent> agents, ArrayList<Obstacle> obstacles, Room room) {
    PVector forceExit = seek(room.exitPos);
    PVector forceSep = separate(agents);
    PVector forceObs = avoidObstacles(obstacles);
    PVector forceWall = avoidWalls(room);
    
    forceExit.mult(1.0);
    forceSep.mult(2.5);
    forceObs.mult(4.0);
    forceWall.mult(5.0);
    
    applyForce(forceExit);
    applyForce(forceSep);
    applyForce(forceObs);
    applyForce(forceWall);
    
    update();
    display();
  }

  void applyForce(PVector force) {
    acc.add(force);
  }

  void update() {
    vel.add(acc);
    vel.limit(maxSpeed);
    pos.add(vel);
    acc.mult(0);
  }

  void display() {
    fill(255, 50, 50);
    noStroke();
    ellipse(pos.x, pos.y, r*2, r*2);
  }

  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, pos);
    desired.setMag(maxSpeed);
    PVector steer = PVector.sub(desired, vel);
    steer.limit(maxForce);
    return steer;
  }

  PVector separate(ArrayList<Agent> agents) {
    float desiredSeparation = r * 3.5;
    PVector sum = new PVector();
    int count = 0;
    for (Agent other : agents) {
      float d = PVector.dist(pos, other.pos);
      if ((d > 0) && (d < desiredSeparation)) {
        PVector diff = PVector.sub(pos, other.pos);
        diff.normalize();
        diff.div(d);
        sum.add(diff);
        count++;
      }
    }
    if (count > 0) {
      sum.setMag(maxSpeed);
      PVector steer = PVector.sub(sum, vel);
      steer.limit(maxForce);
      return steer;
    }
    return new PVector(0, 0);
  }

  PVector avoidObstacles(ArrayList<Obstacle> obstacles) {
    PVector totalSteer = new PVector(0,0);
    for(Obstacle obs : obstacles) {
      float d = PVector.dist(pos, obs.pos);
      float detectionRange = obs.r + r + 25;
      if (obs.type == 2) detectionRange += 20; // Plus de marge pour le rectangle
      
      if (d < detectionRange) {
        PVector flee = PVector.sub(pos, obs.pos);
        flee.normalize();
        flee.mult(maxSpeed);
        PVector steer = PVector.sub(flee, vel);
        steer.limit(maxForce);
        totalSteer.add(steer);
      }
    }
    return totalSteer;
  }

  PVector avoidWalls(Room r) {
    PVector steer = new PVector(0,0);
    float buffer = 20;
    if (pos.y < buffer) steer.y = maxSpeed;
    if (pos.y > height - buffer) steer.y = -maxSpeed;
    if (pos.x > width - buffer) steer.x = -maxSpeed;
    if (pos.x < buffer) {
      if (pos.y < r.exitPos.y - r.doorHeight/2 || pos.y > r.exitPos.y + r.doorHeight/2) {
         steer.x = maxSpeed;
      }
    }
    return steer;
  }
}
