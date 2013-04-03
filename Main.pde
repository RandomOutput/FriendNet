import com.francisli.processing.http.*;
import com.francisli.processing.http.JSONObject;

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
  //randomDist();
  
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
  
  if(token != "" && dataPulled == false)
  {
    HashMap params = new HashMap();
    params.put("access_token", token);
    params.put("fields", "friends");
    
    
    myClient.GET("me", params);
    dataPulled = true;
  }
  
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

}

void responseReceived(HttpRequest request, HttpResponse response) {
  // print the json response as a string
  //println(response.getContentAsString());
  
  if (response.statusCode == 200) {
    JSONObject results = response.getContentAsJSONObject();
 
    // get just the list of artists
    JSONObject allFriends = results.get("friends").get("data");
 
    // we asked for a JSON response from Songkick, so use size() and get() to access elements
    for (int i = 0; i < allFriends.size(); i++) {
      // get the displayName element in the array and return as a String
      String friendName = allFriends.get(i).get("name").stringValue();
      nodes.add(new Node(random(700), random(700), friendName));
      // print out the name
      println("Name " + i + ": " + friendName);
    }
  } else {
    // output the entire response as a string
    println(response.getContentAsString());
  }
}
