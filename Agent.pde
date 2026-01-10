// Agent.pde
class Agent {
  PVector pos, vel, acc;
  float r = 8.0; 
  float maxSpeed = 2.5;
  float maxForce = 0.15;

  Agent(float x, float y) {
    pos = new PVector(x, y);
    vel = new PVector(random(-1,1), random(-1,1));
    acc = new PVector(0, 0);
  }

  // Utilitaire pour les traces
  PVector copyPos() {
    return new PVector(pos.x, pos.y);
  }

  void run(ArrayList<Agent> agents, ArrayList<Obstacle> obstacles, Room room) {
    PVector forceExit = seek(room.exitPos);
    PVector forceSep = separate(agents);
    PVector forceObs = avoidObstacles(obstacles);
    PVector forceWall = avoidWalls(room);
    
    forceExit.mult(1.0);
    forceSep.mult(2.0); 
    forceObs.mult(5.0); 
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
    fill(255, 50, 50, 200);
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
    float desiredSeparation = r * 2.2;
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
      PVector toObstacle = PVector.sub(obs.pos, pos);
      float d = toObstacle.mag();
      
      if (vel.mag() > 0) {
        float angle = PVector.angleBetween(vel, toObstacle);
        if (angle > PI/2) continue; 
      }

      float obstacleRadius = obs.r;
      if (obs.type == 2) obstacleRadius = obs.r * 1.5; 
      float buffer = 15; 
      
      if (d < obstacleRadius + r + buffer) {
        PVector lateral = new PVector(-toObstacle.y, toObstacle.x);
        PVector goal = new PVector(-1, 0); 
        if (PVector.angleBetween(lateral, goal) > PI/2) {
          lateral.mult(-1);
        }
        lateral.setMag(maxSpeed);
        PVector steer = PVector.sub(lateral, vel);
        steer.limit(maxForce * 2);
        float weight = map(d, obstacleRadius + r, obstacleRadius + r + buffer, 1.2, 0);
        steer.mult(weight);
        totalSteer.add(steer);
      }
    }
    return totalSteer;
  }

  PVector avoidWalls(Room r) {
    PVector steer = new PVector(0,0);
    float margin = 15;
    if (pos.y < margin) steer.y = maxSpeed;
    if (pos.y > height - margin) steer.y = -maxSpeed;
    if (pos.x > width - margin) steer.x = -maxSpeed;
    if (pos.x < margin) {
      if (pos.y < r.exitPos.y - r.doorHeight/2 || pos.y > r.exitPos.y + r.doorHeight/2) {
         steer.x = maxSpeed;
      }
    }
    return steer;
  }
}
