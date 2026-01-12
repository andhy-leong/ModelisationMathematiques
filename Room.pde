class Room {
  ArrayList<PVector> exits;
  ArrayList<Obstacle> wallObstacles; 
  float doorHeight;
  
  float x, y, w, h;
  // MODIFICATION : 15px est un bon équilibre (ni trop fin, ni trop gros)
  float wallThickness = 15; 

  Room(float x, float y, float w, float h, float doorH) {
    this.x = x; this.y = y;
    this.w = w; this.h = h;
    this.doorHeight = doorH;
    exits = new ArrayList<PVector>();
    wallObstacles = new ArrayList<Obstacle>();
    updateWalls(); 
  }
  
  void addExit(float mx, float my) {
    float dLeft = abs(mx - x);
    float dRight = abs(mx - (x + w));
    float dTop = abs(my - y);
    float dBottom = abs(my - (y + h));
    
    float m = min(min(dLeft, dRight), min(dTop, dBottom));
    PVector p = new PVector(mx, my);
    
    if (m == dLeft) p.x = x;
    else if (m == dRight) p.x = x + w;
    else if (m == dTop) p.y = y;
    else if (m == dBottom) p.y = y + h;
    
    exits.add(p);
    updateWalls();
  }
  
  void updateWalls() {
    wallObstacles.clear();
    // Génération des segments de murs autour des portes
    generateWallSegments(x, y, x, y + h, true);       // Gauche
    generateWallSegments(x + w, y, x + w, y + h, true); // Droite
    generateWallSegments(x, y, x + w, y, false);      // Haut
    generateWallSegments(x, y + h, x + w, y + h, false); // Bas
  }
  
  void generateWallSegments(float x1, float y1, float x2, float y2, boolean vertical) {
    ArrayList<Float> cuts = new ArrayList<Float>();
    
    for (PVector e : exits) {
      if (vertical) {
        if (abs(e.x - x1) < 5 && e.y >= min(y1, y2) && e.y <= max(y1, y2)) cuts.add(e.y);
      } else {
        if (abs(e.y - y1) < 5 && e.x >= min(x1, x2) && e.x <= max(x1, x2)) cuts.add(e.x);
      }
    }
    
    float start = vertical ? min(y1, y2) : min(x1, x2);
    float end = vertical ? max(y1, y2) : max(x1, x2);
    
    float[] sortedCuts = new float[cuts.size()];
    for(int i=0; i<cuts.size(); i++) sortedCuts[i] = cuts.get(i);
    java.util.Arrays.sort(sortedCuts);
    
    float currentPos = start;
    
    for (float cut : sortedCuts) {
      float holeStart = cut - doorHeight/2;
      float holeEnd = cut + doorHeight/2;
      
      if (holeStart > currentPos) {
        createWallObstacle(x1, y1, currentPos, holeStart, vertical);
      }
      currentPos = max(currentPos, holeEnd);
    }
    
    if (currentPos < end) {
      createWallObstacle(x1, y1, currentPos, end, vertical);
    }
  }
  
  void createWallObstacle(float refX, float refY, float start, float end, boolean vertical) {
    float len = end - start;
    if (len <= 0) return;
    
    float cx, cy, obsW, obsH;
    
    if (vertical) {
      cx = refX; 
      cy = start + len/2;
      obsW = wallThickness; 
      obsH = len;           
    } else {
      cx = start + len/2;
      cy = refY;
      obsW = len;
      obsH = wallThickness;
    }
    
    Obstacle obs = new Obstacle(cx, cy, 10, 1); 
    obs.r = obsW / 2;
    obs.h = obsH / 2;
    obs.type = 10; 
    
    wallObstacles.add(obs);
  }
  
  PVector getExitUnderMouse(float mx, float my) {
    for (PVector e : exits) if (dist(mx, my, e.x, e.y) < 20) return e;
    return null;
  }
  
  PVector getClosestExit(PVector p) {
    if (exits.isEmpty()) return new PVector(x+w/2, y+h/2);
    PVector best = exits.get(0);
    float md = PVector.dist(p, best);
    for(PVector e : exits) { float d = PVector.dist(p, e); if(d<md){md=d; best=e;} }
    return best;
  }

  void display() {
    fill(0); noStroke();
    
    // 1. Dessiner les segments de murs physiques
    for (Obstacle obs : wallObstacles) {
      rectMode(CENTER);
      rect(obs.pos.x, obs.pos.y, obs.r*2, obs.h*2);
    }
    
    // 2. Dessiner les "Coins" pour une finition propre
    // Comme les murs sont centrés sur les lignes, les coins peuvent avoir des petits trous
    // On dessine un carré centré sur chaque angle de la pièce pour boucher
    float t = wallThickness;
    rectMode(CENTER); // Important car Obstacle utilise CENTER
    rect(x, y, t, t);           // Haut-Gauche
    rect(x + w, y, t, t);       // Haut-Droite
    rect(x, y + h, t, t);       // Bas-Gauche
    rect(x + w, y + h, t, t);   // Bas-Droite

    // 3. Portes
    for (PVector e : exits) {
      noStroke(); fill(0, 0, 255); ellipse(e.x, e.y, 10, 10);
    }
  }
}
