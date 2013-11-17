
server.log("Megan's Agent Started");

const PUMPURL = "https://agent.electricimp.com/-mUWyOZU-rSA";
const FIREBASEKEY = "hTLP2BGVh1qXdm1AtnBSE6Yb7wkquIqYjLwaBSlO";
const DBASE = "classroomkale";
const FBRATELIMIT = 1; //minimum time between firebase posts

// Device Status
STATS <- {temperature = 0, humidity = 0, pump = 0, light = "000000", overflow = 0, timestamp = 0};
SCHED <- {lights = [], pump = [], color = 0};

/* GLOBAL FUNCTIONS AND CLASSES ----------------------------------------------*/

function postUpdate() {
    // rate limit firebase posts
    if (time() - STATS.timestamp < FBRATELIMIT) {
        // rate limited. Do nothing.
        server.log("firebase update rate limited.");
        return;
    }
    
    // timestamp our current stats
    STATS.timestamp = time();
    
    // post current stats to firebase "current status" store
    fbase.set_path("kales/1/status");
    fbase.update(STATS);
    
    // add the most recent status update to the firebase history as well
    fbase.set_path("kales/1/data-points");
    fbase.push(STATS);
    
    server.log("Firebase update posted.");
    foreach(key,val in STATS) {
        server.log(key+" : "+val);
    }
}

function setPump(value) {
    local reqData = {"command":"pump", "value":value};
    local req = http.post(PUMPURL,{},http.jsonencode(reqData));
    local res = req.sendsync();
    server.log("Sent pump request, got: "+res.body);
    STATS.pump = value;
    postUpdate();
}

function secondsTill(targetTime) {
    local data = split(targetTime,":");
    local target = { hour = data[0].tointeger(), min = data[1].tointeger() };
    local now = date(time() - (3600 * 8));
    
    if ((target.hour < now.hour) || (target.hour == now.hour && target.min < now.min)) {
        target.hour += 24;
    }
    
    local secondsTill = 0;
    secondsTill += (target.hour - now.hour) * 3600;
    secondsTill += (target.min - now.min) * 60;
    return secondsTill;
}

function waterDose(vol) {
    // our pump doses the plants with 0.67 mL per second 
    local doseTime = (vol.tointeger() * 1.0) / (0.67);
    return doseTime;
}

function hexdec(c) {
    if (c <= '9') {
        return c - '0';
    } else {
        return 0x0A + c - 'A';
    }
}
function decodeColorString(colorString) {
    colorString = colorString.toupper();
    local rStr = colorString.slice(0,2);
    local gStr = colorString.slice(2,4);
    local bStr = colorString.slice(4,6);
    
    local red = (hexdec(rStr[0]) * 16) + hexdec(rStr[1]);
    local green = (hexdec(gStr[0]) * 16) + hexdec(gStr[1]);
    local blue = (hexdec(bStr[0]) * 16) + hexdec(bStr[1]);

    local rgbTuple = {r=red,g=green,b=blue};
    return rgbTuple;
}

function lightsOnSched() {
    server.log("Executing Scheduled Lights-On.");
    device.send("setColor",decodeColorString(SCHED.color));
}

function lightsOffSched() {
    server.log("Executing Scheduled Lights-Off.");
    device.send("setColor",{r=0,g=0,b=0});
}

function startSchedWatering() {
    server.log("Starting Scheduled Watering.");
    setPump(1);
}

function endSchedWatering() {
    server.log("Finishing Scheduled Watering.");
    setPump(0);
}

function refreshSched() {
    
    foreach (lighting in SCHED.lights) {
       // schedule wake-and-lights-on
        imp.wakeup(secondsTill(lighting.onat), lightsOnSched);
        // schedule wake-and-lights-off
        imp.wakeup(secondsTill(lighting.onat)+(lighting.onfor.tointeger() * 60), lightsOffSched); 
    }
    
    foreach (watering in SCHED.pump) {
        local waterTime = secondsTill(watering.onat);
        imp.wakeup(waterTime, startSchedWatering);
        imp.wakeup((waterTime + waterDose(watering.amount)), endSchedWatering);
    }
    
    imp.wakeup(secondsTill("00:00"), refreshPumpSched);
}

function setNewSched(sched) {
    if ("lights" in sched) {
        SCHED.lights = sched.lights;
    }
    if ("pump" in sched) {
        SCHED.pump = sched.pump;
    }
    
    
    foreach (lighting in SCHED.lights) {
        SCHED.color = lighting.color;
        // schedule wake-and-lights-on
        server.log("lights-on in "+secondsTill(lighting.onat));
        imp.wakeup(secondsTill(lighting.onat), lightsOnSched);
        // schedule wake-and-lights-off
        server.log("lights-off in "+(secondsTill(lighting.onat)+(lighting.onfor.tointeger() * 60)));
        imp.wakeup(secondsTill(lighting.onat)+(lighting.onfor.tointeger() * 60), lightsOffSched); 
    }
    
    
    foreach (watering in SCHED.pump) {
        local waterTime = secondsTill(watering.onat);
        imp.wakeup(waterTime, startSchedWatering);
        imp.wakeup((waterTime + waterDose(watering.amount)), endSchedWatering);
    }
    
    imp.wakeup(secondsTill("00:00"), refreshSched);
}

// -----------------------------------------------------------------------------
// Firebase class: Implements the Firebase REST API.
// https://www.firebase.com/docs/rest-api.html
//
// Author: Aron
// Created: September, 2013
//
class Firebase {
    
    database = null;
    authkey = null;
    agentid = null;
    url = null;
    headers = null;
    
    // ........................................................................
    constructor(_database, _authkey, _path = null) {
        database = _database;
        authkey = _authkey;
        agentid = http.agenturl().slice(-12);
        headers = {"Content-Type": "application/json"};
        set_path(_path);
    }
    
    
    // ........................................................................
    function set_path(_path) {
        if (!_path) {
            _path = "agents/" + agentid;
        }
        url = "https://" + database + ".firebaseIO.com/" + _path + ".json?auth=" + authkey;
    }


    // ........................................................................
    function write(data, callback = null) {
    
        //if (typeof data == "table") data.heartbeat <- time();
        http.request("PUT", url, headers, http.jsonencode(data)).sendasync(function(res) {
            if (res.statuscode != 200) {
                if (callback) callback(res);
                else server.log("Write: Firebase response: " + res.statuscode + " => " + res.body)
            } else {
                if (callback) callback(null);
            }
        }.bindenv(this));
    
    }
    
    // ........................................................................
    function update(data, callback = null) {
    
        //if (typeof data == "table") data.heartbeat <- time();
        http.request("PATCH", url, headers, http.jsonencode(data)).sendasync(function(res) {
            if (res.statuscode != 200) {
                if (callback) callback(res);
                else server.log("Update: Firebase response: " + res.statuscode + " => " + res.body)
            } else {
                if (callback) callback(null);
            }
        }.bindenv(this));
    
    }
    
    // ........................................................................
    function push(data, callback = null) {
    
        //if (typeof data == "table") data.heartbeat <- time();
        http.post(url, headers, http.jsonencode(data)).sendasync(function(res) {
            if (res.statuscode != 200) {
                if (callback) callback(res, null);
                else server.log("Push: Firebase response: " + res.statuscode + " => " + res.body)
            } else {
                local body = null;
                try {
                    body = http.jsondecode(res.body);
                } catch (err) {
                    if (callback) return callback(err, null);
                }
                if (callback) callback(null, body);
            }
        }.bindenv(this));
    
    }
    
    // ........................................................................
    function read(callback = null) {
        http.get(url, headers).sendasync(function(res) {
            if (res.statuscode != 200) {
                if (callback) callback(res, null);
                else server.log("Read: Firebase response: " + res.statuscode + " => " + res.body)
            } else {
                local body = null;
                try {
                    body = http.jsondecode(res.body);
                } catch (err) {
                    if (callback) return callback(err, null);
                }
                if (callback) callback(null, body);
            }
        }.bindenv(this));
    }
    
    // ........................................................................
    function remove(callback = null) {
        http.httpdelete(url, headers).sendasync(function(res) {
            if (res.statuscode != 200) {
                if (callback) callback(res);
                else server.log("Delete: Firebase response: " + res.statuscode + " => " + res.body)
            } else {
                if (callback) callback(null, res.body);
            }
        }.bindenv(this));
    }
    
}

/* DEVICE CALLBACK HANDLERS --------------------------------------------------*/
device.on("thUpdate", function(thStats) {
    STATS.temperature = thStats.temp;
    STATS.humidity = thStats.humidity;
    //server.log("Agent got TH update:");
    //server.log(format("Temperature: %.2fC",STATS.temp));
    //server.log(format("Humidity: %.2f",STATS.humidity)+"%");
    postUpdate();
});

device.on("colorIsNow", function(colorString) {
    //server.log("color updated to: "+colorString);
    STATS.light = colorString;
    postUpdate();
})

/* GENERAL HTTP REQUEST HANDLER ----------------------------------------------*/
http.onrequest(function(req, res) {
    res.header("Access-Control-Allow-Origin","*");
    //server.log("Got new request: "+req.body);
    local reqBody = {};
    try {
        reqBody = http.jsondecode(req.body);
    } catch (err) {
        server.error("Error parsing request body as JSON: "+err);
        res.send(400, err);
    }
    
    if (req.path == "/overwatered" || req.path == "/overwatered/") {
        //server.log("overwatered alert: "+req.body.tointeger());
        STATS.overflow = req.body.tointeger();
        res.send(200, "OK");
        postUpdate();
        return;
    } else if (req.path == "/schedule" || req.path == "/schedule") {
        server.log("Setting new schedule");
        server.log(req.body);
        local newSched = http.jsondecode(req.body);
        setNewSched(newSched);
        res.send(200,SCHED);
    } else if ("command" in reqBody) {
        if (reqBody.command == "light") {
            if (reqBody.value == "rainbow") {
                device.send("rainbow", 1);
                res.send(200,"OK");
                return;
            } else {
                device.send("setColor",reqBody.value);
                res.send(200, "OK");
                return;
            }
        } else if (reqBody.command == "pump") {
            setPump(((reqBody.value == "1") ? 1 : 0));
            res.send(200, "OK");
            return;
        } else if (reqBody.command == "update") {
            device.send("getTH",0);
            res.send(200, "OK");
            return;
        }
    } else {
        res.send(400, "unknown command");
    }
    
});

/* RUNTIME STARTS HERE -------------------------------------------------------*/
// Fetch temp and humidity any time agent is restarted
device.send("getTH",0);

fbase <- Firebase(DBASE, FIREBASEKEY);
