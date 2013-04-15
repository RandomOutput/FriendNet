class Node
{
  public float x = 0;
  public float y = 0;
  public String id = "";
  public String name;
  public HashMap nodeConnections;
  
  Node(float _x, float _y)
  {
    x = (int)_x;
    y = (int)_y;
    name = "";
    nodeConnections = new HashMap();
  }
  
  Node(float _x, float _y, String _name, String _id)
  {
    x = (int)_x;
    y = (int)_y;
    id = _id;
    name = _name;
    nodeConnections = new HashMap();
  }
  
  void draw()
  {
    if(this.x < 0) this.x = 10;
    else if(this.x > 1200) this.x = 1190;
    
    if(this.y < 0) this.y = 10;
    else if(this.y > 700) this.y = 690;
    
    
    fill(200,200,256);
    stroke(120,120,200);
    ellipseMode(CENTER);
    ellipse(x,y,2,2);
    fill(220, 80, 80, 256);
    textSize(7);
    text(name, x+3, y+2); 
    
    
    
    
  }
}
