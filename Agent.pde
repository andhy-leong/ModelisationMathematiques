class Agent {
  PVector pos, vel, acc;
  float r = 8.0; 
  float maxSpeed = 3.0;
  float maxForce = 0.25;
  
  boolean escaped = false; 

  Agent(float x, float y) {
    pos = new PVector(x, y);
    vel = new PVector(0,0);
    acc = new PVector(0, 0);
  }

  // On reçoit une liste "allObstacles" qui contient (Obstacles Utilisateur + Murs de la salle)
  void run(ArrayList<Agent> agents, FlowField flow, ArrayList<Obstacle> allObstacles, Room room, PVector targetSafeZone) {
    
    // --- 1. ETAT ---
    // Vérification géométrique simple pour savoir si on est "dehors"
    // (Juste pour savoir si on vise la sortie ou le point vert)
    boolean insideRoomRect = (pos.x > room.x + r && pos.x < room.x + room.w - r && 
                              pos.y > room.y + r && pos.y < room.y + room.h - r);
    
    if (!insideRoomRect) escaped = true;

    // --- 2. DIRECTION ---
    if (!escaped) {
      // DEDANS : FlowField
      PVector desired = flow.lookup(pos);
      desired.mult(maxSpeed);
      PVector steer = PVector.sub(desired, vel);
      steer.limit(maxForce);
      applyForce(steer);
    } else {
      // DEHORS : Seek SafeZone
      PVector seekForce = seek(targetSafeZone);
      seekForce.mult(1.5); 
      applyForce(seekForce);
    }

    PVector sep = separate(agents);
    applyForce(sep.mult(3.0));

    update();
    
    // --- 3. PHYSIQUE (Collision Unique) ---
    // On collisionne avec TOUT (Cubes noirs ET Murs de la salle)
    resolveObstacles(allObstacles); 
    
    display();
  }

  void applyForce(PVector force) { acc.add(force); }

  void update() {
    vel.add(acc);
    vel.limit(maxSpeed);
    pos.add(vel);
    acc.mult(0);
  }

  // Fonction universelle de collision (Murs et Objets)
  void resolveObstacles(ArrayList<Obstacle> obstacles) {
    for (Obstacle obs : obstacles) {
      PVector closest = getClosestPointOnObstacle(pos, obs);
      PVector normal = PVector.sub(pos, closest);
      float dist = normal.mag();
      
      // Si on touche
      if (dist < r) {
        if (dist == 0) normal = PVector.random2D(); else normal.normalize();
        
        // 1. Repousser
        pos.add(normal.copy().mult(r - dist));
        
        // 2. Glisser (Friction nulle)
        float vDot = PVector.dot(vel, normal);
        if (vDot < 0) vel.sub(normal.copy().mult(vDot));
      }
    }
  }

  // Gestion parfaite de la rotation et des rectangles (utilisée aussi pour les murs)
  PVector getClosestPointOnObstacle(PVector p, Obstacle obs) {
    if (obs.type == 0) { // Cercle
      PVector dir = PVector.sub(p, obs.pos).normalize().mult(obs.r);
      return PVector.add(obs.pos, dir);
    }
    
    // Rectangle (Tourné ou non)
    PVector relative = PVector.sub(p, obs.pos);
    float cosA = cos(-obs.angle); float sinA = sin(-obs.angle);
    float localX = relative.x * cosA - relative.y * sinA;
    float localY = relative.x * sinA + relative.y * cosA;
    
    // obs.r est demi-largeur, obs.h est demi-hauteur
    float cX = constrain(localX, -obs.r, obs.r);
    float cY = constrain(localY, -obs.h, obs.h);
    
    float cosB = cos(obs.angle); float sinB = sin(obs.angle);
    float finalX = cX * cosB - cY * sinB;
    float finalY = cX * sinB + cY * cosB;
    
    return PVector.add(obs.pos, new PVector(finalX, finalY));
  }
  
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, pos);
    float d = desired.mag();
    desired.normalize();
    if (d < 50) desired.mult(map(d, 0, 50, 0, maxSpeed));
    else desired.mult(maxSpeed);
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
        PVector diff = PVector.sub(pos, other.pos).normalize().div(d);
        sum.add(diff); count++;
      }
    }
    if (count > 0) {
      sum.setMag(maxSpeed);
      return PVector.sub(sum, vel).limit(maxForce);
    }
    return new PVector(0,0);
  }

  void display() { 
    if (escaped) fill(0, 100, 0); else fill(255, 50, 50); 
    noStroke(); ellipse(pos.x, pos.y, r*2, r*2);
  }
}
