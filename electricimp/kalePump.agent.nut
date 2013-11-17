
server.log("Megan Irrigation MGR Agent Started");

/* GLOBAL VARS AND CONSTS ----------------------------------------------------*/
const BOSSURL = "https://agent.electricimp.com/i8UugRGJORm2";

/* GLOBAL FUNCTIONS AND CLASSES ----------------------------------------------*/

/* DEVICE CALLBACKS ----------------------------------------------------------*/
device.on("overWater", function(overWaterDet) {
    if (overWaterDet) {
        server.log("plant overwatered!");
    } else {
        server.log("overwater condition cleared.");
    }
    
});

/* GENERAL HTTP REQUEST HANDLER ----------------------------------------------*/
http.onrequest(function(req, res) {
    server.log("Got new request: "+req.body);
    local reqBody = {};
    try {
        reqBody = http.jsondecode(req.body);
    } catch (err) {
        server.error("Error parsing request body as JSON: "+err);
        res.send(400, err);
    }
    
    if ("command" in reqBody) {
        if (reqBody.command == "pump") {
            device.send("setPump",reqBody.value);
            res.send(200, "OK");
            return;
        } 
    }
    
    res.send(400, "unknown command");
});