

//Parametres
boolean allumer = true;
boolean captureEcr = false;
int tauxDeCaptureEcr = 3;
int NY = 150;//200
int NX = 2*NY;//400
float A[][][] = new float[NX][NY][2];//0 actuel 1 ancien
float c = 0.075;

//Outils
float lentille[][] = {};// x,y,hauteur,largeur,indice
float mur[][] = {};
float sources[][] = {};//xD,yD,xA,yA,espace

//Mesures
float rCercle = NY/3.0;
float xCercle = NY/2.0, yCercle= NY/4.0;
float dephCercle = -90;
int pMesures = 150;
int nMesures = 0;
float Mesures[] = new float[pMesures];
float nMesuresI[] = new float[pMesures];
boolean cercle = true;
int yEcran = int(NY/2.0);
boolean capture = false;

//Placement
int vc = 3;
int cd = 0;
int temps = 0;

//Equation
float a1 = 1;
float a2 = 1;

//Sources
int pointsSource[][] = new int[NX][NY];
float periode = 100;//100
float ampSource = 0.5;

//Milieu
float indice[][] = new float[NX][NY];


void settings() {
  String para[] = loadStrings("parametre.txt");
  String fenetre[] = para[0].split(" ");
  size(int(fenetre[1]), int(fenetre[2]));
  NX = int(NY*width/height);

  for (int i = 0; i < NX; i ++) {
    for (int k = 0; k < NY; k ++) {
      for (int j = 0; j < 2; j ++) {
        A[i][k][j] = 0;
      }
      indice[i][k] = c;
    }
  }

  if (lentille.length > 0) {
    for (int m = 0; m < lentille.length; m ++) {
      float xd = lentille[m][0];
      float yd = lentille[m][1];
      float haut = lentille[m][2];
      float larg = lentille[m][3];
      float indiceL = lentille[m][4];
      for (int y = int(yd-haut/2); y < int(yd+haut/2); y ++) {
        for (int x = int(xd-(larg/2.0)*sin(PI*(y+haut/2-yd)/haut)); x < int(xd+(larg/2.0)*sin(PI*(y+haut/2-yd)/haut)); x ++) {
          indice[x][y] = c*indiceL;
        }
      }
    }
  }

  if (mur.length > 0) {
    for (int i = 0; i < mur.length; i ++) {
      float xD = mur[i][0], yD = mur[i][1], xA = mur[i][2], yA = mur[i][3], id = mur[i][4];
      if (xD-xA == 0) {
        if (yD-yA == 0) {
          indice[int(xD)][int(yD)] = id;
        } else {
          for (int y = int(min(yD, yA)); y < max(yD, yA); y++) {
            if (int(xD) < NX && y < NY && int(xD) > 0 && y > 0) {
              indice[int(xD)][y] = id;
            }
          }
        }
      } else {
        float m = (yA-yD)/(xA-xD);
        float p = yD-m*xD;
        float norme = sqrt((yA-yD)*(yA-yD)+(xA-xD)*(xA-xD));
        float pMur = abs(xD-xA)/norme;
        for (float x = (min(xD, xA)); x < max(xD, xA); x += pMur) {
          float y = m*x+p;
          indice[int(x)][int(y)] = 0;
        }
      }
    }
  }

  if (sources.length > 0) {
    for (int i = 0; i < sources.length; i ++) {
      float xD = sources[i][0], yD = sources[i][1], xA = sources[i][2], yA = sources[i][3];
      int espace = int(sources[i][4])+1;
      if (xD-xA == 0) {
        if (yD-yA == 0) {
          pointsSource[int(xD)][int(yD)] = 1;
        } else {
          for (int y = int(min(yD, yA)); y < max(yD, yA); y+= espace) {
            pointsSource[int(xD)][y] = 1;
          }
        }
      } else {
        float m = (yA-yD)/(xA-xD);
        float p = yD-m*xD;
        float norme = sqrt((yA-yD)*(yA-yD)+(xA-xD)*(xA-xD));
        float pMur = abs(xD-xA)/norme;
        for (float x = (min(xD, xA)); x < max(xD, xA); x += espace*pMur) {
          float y = m*x+p;
          pointsSource[int(x)][int(y)] = 1;
        }
      }
    }
  }
}


void draw() {

  if (allumer) {
    float nA[][] = new float[NX][NY];

    for (int i = 0; i < NX; i ++) {
      for (int j = 0; j < NY; j ++) {
        float coeff = indice[i][j];
        if (j == 0) {
          if (i == 0) {
            nA[i][j] = coeff*coeff*(A[i][j+1][0]+A[i+1][j][0]+A[i+1][j+1][0]-3*A[i][j][0])+(a1+a2)*A[i][j][0]-a1*A[i][j][1];
          } else if (i == NX-1) {
            nA[i][j] = coeff*coeff*(A[i][j+1][0]+A[i-1][j][0]+A[i-1][j+1][0]-3*A[i][j][0])+(a1+a2)*A[i][j][0]-a1*A[i][j][1];
          } else {
            nA[i][j] = coeff*coeff*(A[i][j+1][0]+A[i+1][j][0]+A[i-1][j][0]+A[i+1][j+1][0]+A[i-1][j+1][0]-5*A[i][j][0])+(a1+a2)*A[i][j][0]-a1*A[i][j][1];
          }
        } else if (j == NY-1) {
          if (i == 0) {
            nA[i][j] = coeff*coeff*(A[i][j-1][0]+A[i+1][j][0]+A[i+1][j-1][0]-3*A[i][j][0])+(a1+a2)*A[i][j][0]-a1*A[i][j][1];
          } else if (i == NX-1) {
            nA[i][j] = coeff*coeff*(A[i][j-1][0]+A[i-1][j][0]+A[i-1][j-1][0]-3*A[i][j][0])+(a1+a2)*A[i][j][0]-a1*A[i][j][1];
          } else {
            nA[i][j] = coeff*coeff*(A[i][j-1][0]+A[i+1][j][0]+A[i-1][j][0]+A[i+1][j-1][0]+A[i-1][j-1][0]-5*A[i][j][0])+(a1+a2)*A[i][j][0]-a1*A[i][j][1];
          }
        } else {
          if (i == 0) {
            nA[i][j] = coeff*coeff*(A[i][j+1][0]+A[i][j-1][0]+A[i+1][j][0]+A[i+1][j+1][0]+A[i+1][j-1][0]-5*A[i][j][0])+(a1+a2)*A[i][j][0]-a1*A[i][j][1];
          } else if (i == NX-1) {
            nA[i][j] = coeff*coeff*(A[i][j+1][0]+A[i][j-1][0]+A[i-1][j][0]+A[i-1][j+1][0]+A[i-1][j-1][0]-5*A[i][j][0])+(a1+a2)*A[i][j][0]-a1*A[i][j][1];
          } else {
            nA[i][j] = coeff*coeff*(A[i][j+1][0]+A[i][j-1][0]+A[i+1][j][0]+A[i-1][j][0]+A[i+1][j+1][0]+A[i+1][j-1][0]+A[i-1][j+1][0]+A[i-1][j-1][0]-8*A[i][j][0])+(a1+a2)*A[i][j][0]-a1*A[i][j][1];
          }
        }
      }
    }

    if (mousePressed == true && cd >= vc) {
      if (mouseButton == LEFT) {
        pointsSource[int(mouseX*NX/width)][int(mouseY*NY/height)] = 1;
      } else {

        pointsSource[int(mouseX*NX/width)][int(mouseY*NY/height)] = 0;
      }
      cd = 0;
    }

    if (cd < vc) {
      cd ++;
    }

    for (int i = 0; i < NX; i ++) {
      for (int j = 0; j < NY; j ++) {
        if (pointsSource[i][j] == 1) {
          nA[i][j] = ampSource*sin(2*PI*temps/periode);
        }
      }
    }

    for (int i = 0; i < NX; i ++) {
      for (int j = 0; j < NY; j ++) {
        A[i][j][1] = A[i][j][0];
        A[i][j][0] = nA[i][j];
      }
    }

    for (int i = 0; i < NX; i ++) {
      for (int j = 0; j < NY; j ++) {
        fill((A[i][j][0]+0.5)*255/1.5);
        stroke((A[i][j][0]+0.5)*255/1.5);
        rect(i*width/NX, j*height/NY, float(width)/NX, float(height)/NY);
      }
    }

    if (capture) {
      boolean mes = false;
      for (int i = 0; i < pMesures; i ++) {
        float angle = radians(i*180.0/pMesures+dephCercle);
        int xM = 0, yM = 0;
        if (cercle) {
          xM = int(xCercle+cos(angle)*rCercle);
          yM = int(yCercle+sin(angle)*rCercle);
        } else {
          xM = int(NX*i/pMesures);
          yM = (yEcran);
        }
        fill(0, 200, 0);
        noStroke();
        rect(xM*width/NX, yM*height/NY, float(width)/NX, float(height)/NY);
        if (xM < 0) {
          xM = 0;
        } else if (xM > NX-1) {
          xM = NX-1;
        }
        if (yM < 0) {
          yM = 0;
        } else if (yM > NY-1) {
          yM = NY-1;
        }
        if (A[xM][yM][0] != 0) {
          Mesures[i] += abs(A[xM][yM][0]);
          nMesuresI[i] ++;
          mes = true;
        }
      }
      if (mes) {
        nMesures ++;
      }
    }

    for (int i = 0; i < NX; i ++) {
      for (int j = 0; j < NY; j ++) {
        if (i > 0 && j > 0) {
          float diffh = indice[i][j]-indice[i][j-1];
          float diffg = indice[i][j]-indice[i-1][j];
          stroke(255, 0, 0);
          if (diffh != 0) {
            stroke(100+abs(diffh)*155/c, 0, 0);
            line(i*width/NX, j*height/NY, (i+1)*width/NX, j*height/NY);
          }
          if (diffg != 0) {
            stroke(100+abs(diffg)*155/c, 0, 0);
            line(i*width/NX, j*height/NY, i*width/NX, (j+1)*height/NY);
          }
        }
      }
    }

    temps ++;
    if (temps%tauxDeCaptureEcr == 0 && captureEcr == true) {
      saveFrame("images/frames-######");
    }
  }
}


void keyPressed() {
  println(keyCode);
  println(max(nMesuresI));
  if (keyCode == 83 && max(nMesuresI) > 0) {//s
    String save[] = new String[pMesures];
    for (int i = 0; i < pMesures; i ++) {
      Mesures[i] /= nMesuresI[i];
      save[i] = str(Mesures[i]);
    }
    saveStrings("ecran.txt", save);
    println("save ! ");
  }
}
