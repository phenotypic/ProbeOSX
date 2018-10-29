# ProbeOSX (WIP)
#### A simple tool for macOS to capture and interpret probe requests.


## What is it?

ProbeOSX is a simple tool written in Bash which allows for Mac users to sniff for [probe requests](https://medium.com/@brannondorsey/wi-fi-is-broken-3f6054210fa5). This allows the user to get plain text information such as MAC addresses along with those devices previously connected and/or hidden networks. [Here](https://www.youtube.com/watch?v=Z8RHMUSYTiA&frags=pl%2Cwn) is a video showing how a Linux user may do the same sort of thing using a similar tool to ProbeOSX. As mentioned in the video, the information that is broadcasted in a probe request can allow for an attacker to create an identical, malicious network which could trick your device into connecting to it; therefore allowing all data traffic to your device to unknowingly be routed through the attackers network. 

## Usage

Download and run the script with:
```
git clone https://github.com/Tommrodrigues/ProbeOSX
bash ~/ProbeOSX/ProbeOSX.sh
```

The script is fairly easy to use, simply run it using the command above to recieve the standart output. Here are some flags you can add if you would like more or less output:

| Flag | Description |
| --- | --- |
| `-v` | Verbose: Show **ALL** prove requests, even those from the same MAC address asking for the same network. Not recommended |
| `-na` | No analysis: Mutes the analysis feature at the end of a scan |
| `-i <interface>` | Interface: Manually set Wi-Fi interface (script should normally auto-detect the correct interface) |

Here is an example output (**obsolete**):

![Example](https://image.ibb.co/i7sxo9/Screen.png)

### Notes

The script will only run if there is a MAC address lookup table in its directory called `mac-vendor.txt`. A file is included in the repository so it shouldn't be a problem. However, if you would like to use a custom lookup table, make sure it follows this format:
```
<VENDORID>	<VENDORNAME>
00000E	Fujitsu
FCE998	Apple, Inc.
...
```

**When you want to stop** your scan, simply press `control` + `c`.

### Interpreting the output

As mentioned above, there are two different options when it comes to outputting probe requests using this script with one being more detailed than the other. The table below contains a short description of all of the data outputted by the more detailed option and therefore people using the simple output should only concern themselves with the rows about MAC Addresses and Target Networks:

| Name | Description |
| --- | --- |
| Time | Rather self explanatory, this is the time at which the probe request was originally sent (in Hours:Minutes:Seconds). |
| Signal | This is the signal strength of the probe request when received by your computer in dBm. The closer the value is to 0, the stronger the signal. Look below for more information |
| MAC address | This is the combination of 6 groups of 2 numbers and letters which is unique to every device with Wi-Fi capability. Can be used to fingerprint each device. |
| Target Network | This is the name  (SSID) of network which the device has requested to connect to in plain text. |
| Vendor | This is the manufacturer of whichever device has made the request. This is determined by the first 6 characters of the MAC. |

## Removal

If you downloaded via `git clone`, you can simple run the following command to remove ProbeOSX:
```
sudo rm -r ~/ProbeOSX
```

