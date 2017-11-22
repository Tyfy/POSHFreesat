# POSHFreesat

PowerShell to discover Freesat Set Top Boxes on a local network and send commands to it.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

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


## Authors

* **Richard Lewis** - *Initial work* - [Tyfy](https://github.com/Tyfy)

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details

## Acknowledgments

* [Chris4sox](http://chickenshell.blogspot.co.uk/) article on [Controlling Roku with PowerShell](http://chickenshell.blogspot.co.uk/2015/02/roku-controls-with-powershell.html) for pointing me in teh right direction with the SSDP code
