class FlowField {
  PVector[][] field;
  int[][] distMap;
  int cols, rows; 
  int resolution = 20;

  FlowField() {
    cols = width / resolution;
    rows = height / resolution;
    field = new PVector[cols][rows];
    distMap = new int[cols][rows];
    init();
  }

  void init() {
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        field[i][j] = new PVector(0, 0);
        distMap[i][j] = 99999;
      }
    }
  }

  void generate(ArrayList<Obstacle> obstacles, Room room) {
    // --- 1. DIJKSTRA (Calcul des distances) ---
    
    for (int i=0; i<cols; i++) {
      for (int j=0; j<rows; j++) distMap[i][j] = 99999;
    }

    ArrayList<int[]> queue = new ArrayList<int[]>();
    
    for (PVector exit : room.exits) {
      int c = int(constrain(exit.x / resolution, 0, cols-1));
      int r = int(constrain(exit.y / resolution, 0, rows-1));
      distMap[c][r] = 0;
      queue.add(new int[]{c, r});
    }

    while (!queue.isEmpty()) {
      int[] current = queue.remove(0); 
      int cx = current[0]; int cy = current[1];

      for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
          if (x == 0 && y == 0) continue;
          int nx = cx + x; int ny = cy + y;

          if (nx >= 0 && nx < cols && ny >= 0 && ny < rows) {
            if (isBlocked(nx, ny, obstacles)) continue;

            int moveCost = (x != 0 && y != 0) ? 14 : 10;
            int newDist = distMap[cx][cy] + moveCost;

            if (newDist < distMap[nx][ny]) {
              distMap[nx][ny] = newDist;
              queue.add(new int[]{nx, ny});
            }
          }
        }
      }
    }

    // --- 2. CALCUL DES VECTEURS ---
    
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        int currentDist = distMap[i][j];

        boolean nearWall = isNearWall(i, j, obstacles);

        if (nearWall) {
           // Mode "Sortie de secours" ou "Longer le mur"
           int bestDist = 999999;
           int targetX = -1; 
           int targetY = -1;
           
           for (int x = -1; x <= 1; x++) {
             for (int y = -1; y <= 1; y++) {
                if (x==0 && y==0) continue;
                int nx = i+x; int ny = j+y;
                if (nx >= 0 && nx < cols && ny >= 0 && ny < rows) {
                   int d = distMap[nx][ny];
                   if (d < bestDist) {
                      bestDist = d;
                      targetX = nx;
                      targetY = ny;
                   }
                }
             }
           }
           
           if (targetX != -1) {
              PVector center = new PVector(i*resolution+resolution/2, j*resolution+resolution/2);
              PVector target = new PVector(targetX*resolution+resolution/2, targetY*resolution+resolution/2);
              PVector dir = PVector.sub(target, center).normalize();
              field[i][j] = dir;
           }

        } else {
           // Mode "Fluide" (Loin des murs)
           int dLeft = getClampedDist(i - 1, j, currentDist);
           int dRight = getClampedDist(i + 1, j, currentDist);
           int dUp = getClampedDist(i, j - 1, currentDist);
           int dDown = getClampedDist(i, j + 1, currentDist);

           float xForce = dLeft - dRight;
           float yForce = dUp - dDown;
           PVector v = new PVector(xForce, yForce);
           v.normalize();
           field[i][j] = v;
        }
      }
    }
  }
  
  boolean isNearWall(int c, int r, ArrayList<Obstacle> obstacles) {
     // Si la case elle-même est un obstacle, on est "NearWall" (en fait InsideWall)
     float cx = c * resolution + resolution/2;
     float cy = r * resolution + resolution/2;
     for (Obstacle obs : obstacles) if (obs.contains(cx, cy)) return true;

     // Sinon on regarde les voisins
     for (int x = -1; x <= 1; x++) {
       for (int y = -1; y <= 1; y++) {
         if (x==0 && y==0) continue;
         float wx = (c + x) * resolution + resolution/2;
         float wy = (r + y) * resolution + resolution/2;
         
         for (Obstacle obs : obstacles) {
           if (obs.contains(wx, wy)) return true;
         }
       }
     }
     return false;
  }
  
  int getClampedDist(int c, int r, int fallbackVal) {
    if (c < 0 || c >= cols || r < 0 || r >= rows) return fallbackVal + 5;
    int val = distMap[c][r];
    if (val >= 90000) return fallbackVal + 5;
    return val;
  }
  
  boolean isBlocked(int c, int r, ArrayList<Obstacle> obstacles) {
    float x = c * resolution + resolution/2;
    float y = r * resolution + resolution/2;
    for (Obstacle obs : obstacles) {
      if (obs.contains(x, y)) return true;
    }
    return false;
  }

  PVector lookup(PVector lookup) {
    int c = int(constrain(lookup.x / resolution, 0, cols-1));
    int r = int(constrain(lookup.y / resolution, 0, rows-1));
    return field[c][r].copy();
  }
  
  void display() {
    stroke(180, 80);
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        if (field[i][j].mag() > 0) {
          pushMatrix();
          translate(i*resolution + resolution/2, j*resolution + resolution/2);
          rotate(field[i][j].heading());
          line(-5, 0, 5, 0);
          line(5, 0, 3, -2);
          line(5, 0, 3, 2);
          popMatrix();
        }
      }
    }
  }
}
