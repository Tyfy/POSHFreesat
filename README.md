# POSHFreesat

PowerShell to discover Freesat Set Top Boxes on a local network and send commands to it.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

What things you need to install the software and how to install them

```
This project was developed using PowerShell 5.1 on Windows 10
```

### Information

The Freesat boxes respond to [SSDP](https://en.wikipedia.org/wiki/Simple_Service_Discovery_Protocol) requests but not the full [UPNP](https://en.wikipedia.org/wiki/Universal_Plug_and_Play) discovery process.

The box responds with information on the IP Address and Port that can be used.

* The IP Address will be either static or DHCP depending on how you set them up.
* The Port number appears to change each time the box starts up but this might also change while the box is in use

One of the SSDP responses will give the location of the device.xml file and this is where you can find the serial number of the box and match it against a name if you want.

I believe that the Mobile App makes calls to the Freesat cloud along with the authentication information for your account and that with this it can request a list of known boxes with their aliases that can then be matched against the SSDP responses.

I have not attempted to make any of the connections to the Freesat cloud as I know the serial numbers of the boxes I have so I can hardcode that in my own setup if I need to.

Once I have identified the correct device from the serial number I can then use a simple POST request with a body formatted in a specific way to send individual commands directly to the Freesat box.

I have not found a way to send multiple commands in a single request and suspect this will not work so if I want to change channels I need to send 3 individual commands and may need to introduce a small delay.

### Additional Operations

There are a number of other things that the Freesat App can send to the box that should be straight forward to implement once the device has been discovered.

Examples are

* GET /rc/locale - Get the Serial number, current Postcode and number of tuners for the box
* GET /rc/apps/Netflix - Get Netflix status
* GET /rc/power - Get Power status
* POST /rc/power - change Power status
* Open one of the On Demand Apps
* Open an item from a list of Showcase items. 
This includes opening a program directly in the BBC iPlayer app
Should work with others (Demand 5  etc)

The Freesat App gets the information it displays (Channel listings, Showcase, On Demand apps) from the Internet

The following calls are being made with basic authentication and depending on the location the numbers change to indicate service and region.

* GET http://fdp-regional-v1-0.gcprod1.freetime-platform.net/ms3/regional/sc/json/281/621
* GET http://fdp-regional-v1-0.gcprod1.freetime-platform.net/ms3/regional/od/json/281/62
* GET http://fdp-sv23-ms-ip-epg-v1-0.gcprod1.freetime-platform.net/json/nownextall/281/62
* GET http://fdp-sv09-channel-list-v2-0.gcprod1.freetime-platform.net/ms/channels/json/chlist/281/61


* 281 refers to "FreeSat Scotland G2"
* 62 is “Scotland/BorderSco”

Look for

```
<Service name="FreeSat" type="satellite" />
```

In the Countries.cfg file