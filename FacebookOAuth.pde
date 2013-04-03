import java.net.URL;
import java.net.MalformedURLException;
import java.lang.reflect.*;
import java.awt.*;
import java.awt.event.*;

import org.lobobrowser.gui.*;

/** 
 * Class FacebookOAuth
 *
 * author: Jorge C. S. Cardoso http://jorgecardoso.eu
 * 29 Oct 2010
 *
 * The FacebookOAuth class implements the OAuth authentication flow for desktop applications
 * necessary to use the Graph API (see: http://developers.facebook.com/docs/ and
 * http://developers.facebook.com/docs/authentication/desktop)
 *
 * Basically, it requests the Facebook OAuth authorization screen and displays it in a 
 * WebBrowser component window that pops up (the screen is not rendered in the Processing 
 * window - the LoboBrowser component is used (see: http://lobobrowser.org/browser/api-info.jsp)), 
 * and then intercepts the redirect issued by screen when the user authenticates.
 * The redirect URL contains the Access Token necessary to use the Graph API.
 *
 * Facebook provides several Dialog Form Factors for the authorization screen:
 * (from http://developers.facebook.com/docs/authentication/)
 * page - Display a full-page authorization screen (the default)
 * popup - Display a compact dialog optimized for web popup windows
 * wap - Display a WAP / mobile-optimized version of the dialog
 * touch - Display an iPhone/Android/smartphone-optimized version of the dialog
 * 
 * The page and popup seem to give problems to the Lobo browser component which this class uses to
 * render the web page, so it's probably best to stick with wap or touch.
 *
 * To use this class:
 
FacebookOAuth auth;
String clientID = "yourfacebookappidhere";

void setup() {
  size(200,200);
  auth = new FacebookOAuth(this, clientID, 500, 500, DFF_WAP, true);  
  
  // opens the browser window with the authentication page
  auth.authenticate(); 
}

void draw() {
 
}

// callback used to give the access token back to the application
void facebookAccessToken(String token) {
  
  println(token);
  
  // From this point on you can use the token to create Graph API requests:
  //String r = http.getWebPage("https://graph.facebook.com/me?fields=picture&"+token);
  
}
 *
 */

String DFF_PAGE = "page";
String DFF_POPUP = "popup";
String DFF_WAP = "wap";
String DFF_TOUCH = "touch";


public class FacebookOAuth implements ContentListener {
  
  
  /*
   * The browser window that opens to ask user credentials
   */
  Frame frame;
  
  /*
   * The width and height of the window that opens.
   */
  int windowWidth, windowHeight;
  
  /*
   * The dialog form factor. 
   * See: http://developers.facebook.com/docs/authentication/
   */
  String dialogFormFactor;
  
  /*
   * If true, will request offline access permissions.
   * See: http://developers.facebook.com/docs/authentication/permissions
   */
  boolean offlineAccess;
  
  /*
   * The Lobo browser
   */
  BrowserPanel webBrowser;
  
  /*
   * The Processing applet that is calling us.
   */
  PApplet parent;
  
  /*
   * The Facebook client ID. See: http://www.facebook.com/developers/createapp.php
   */
  String clientID;
  
  /*
   * The callback method on the Processing Applet. 
   * This method is called facebookAccessToken(String token)
   */
  Method callback;

   
  /*
   * Creates a FacebookOAuth object with the given parent PApplet and Facebook application id.
   */
  public FacebookOAuth(PApplet parent, String clientID) {
    this(parent, clientID, 400, 400, DFF_WAP, false);
  }
  
  /*
   * Creates a FacebookOAuth object with the given parent PApplet, 
   * Facebook application id, browser window width and height, 
   * Facebook dialog form factor and offline access permissions.
   */  
  public FacebookOAuth(PApplet parent, String clientID, int windowWidth, int windowHeight, String dialogFormFactor, boolean offlineAccess) {
    try {
      PlatformInit.getInstance().init(true, false);
      PlatformInit.getInstance().initLogging(false);
    } 
    catch (Exception e) {
      //println(e.getMessage());
    }
    
    webBrowser = new BrowserPanel(null, false, false, false); 

    webBrowser.addContentListener(this);
    
    this.parent = parent;
    this.clientID = clientID;
    this.windowWidth = windowWidth;
    this.windowHeight = windowHeight;
    this.dialogFormFactor = dialogFormFactor;
    this.offlineAccess = offlineAccess;
    
    // check to see if the host applet implements
    // public void facebookAccessToken(String token)
    try {
      callback =
        parent.getClass().getMethod("facebookAccessToken", new Class[] {"".getClass()});
    } 
    catch (Exception e) {
      // no such method, or an error.. which is fine, just ignore
    }    
  }

  /*
   * Displays the browser window to authenticate the user on Facebook.
   */
  public void authenticate() {
    initPanel(400, 400);
    String url = "https://graph.facebook.com/oauth/authorize?";
    url += "client_id="+clientID;
    url += "&redirect_uri=http://www.facebook.com/connect/login_success.html";
    url += "&type=user_agent";
    url += "&display="+dialogFormFactor;
    if (offlineAccess) {
      url += "&offlineAccess";
    }
    //println(url);
    setURL(url);

  }

  private void initPanel(int w,int h) {
    frame=new Frame();

    //frame.setLocation(50,50);
    //frame.setLayout(new BorderLayout());
    //frame.setUndecorated(true);

    //   Handle window close requests
    frame.addWindowListener(new WindowAdapter( ) {
      public void windowClosing(WindowEvent e) {
        frame.dispose();
      }
    }
    );


    frame.add(webBrowser,BorderLayout.CENTER);
    frame.pack();
    frame.setSize(w, h);
    frame.setVisible(true);
  }


  private void setURL(String url) {
    try {
      webBrowser.navigate(url);
    } 
    catch (MalformedURLException murle) {
    }
  }

  /*
   * called by the browser panel when the window contents change.
   * We use this to grab the facebook access token and pass it on the the Processing Applet.
   */ 
  public void contentSet(ContentEvent event) { 
    NavigationEntry ne = webBrowser.getCurrentNavigationEntry();
    if (ne != null) {
      String url = ne.getUrl().toString();
      int tokenIndex = url.indexOf("access_token");
      if (tokenIndex >= 0) {
        int tokenEnd = url.indexOf("&", tokenIndex+1);
        if (tokenEnd < 0) {
          tokenEnd = url.length()-1;
        }
        String token = url.substring(tokenIndex,tokenEnd);
        //println("----ok");
        frame.dispose();
        if (callback != null) {
          try {
            callback.invoke(parent, new Object[] {token }      );
          } 
          catch (Exception e) {
            //println("Disabling facebookAccessToken() because of an error.");
            e.printStackTrace();
            callback = null;
          }
        }
      }
    }
  }
}
