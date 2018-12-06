Boolean SETBUTTS = false; //<>// //<>// //<>//
Boolean initTF = true;
String ExecStr;
int colorMode = 2;


void Restart() {
  setup();
}

void SetColorSwitch() {
  println("==>SetColorSwitch()");
  println(colorMode);

  if (colorMode == 1) {
    println("1");
    for (Slider slider : c2Sliders) {
      println(slider.getName());      
      slider.hide();
    }
    for (Slider slider : c1Sliders) {
      slider.show();
    }
  } else {
    for (Slider slider : c1Sliders) {
      slider.hide();
    }
    for (Slider slider : c2Sliders) {
      slider.show();
    }
  }
}

void Router(String go, String msg) {  //
  println("<--- Router(go, msg: " 
    +go
    +", "
    +msg
    );

  String updateText = "";

  if (go == "hue" || go == "brightness" ) {
    println("-----------------------------------what is hue value?  "+hue);
    cPick = color(hue, 100, brightness, 100);
    offBlack = color (hue*.25, 25, brightness*.25);
    c1Sliders[0].setColorBackground(color(hue, 0, 100, 20));
    c1Sliders[0].setColorForeground(color(hue, 0, 100));
    c1Sliders[0].setColorActive(color(hue, 0, 100));
    println ("SEEEEE "+SETBUTTS);

    if (SETBUTTS) {  // the slider change conditions should only be reached when SETBUTTS, anyway, but this ensures no GUI events get confused.
      for (Light light : lights) {
        butts[light.buttI].setColorForeground(cPick); // foreground is when hovered  //DEBUG
        //butts[light.buttI].setColorActive(cPick);  // active is when ON
      }
      //> add change hover for setAll_B
      setAll_B.setColorForeground(cPick);
    }
  }
  if (go == "rgbR" || go == "rgbG" || go == "rgbB") {
    cPick = color(rgbR, rgbG, rgbB, 100);
    offBlack = color (rgbR*.25, rgbG*.25, rgbB*.25);
    println ("SEEEEE "+SETBUTTS);

    if (SETBUTTS) {  // the slider change conditions should only be reached when SETBUTTS, anyway, but this ensures no GUI events get confused.
      for (Light light : lights) {
        butts[light.buttI].setColorForeground(cPick); // foreground is when hovered  //DEBUG
        //butts[light.buttI].setColorActive(cPick);  // active is when ON
      }
      //> add change hover for setAll_B
      setAll_B.setColorForeground(cPick);
    }
  }



  switch(go) {

  case "colormode_rb":
    int c = int(cm_rb.getValue());
    println (c);
    if (c<0) cm_rb.activate(0);
    if (c==2) {
      colorMode = 2;
    } else {
      colorMode = 1;
    }
    SetColorSwitch();
    break;
  case "SetupGrp":
    if (Boolean.parseBoolean(msg)) {
    } else {
      int lc = int(sliders[0].getValue());
      int zc = int(sliders[1].getValue());

      println("**************************************************************cone_count= "+lc);
      println("**************************************************************scanner_count= "+zc+" "+scannerCount);

      if ((coneCount != lc) || (scannerCount !=zc)) {
        coneCount = lc;
        scannerCount = zc;
        updateText = (coneCount +" cones / "+scannerCount+" scanners; redrawing grid");
        Start();
      }
    }
    break;

    //case "start":
    //  UnPause();
    //  break;
  case "exec_B":
    MakeExecStr();

    //UpdateUI(ExecStr);
    if (CONNECTED) {
      println ("hey bozo: "+ExecStr);

      WritePort(ExecStr);
    } else {
      println("try to connect");
      try {
        port= new Serial(this, Serial.list()[0], 9600);
        //if (Serial.list()[0].isEmpty()) {        }
        updateText = "Wahooo! connected @ "+Serial.list()[0];

        Com=Serial.list()[0];
        CON_CHANGED = true;
      } 
      catch (Exception e) {
        updateText = "Booo, can't find a valid serial connection!  :(";
      }
      //println ("not connected");
      //UpdateUI("No serial connectin has been achieved.");
    }

    break;
  case "program_gr": // GUI group 3, program menu
    SETBUTTS = Boolean.parseBoolean(msg);  //str convert message to bool true/false

    if (SETBUTTS) { //if menu is open, change light buttons to program mode
      for (int i = 0; i<lightCount; i++) {
        //color1[i]=butts[i].getColor().getForeground(); //get the current BG color
        lights[i].Program(Boolean.valueOf(msg), i);
      }
      setAll_B.show();
    } else {  //leaving program mode; restore the colors to the BG color
      for (int i = 0; i<lightCount; i++) {
        //butts[i].setColorBackground(colBG[i]);
        lights[i].Program(Boolean.valueOf(msg), i);
        //println(hex(color1[i], 6));
        //colBG[i]=butts[i].getColor().getBackground(); //get the current BG color
        //lights[i].Program(Boolean.valueOf(msg), i);
      }
      setAll_B.hide(); //hide setall button
    }

    break;
  case "cone_count":
    break;
  case "setAll_B":
    for (int i = 0; i<lightCount; i++) {
      SetLight(i);
    }
    break;
  case "connect_B":
    if (!CONNECTED) {
      try {
        port= new Serial(this, Serial.list()[0], 9600);
        //if (Serial.list()[0].isEmpty()) {        }
        updateText = "Wahooo! connected @ "+Serial.list()[0];

        Com=Serial.list()[0];
        CON_CHANGED = true;
      } 
      catch (Exception e) {
        updateText = "Booo, can't find a valid serial connection!  :(";
      }
    } else {
      updateText = "Ok, I'll disconnect...";
      CON_CHANGED=true;
    }
    break;
  case "out":
    updateText = msg;
    if (CONNECTED) {
      updateText = "dance, slime! "+updateText;
      //Router("exec_B", ""); //send to the execute routine to sweep all the lights to the serial port
      return;
    } else {
      updateText = "set msg: " + updateText;
    }
    break;
  default:
    println("default case, no actions here yet");
    return; //this return breaks the light button listener event to prevent the rest of router control
  }
  UpdateUI(updateText);
  console.scroll(.9);
}

public void colormode_rb() {
  println ("> colormode radiobutton event");
}
//**************************************************************
void controlEvent(ControlEvent theEvent) {
  println("*** GUI EVENT");
  String conName="";
  if (theEvent.isController()) {
    conName =  theEvent.getController().getName();
    println ("This isController: "+conName);
    Router(conName, null);
  }
  if (theEvent.isGroup()) {
    //? radiobutton is also a group. what to do with that?
    String ISOPEN = str(theEvent.getGroup().isOpen());
    println("got an event from group "
      +theEvent.getGroup().getName()
      +", isOpen? "+theEvent.getGroup().isOpen()
      );
    conName =  theEvent.getGroup().getName();
    Router(conName, ISOPEN);
  }
}
