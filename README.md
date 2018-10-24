# ProbeOSX
#### A simple tool for macOS to capture and interpret probe requests.


## What is it?

ProbeOSX is a simple tool written in Bash which allows for Mac users to sniff for [probe requests](https://medium.com/@brannondorsey/wi-fi-is-broken-3f6054210fa5). This allows the user to get plain text information such as MAC addresses along with those devices previously connected and/or hidden networks. [Here](https://www.youtube.com/watch?v=Z8RHMUSYTiA&frags=pl%2Cwn) is a video showing how a Linux user may do the same sort of thing using a similar tool to ProbeOSX. As mentioned in the video, the information that is broadcasted in a probe request can allow for an attacker to create an identical, malicious network which could trick your device into connecting to it; therefore allowing all data traffic to your device to unknowingly be routed through the attackers network. Read the [Motivations](#motivations) section for more information.


## Usage

Download and run the script with:
```
git clone https://github.com/Tommrodrigues/ProbeOSX
bash ~/ProbeOSX/ProbeOSX.sh
```

The script was designed with ease of use in mind so most people shouldn't find it too hard to work themselves through the various options. However, if you would like more guidance or information, read below:

1. After starting the script with `bash ~/ProbeOSX/ProbeOSX.sh`, you will first be prompted with a message asking you to verify whether the auto-detected Wi-Fi interface is indeed correct. You can check this by holding down the `option` key and then clicking on the Wi-Fi icon on the top of your screen which should read on the top line"`Interface Name: <interface>`". If the listed interface does not match that of the auto-detected one then choose `n` and proceed to enter the correct interface when prompted, otherwise, select `y`.

2. Now, you will be asked whether you want to use the detailed output (y) or the simple output (n). It is recommended that you use the detailed output, but the simple output can be useful in some circumstances.
The output formats are as below:

| Type | Contents |
| --- | --- |
| Detailed output | `<Time> <Signal strength> <MAC Address> <Target network> <Vendor>` |
| Simple output | `<MAC Address> <Target network>` |

3. Next, if you selected detailed output, the script should auto-detect the MAC vendor list included in the repository and ask you if this is the one you want to use. If either the script does not detect the included MAC vendor list or you would like to use a custom list, follow the on screen instructions.  If you would like to use a custom lookup table, make sure it follows this format:
```
<VENDORID>	<VENDORNAME>
00000E	Fujitsu
FCE998	Apple, Inc.
...
```

4. Now, you will be asked if you would like to ignore repeated requests I.e. if a device requests the same network repeatedly, you will only be shown it once. This is highly recommended both due to the fact that it is far easier to interpret the data when this option is turned on but also due to the fact that there are very limited cases where you may need to see every single request.

5. Finally, you will be prompted with a screen asking you to verify the Wi-Fi interface, whether you want to use  the detailed output and if you do; where it is located along with verifying whether you want to ignore identical requests and ensuring that you have read the [Terms of Use](#terms-of-use).

6. After agreeing, you will be supplied with a start time along with a short summary of what the script is doing and the script will start to sort the probe requests. You will also receive a message like this:
```
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on en0, link-type IEEE802_11_RADIO (802.11 plus radiotap header), capture size 256 bytes
```

You can simply ignore this message. Now, the intercepted probe requests should come flooding in as shown in the example below:

![Example](https://image.ibb.co/i7sxo9/Screen.png)

It is important to note that the script automatically eliminates any "bad" probe requests, I.e. any that contain `bad-fcs` or and which have an empty target network in an effort to make it easier for the user to interpret.

When you want to stop your scan, simple press `control` + `c`.

### Interpreting the output

As mentioned above, there are two different options when it comes to outputting probe requests using this script with one being more detailed than the other. The table below contains a short description of all of the data outputted by the more detailed option and therefore people using the simple output should only concern themselves with the rows about MAC Addresses and Target Networks:

| Name | Description |
| --- | --- |
| Time | Rather self explanatory, this is the time at which the probe request was originally sent (in Hours:Minutes:Seconds). |
| Signal | This is the signal strength of the probe request when received by your computer in dBm. The closer the value is to 0, the stronger the signal. Look below for more information |
| MAC address | This is the combination of 6 groups of 2 numbers and letters which is unique to every device with Wi-Fi capability. Can be used to fingerprint each device. |
| Target Network | This is the name  (SSID) of network which the device has requested to connect to in plain text. |
| Vendor | This is the manufacturer of whichever device has made the request. This is determined by the first 6 characters of the MAC. |

Below is a (very) rough guide for interpreting the signal strength:

| Strength | Interpretation |
| --- | --- |
| x ≥ -30dBm | Very strong signal (Very close) |
| -30dBm> x ≥-60dBm | Good signal (Rather close) |
| -60dBm> x ≥-70dBm | Decent signal (Fairly close) |
| x <-70dBm | Weak signal (Far away) |

## Removal

If you downloaded via `git clone`, you can simple run the following command to remove ProbeOSX:
```
sudo rm -r $HOME/ProbeOSX
```

