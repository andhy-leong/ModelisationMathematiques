class Obstacle {
  PVector pos;
  float r;     // Rayon ou demi-largeur
  float h;     // Hauteur (pour les rectangles)
  float angle; // Rotation en radians
  int type;    // 0=Circle, 1=Square, 2=Rect, 3=Triangle
  
  boolean isSelected = false; // Pour savoir si on l'a cliqué

  Obstacle(float x, float y, float size, int type) {
    pos = new PVector(x, y);
    this.r = size; // Demi-largeur
    this.type = type;
    this.angle = 0;
    
    // Définir la hauteur par défaut selon le type
    if (type == 0 || type == 1) h = size;
    else if (type == 2) { r = size * 2; h = size; } // Rectangle large
    else h = size;
  }
  
  void setPosition(float x, float y) {
    pos.set(x, y);
  }
  
  void setRotation(float a) {
    angle = a;
  }

  // --- CŒUR DU SYSTÈME : DÉTECTION AVEC ROTATION ---
  boolean contains(float x, float y) {
    // 1. Cercle (La rotation ne change rien)
    if (type == 0) {
      return dist(x, y, pos.x, pos.y) < r + 5;
    }
    
    // 2. Formes Rectangulaires (Square, Rect, Triangle approx)
    // On transforme le point du monde vers le repère local de l'obstacle
    float dx = x - pos.x;
    float dy = y - pos.y;
    
    // Rotation Inverse
    float localX = dx * cos(-angle) - dy * sin(-angle);
    float localY = dx * sin(-angle) + dy * cos(-angle);
    
    // Vérification AABB (Axis Aligned Bounding Box) locale
    // On ajoute une marge de 5px pour faciliter la sélection souris
    float margin = 5;
    return (abs(localX) < r + margin && abs(localY) < h + margin);
  }

  void display() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle); // Application de la rotation visuelle
    
    rectMode(CENTER);
    noStroke();
    
    // Couleur : Rouge si sélectionné, Noir sinon
    if (isSelected) {
      fill(255, 100, 100); // Rouge clair
      stroke(255, 0, 0);
      strokeWeight(2);
    } else {
      fill(0);
      noStroke();
    }
    
    if (type == 0) ellipse(0, 0, r*2, r*2);
    else if (type == 1) rect(0, 0, r*2, r*2); // Carré
    else if (type == 2) rect(0, 0, r*2, h*2); // Rectangle
    else if (type == 3) triangle(0, -h, -r, h, r, h);
    
    popMatrix();
  }
}
