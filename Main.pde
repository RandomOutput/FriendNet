import com.francisli.processing.http.*;

ArrayList nodes;
HttpClient myClient;

FacebookOAuth auth;
String clientID = "489785564410684";
HTTP http;
String token = "";
Boolean dataPulled = false;

void setup()
{
  myClient = new HttpClient(this, "graph.facebook.com");
  myClient.useSSL = true;
  http = new HTTP();
  
  size(700,700);
  background(50,50,100);
  nodes = new ArrayList();
  randomDist();
  
  auth = new FacebookOAuth(this, clientID, 500, 500, DFF_WAP, true);  
  
  // opens the browser window with the authentication page
  auth.authenticate(); 
}

void randomDist()
{
  for(int i=0; i<500; i++)
  {
    nodes.add(new Node(random(700), random(700)));
  }
}

void draw()
{
  /*
  if(token != "" && dataPulled == false)
  {
    String r = http.getWebPage("https://graph.facebook.com/me?fields=&"+token);
    println();
    println("***RESPONSE***");
    println(r);
    dataPulled = true;
  }*/
  
  for(int i=0;i<nodes.size();i++)
  {
    Node node = (Node)nodes.get(i);
    node.draw();
  }
}

// callback used to give the access token back to the application
void facebookAccessToken(String _token) {
  
  println(_token);
  _token = _token.substring(_token.indexOf("=") + 1, _token.length());
  token = _token;
  //println(token);
  // From this point on you can use the token to create Graph API requests:
  //String r = http.getWebPage("https://graph.facebook.com/me?fields=picture&"+token);
  
  HashMap params = new HashMap();
  params.put("access_token", token);
  params.put("fields", "friends");
  
  
  myClient.GET("me", params);
}

void responseReceived(HttpRequest request, HttpResponse response) {
  // print the json response as a string
  println(response.getContentAsString());
}
