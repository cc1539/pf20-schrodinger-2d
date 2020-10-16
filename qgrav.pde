
float multiplyReal(float a, float b, float c, float d) {
  return a*c-b*d;
}

float multiplyImag(float a, float b, float c, float d) {
  return b*c+a*d;
}

float getLagrangian(float[][] in, int x, int y) {
  int w = in.length;
  int h = in[0].length;
  float value = 0;
  for(int i=-1;i<=1;i++) {
  for(int j=-1;j<=1;j++) {
    boolean i1 = i!=0;
    boolean j1 = j!=0;
    float factor = (i1&&j1)?0.05:(i1||j1)?0.2:-1;
    int u = x+i; if(u<0){u+=w;}else if(u>=w){u=0;}
    int v = y+j; if(v<0){v+=h;}else if(v>=h){v=0;}
    value += factor*in[u][v];
  }
  }
  return value;
}

void multiply(int i, int j, float re, float im) {
  float dre = multiplyReal(data[0][i][j],data[1][i][j],re,im);
  float dim = multiplyImag(data[0][i][j],data[1][i][j],re,im);
  float bre = multiplyReal(back[0][i][j],back[1][i][j],re,im);
  float bim = multiplyImag(back[0][i][j],back[1][i][j],re,im);
  data[0][i][j] = dre;
  data[1][i][j] = dim;
  back[0][i][j] = bre;
  back[1][i][j] = bim;
}

float[][][] data;
float[][][] back;
int w;
int h;

PGraphics canvas;

void step(float dt) {
  for(int i=0;i<w;i++) {
  for(int j=0;j<h;j++) {
    //float mag = sqrt(pow(data[0][i][j],2)+pow(data[1][i][j],2));
    //float ldt = min(max(dt*(1-mag*5e-1),0),1);
    //float ldt = dt*(1-1.5/((pow(i-w/2,2)+pow(j-h/2,2))*1e-3+1));
    float ldt = dt;
    back[1][i][j] += getLagrangian(data[0],i,j)*ldt;
    back[0][i][j] -= getLagrangian(data[1],i,j)*ldt;
  }
  }
  float[][][] temp = data;
  data = back;
  back = temp;
}

void reset() {
  for(int i=0;i<w;i++) {
  for(int j=0;j<h;j++) {
    float jitter = 1e-3;
    data[0][i][j] = random(-1,1)*jitter;
    data[1][i][j] = random(-1,1)*jitter;
    back[0][i][j] = random(-1,1)*jitter;
    back[1][i][j] = random(-1,1)*jitter;
  }
  }
}

void setup() {
  size(840,840);
  noSmooth();
  w = width/4;
  h = height/4;
  canvas = createGraphics(w,h,JAVA2D);
  canvas.beginDraw();
  canvas.loadPixels();
  canvas.endDraw();
  data = new float[2][w][h];
  back = new float[2][w][h];
  reset();
}

void keyPressed() {
  switch(key) {
    case 'c': {
      reset();
    } break;
  }
}

void draw() {
  if(mousePressed) {
    float vx = (mouseX-pmouseX)*.1;
    float vy = (mouseY-pmouseY)*.1;
    float x = (float)mouseX/width*w;
    float y = (float)mouseY/height*h;
    if(mouseButton==LEFT) {
      for(int i=0;i<w;i++) {
      for(int j=0;j<h;j++) {
        float dx = i-x;
        float dy = j-y;
        float dst2 = dx*dx+dy*dy;
        if(dst2<400) {
          float amp = .1/(exp(dst2/100));
          float phs = (dx*vx+dy*vy)*.1;
          float re = amp*cos(phs);
          float im = amp*sin(phs);
          data[0][i][j] += re;
          data[1][i][j] += im;
          back[0][i][j] += re;
          back[1][i][j] += im;
        }
      }
      }
    } else if(mouseButton==RIGHT) {
      for(int i=0;i<w;i++) {
      for(int j=0;j<h;j++) {
        float phs = (i*vx+j*vy)*.01;
        multiply(i,j,cos(phs),sin(phs));
      }
      }
    } else {
      for(int i=0;i<w;i++) {
      for(int j=0;j<h;j++) {
        float phs = -sqrt(pow(i-x,2)+pow(j-y,2))*.1;
        multiply(i,j,cos(phs),sin(phs));
      }
      }
    }
  }
  for(int t=0;t<20;t++) {
    step(1);
  }
  canvas.beginDraw();
  for(int i=0;i<w;i++) {
  for(int j=0;j<h;j++) {
    float re = data[0][i][j]*10;
    float im = data[1][i][j]*10;
    float mag = sqrt(re*re+im*im);
    canvas.pixels[i+j*w] = (keyPressed&&key==' ')?color(mag*255):color(abs(re)*255,0,abs(im)*255);
  }
  }
  canvas.updatePixels();
  canvas.endDraw();
  image(canvas,0,0,width,height);
  
  surface.setTitle("FPS: "+frameRate);
}
