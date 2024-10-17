import java.util.*;

Graph invoker;
List<Integer> contourColors;


enum Color{B, W, G}

class DC{
  int rowD;
  int colD;
  DC(int x, int y){rowD = x; colD = y;}
}

class Graph{
  Pixel[][] board;
  int contourCount;
  Contour[] vertex;
  DC[] circleArr;
  ArrayList<Contour>[] colourUnion;
  
  
  Graph(){
    circleArr = new DC[]{
      new DC(-3, 0), new DC(0, 3),
      new DC(-2, -1), new DC(-2, 0), new DC(-2, 1),
      new DC(-1, -2), new DC(-1, -1), new DC(-1, 0), new DC(-1, 1), new DC(-1, 2),
      new DC(0, -2), new DC(0, -1), new DC(0, 0), new DC(0, 1), new DC(0, 2),
      new DC(1, -2), new DC(1, -1), new DC(1, 0), new DC(1, 1), new DC(1, 2),
      new DC(2, -1), new DC(2, 0), new DC(2,1)
    };
    board = new Pixel[height][width];
    int row = 0;
    int col = 0;
    contourCount = 0;
    for(int i = 0; i < pixels.length; i++){
      board[row][col++] = new Pixel(col, row, i, pixels[i] == color(255));
      if((i+1)%width == 0){
        row++;
        col = 0;
      }
    }
    setAdjList();
    
  }
  
  void setVertex(){
    vertex = new Contour[contourCount];
    for(int i = 0; i < vertex.length; i++){
      vertex[i] = new Contour();
      vertex[i].contourNum = i;
      vertex[i].adjContours = new ArrayList<Contour>();
    }
  }
  
  class Contour{
    int contourNum;
    List<Contour> adjContours;
    int adjNum;
    int colour;
    String toString(){
      return ""+contourNum;
    }
  }
  
  class Pixel{
    boolean isWhite;
    //Pixel head;
    List<Pixel> adj;
    int x;
    int y;
    int i;
    Color colour;
    int contourIndex;
    
    
    Pixel(int x, int y, int i, boolean isWhite){
      adj = new ArrayList<>();
      //head = this;
      this.x = x;
      this.y = y;
      this.i = i;
      this.isWhite = isWhite;
      contourIndex = -1;
    }
    String toString(){
      return this.x + " " + this.y;
    }
  }
  
  void setAdjList(){
      for(int i = 0; i < board.length; i++){
        for(int j = 0; j < board[0].length; j++){
          Pixel n = board[i][j];
          //System.out.println(n.isWhite);
          if(!n.isWhite) continue;
          //n.adj = new ArrayList<>();
          boolean left = false, right = false, top = false, down = false;
          if(i != 0){
            top = true;
            Pixel test = board[i-1][j];
            if(test.isWhite)
              n.adj.add(test);
          }
          if(i != board.length-1){
            down = true;
            Pixel test = board[i+1][j];
            if(test.isWhite)
              n.adj.add(test);
          }
          if(j != 0){
            left = true;
            Pixel test = board[i][j-1];
            if(test.isWhite)
              n.adj.add(test);
          }
          if(j != board[0].length-1){
            right = true;
            Pixel test = board[i][j+1];
            if(test.isWhite)
              n.adj.add(test);
          }
          if(top && left){
            Pixel test = board[i-1][j-1];
            if(test.isWhite)
              n.adj.add(test);
          }
          if(top && right){
            Pixel test = board[i-1][j+1];
            if(test.isWhite)
              n.adj.add(test);
          }
          if(down && left){ 
            Pixel test = board[i+1][j-1];
            if(test.isWhite)
              n.adj.add(test);
          }
          if(down && right){
            Pixel test = board[i+1][j+1];
            if(test.isWhite)
              n.adj.add(test);
          }
        }
      }
    }
  
  
  void BFS(Pixel[][] G, Pixel s){
      for(Pixel[] nodes : G){
        for(Pixel u : nodes){
          if(u == null) continue;
          if(u != s){
            u.colour = Color.W;

          }
        }
      }
      s.colour = Color.G;

      s.contourIndex = contourCount;
      ArrayDeque<Pixel> Q = new ArrayDeque<>();
      Q.offer(s);
      while(!Q.isEmpty()){
        Pixel u = Q.poll();
        for(Pixel v : u.adj){
          if(v.colour == Color.W){
            v.contourIndex = contourCount;
            v.colour = Color.G;

            Q.offer(v);
          }
        }
        u.colour = Color.B;
      }
    }
    
    void adjDiscovCircle(){
      for(int row = 0; row < board.length; row++){
        for(int col = 0; col < board[0].length; col++){
          checkArea(row, col);
        }
      }
    }
    
    void checkArea(int row, int col){
      Pixel temp = null;
      Main: for(DC cp : circleArr){
        int r = row + cp.rowD;
        int c = col + cp.colD;
        if((r < height-1 && r > 0) && (c < width-1 && c > 0)){
          Pixel p = board[r][c];
          if(p.isWhite){
            if(temp == null) temp = p;
            else if(temp.contourIndex != p.contourIndex){
              int tc = temp.contourIndex;
              int pc = p.contourIndex;
              if(!vertex[tc].adjContours.contains(vertex[pc])){
                vertex[tc].adjContours.add(vertex[pc]);
                vertex[pc].adjContours.add(vertex[tc]);
                vertex[tc].adjNum++;
                vertex[pc].adjNum++;
              }
              break Main;
            }
          }
        }
      }
    }
    
    void WelshPowell(){
      Arrays.sort(vertex, (Contour o1, Contour o2) -> o2.adjNum - o1.adjNum);
      colourUnion = new ArrayList[4];
      for(int i = 0; i < colourUnion.length; i++){
        colourUnion[i] = new ArrayList<Contour>();
      }
      int colour = 1;
      for(int i = 0; i < vertex.length; i++){
        Contour c = vertex[i];
        if(c.colour == 0){
          c.colour = colour;
          colourUnion[colour-1].add(c);
          
          
          INNER: for(int j = 0; j < vertex.length; j++){
            Contour t = vertex[j];
            if(t.colour == 0){
              for(Contour temp : colourUnion[colour-1]){
                if(temp.adjContours.contains(t)) continue INNER;
              }
              t.colour = colour;
              colourUnion[colour-1].add(t);
            }
          }
          colour++;
          
        }
      }
    }
    
    void colorBoard(){
      int[] colorPalette = new int[]{color(255,255,0), color(0, 255, 0), color(0,0,255), color(127, 0, 255)};
      Arrays.sort(vertex, (Graph.Contour o1, Graph.Contour o2) -> o1.contourNum - o2.contourNum);
      for(int row = 0; row < board.length; row++){
        for(int col = 0; col < board[0].length; col++){
          Pixel p = board[row][col];
          if(!p.isWhite) continue;
          if(p.contourIndex == 0){
            set(col, row, color(0));
          }
          else{
            Contour c = vertex[p.contourIndex];
            set(col, row, colorPalette[c.colour-1]);
          }
        }
      }
    }
  
}

PImage img;
void setup(){
  fill(100, 0, 0);
  size(1080/2, 1439/2);
  img = loadImage("image2.png");
  image(img, 0, 0, 1080/2, 1439/2);
  //filter(GRAY);
  filter(THRESHOLD, 0.5);
  loadPixels();
  
  invoker = new Graph();
  FourColorCat.Graph.Pixel[][] board = invoker.board;
  for(int row = 0; row < board.length; row++){
    for(int col = 0; col < board[0].length; col++){
      Graph.Pixel p = board[row][col];
      if(p.isWhite && p.contourIndex == -1){
        invoker.BFS(board, p);
        invoker.contourCount++;
      }
      
    }
  }
  invoker.setVertex();
  invoker.adjDiscovCircle();
  invoker.WelshPowell();
  invoker.colorBoard();
  saveFrame("pic.jpeg");
}
