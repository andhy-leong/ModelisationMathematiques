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
    
    // Pondération ajustée pour permettre plus de proximité
    forceExit.mult(1.0);
    forceSep.mult(1.5);   // Moins de séparation entre agents
    forceObs.mult(5.0);   // Force d'obstacle forte mais très courte portée
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
    float desiredSeparation = r * 2.1; // Réduit pour que les agents se touchent presque
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

  // --- PHYSIQUE AJUSTÉE ICI ---
  PVector avoidObstacles(ArrayList<Obstacle> obstacles) {
    PVector totalSteer = new PVector(0,0);
    for(Obstacle obs : obstacles) {
      float d = PVector.dist(pos, obs.pos);
      
      // Rayon effectif de l'obstacle (on réduit la marge à 5 pixels au lieu de 25)
      float obstacleRadius = obs.r;
      if (obs.type == 2) obstacleRadius = obs.r * 1.5; // Ajustement pour rectangle
      
      float detectionRange = obstacleRadius + r + 5; 
      
      if (d < detectionRange) {
        PVector flee = PVector.sub(pos, obs.pos);
        flee.normalize();
        
        // Force de répulsion exponentielle : très forte quand on est très près
        float strength = map(d, obstacleRadius + r, detectionRange, maxSpeed * 2, 0);
        flee.mult(strength);
        
        PVector steer = PVector.sub(flee, vel);
        steer.limit(maxForce * 2); // On permet une force de virage plus brusque
        totalSteer.add(steer);
      }
    }
    return totalSteer;
  }

  PVector avoidWalls(Room r) {
    PVector steer = new PVector(0,0);
    float buffer = 15; // Réduit la distance d'évitement des murs
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
