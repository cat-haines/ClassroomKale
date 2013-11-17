
/* GLOBALS AND CONSTS --------------------------------------------------------*/


/* GLOBAL FUNCTIONS ANDF CLASS DEFINITIONS -----------------------------------*/

function overWaterDet() {
    local lvl = lvl_sns.read();
    imp.sleep(0.05);            // debounce
    if (lvl) {
        agent.send("overWater",1);
        pump.write(0);          // immediately stop pump
    } else {
        agent.send("overWater",0);
    }
}

/* REGISTER AGENT CALLBACKS --------------------------------------------------*/
// set the color. Takes an RGB Tuple. All zeros to turn off.
agent.on("setPump", function(value) {
    pump.write(value);
});

/* RUNTIME BEGINS HERE -------------------------------------------------------*/

imp.configure("Megan Kale Pump Manager",[],[]);
imp.enableblinkup(true);
server.log("Imp running SW V: "+imp.getsoftwareversion());

/* pin assignments -------------------------------------------------------------
pin1 - SO1 (sensor output 1, 5V analog gas sensor) - not used here (need parts)
pin5 - pump Control (DIGITAL_OUT)
------------------------------------------------------------------------------*/
pump <- hardware.pin1;
pump.configure(DIGITAL_OUT);
// make sure the pump is off on device restart.
pump.write(0);

lvl_sns <- hardware.pin2;
lvl_sns.configure(DIGITAL_IN_PULLUP, overWaterDet);

/* done with pin assignment / configuration ----------------------------------*/

