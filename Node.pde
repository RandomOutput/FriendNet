class Node
{
  public int x = 0;
  public int y = 0;
  public String name;
  
  Node(float _x, float _y)
  {
    x = (int)_x;
    y = (int)_y;
    name = "";
  }
  
  Node(float _x, float _y, String _name)
  {
    x = (int)_x;
    y = (int)_y;
    name = _name;
  }
  
  void draw()
  {
    noFill();
    stroke(60,60,100);
    ellipseMode(CENTER);
    ellipse(x,y,10,10);
    fill(200, 100, 100, 50);
    textSize(10);
    text(name, x, y); 
  }
}
