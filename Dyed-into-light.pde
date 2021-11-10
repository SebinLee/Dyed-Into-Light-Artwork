import org.openkinect.processing.*;
import org.openkinect.freenect.*;
import processing.video.*;

//Create Kinect, Video Object
Kinect kinect;
Movie background;

//Declaration Global Variable
PImage display;

int threshold = 750;
int[] depth;
float angle;
float video_height;
float video_width;
float video_loc_x;
float video_loc_y;
float video_threshold = 10;
boolean recognized = false;
boolean videoMode = false;

void setup() {
    //size(640,480);
    fullScreen();
    background(0);
    
    //Initialize Kinect
    kinect = new Kinect(this);
    kinect.initDepth();
    kinect.initVideo();
    angle = kinect.getTilt();

    //Initialize Background Video variable
    //Loop Infinite till the program ends
    background = new Movie(this, "DyedIntoLight.mp4");
    background.loop();
    
    //Make Secondary window to check what kinect seeing
    //second_win = new PWindow();
    
    //Make Blank Image
    display = createImage(640, 480, RGB);
    
    //Check Video Size
    check_videosize();
  
}

void draw() {    
    if(videoMode == false) {
      image(background, video_loc_x, video_loc_y, video_width, video_height);
      display();
    }
    else {
      image(kinect.getVideoImage(),video_loc_x,video_loc_y,video_width,video_height);
    }
}

void display() {
    depth = kinect.getRawDepth();
    
    // Being overly cautious here
    if (kinect == null) return;
    if (depth == null) return;

    //Make recognized to false
    recognized = false;

    // Going to rewrite the depth image to show which pixels are in threshold
    display.loadPixels();
    for (int x = 0; x < kinect.width; x++) {
      for (int y = 0; y < kinect.height; y++) {

        int offset = x + y*kinect.width;
        // Raw depth
        int rawDepth = depth[offset];
        int pix = x + y*display.width;
        if (rawDepth < threshold) {
          //Transparent Pixel to show Background Video
          display.pixels[pix] = color(0,0,0,0);
          recognized = true;
        } else {
          display.pixels[pix] = color(0,0,0);
        }
      }
    }
    display.updatePixels();
    
    // Draw the image
    // If no one recognized, show background video.
    if(recognized == true) {image(display, video_loc_x+video_threshold, video_loc_y+video_threshold, video_width-(video_threshold*2), video_height-(video_threshold*2));}
    //image(display, video_loc_x, video_loc_y, video_width, video_height);
}

void check_videosize() {
    video_height = height;
    video_width = height / 3 * 4;
    video_loc_x = (width-video_width)/2;
    video_loc_y = 0;
}

void showinfo() {
    println("-------------------------------");
    println("Tilt : " + angle);
    println("Threshold : " + threshold);
    println("Video Threshold : " + video_threshold);
    println("-------------------------------");
}

void movieEvent(Movie m) {
  m.read();
}

void keyPressed() {
    if(key==CODED) {
        if(keyCode==UP) {threshold++;}
        else if(keyCode==DOWN) {threshold--;}
        else if(keyCode==LEFT) {threshold-=5;}
        else if(keyCode==RIGHT) {threshold+=5;}
        showinfo();
    }
    else if(key=='u') {
        angle++;

        //constrain angle's range
        angle = constrain(angle,0,30);
        kinect.setTilt(angle);

        showinfo();
    }
    else if(key=='d') {
        angle--;

        //constrain angle's range
        angle = constrain(angle,0,30);
        kinect.setTilt(angle);
        showinfo();
    }
    else if(key=='i') {
        showinfo();
    }
    else if(key=='v') {
      if(videoMode == false) {
        videoMode=true;
        background.pause();
      }
      else {
        videoMode = false;
        background.play();
      }
    }
    else if(key=='[') {
      video_threshold-=5;
    }
    else if(key == ']') {
      video_threshold+=5;
    }
}
