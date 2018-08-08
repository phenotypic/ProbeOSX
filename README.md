# ProbeOSX
#### A simple tool for macOS to capture and interpret probe requests.


## What is it?

ProbeOSX is a simple tool written in Bash which allows for Mac users to sniff for [probe requests](https://medium.com/@brannondorsey/wi-fi-is-broken-3f6054210fa5) in their local area. This allows the user to get plain text information such as MAC addresses along with those devices previously connected and/or hidden networks. [This](https://www.youtube.com/watch?v=Z8RHMUSYTiA&frags=pl%2Cwn) is an excellent video showing how a Linux user may do the same sort of thing using a similar tool to ProbeOSX. As mentioned in the video, the information that is broadcasted in a probe request can allow for an attacker to create an identical, malicious network which could trick your device into connecting to it; therefore allowing all data traffic to your device to unknowingly be routed through the attackers network. Read the [Motivations](#motivations) section for more information.


## Installation

Before using the script, make sure to read the [Terms of Use](#terms-of-use) section. 

The script is self contained so you can either simply download the script via the "Download ZIP" button above, decompress the file, open Terminal, type `bash `, drag in the script and press enter. (`bash <path/to/the/script.sh>`). Or, you can use the command line (recommended):
```
git clone https://github.com/Tommrodrigues/ProbeOSX
cd $HOME/ProbeOSX && bash ProbeOSX.sh
```

## Removal

As mentioned above, ProbeOSX is self contained and therefore can simply be removed from the computer by dragging the script into the Trash if you don't want it any more as no files or folders are created by the script.

If you downloaded via `git clone`, you can simple run the following command to remove ProbeOSX:
```
sudo rm -r $HOME/ProbeOSX
```


## Usage

Be sure to read both the [Terms of Use](#terms-of-use) and the [Important usage notes](#important-usage-notes) sections before using the script.

The script was designed with ease of use in mind so most people shouldn't find it too hard to work themselves through the various options. However, if you would like more guidance or information, read below:

1. After starting the script with either `bash <path/to/the/script.sh>` or cd `$HOME/ProbeOSX && bash ProbeOSX.sh` if you cloned it, you will be prompted with a message asking you to verify whether the auto-detected Wi-Fi interface is indeed correct. You can check this by holding down the `option` key and then clicking on the Wi-Fi icon on the top of your screen which should read on the top line"`Interface Name: <interface>`". If the listed interface does not match that of the auto-detected one then choose `n` and proceed to enter the correct interface when prompted, otherwise, select `y`.

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


## Installing other dependencies

As stated above, the script itself is self contained; as such unless you wish to use a custom vendor lookup table other than the one included, there is no need to install any other dependencies.


## Compatibility, requirements and optimisation

The script was originally written on and for macOS 10.13 but I don't see any real reason why this wouldn't work on previous and future versions of macOS (within reason). The script is not computationally demanding so shouldn't require more than the baseline hardware for most of the Macs made in the last 7-ish years (as long as they have a Wi-Fi card capable of monitor mode)

As for compatibility with other operating systems, I believe that the methods used in this script for intercepting the probe requests are unavailable on Linux so I would recommend using a tool like [ProbeQuest](https://github.com/SkypLabs/probequest) which will work for linux. (This script may indeed work on Linux but it has not been tested so I cannot promise anything.)


## Important usage notes

1. The path you enter MUST be a full path e.g. `/Users/tom/Desktop/table.txt` (i.e. you cannot use `$HOME/Desktop/table.txt` or `~/Desktop/table.txt`)

2. ProbeOSX does not handle spaces in the file path well e.g. `/Users/tom/Desktop/mac vendor tables/table.txt` would not work so try to avoid spaces.

3. You may not be able to use your internet connectivity while the script is in use due to the fact that the Wi-Fi interface is put into monitor mode. However, there *have* been instances where I have been able to access the internet while the script was in use.

4. As mentioned in the [Usage](#usage) section, the script can ignore the same combination of MAC address and target network. The script also automatically eliminates any "bad" probe requests, i.e. any that contain `bad-fcs` or and which have an empty target network.


## Limiting factors

IOS: Since IOS 8, a [new feature](https://www.theverge.com/2014/6/9/5792970/ios-8-strikes-an-unexpected-blow-against-location-tracking) has been in place to mitigate the privacy issues related to Wi-Fi scanning.

Android: To prevent your Android devices from leaking their PNL, you can install [Wi-Fi Privacy Police](https://github.com/BramBonne/privacypolice) from the Play Store.

This sort of "attack" can also be mitigated by emitting a huge volume of random probe requests through a tool such as the [ESP8266 Deauther](https://github.com/spacehuhn/esp8266_deauther) which will overwhelm the script.


## Motivations

#### When would I use it?

This tool can be useful for you if you are looking to audit the security and privacy of your personal device. After running the tool, you can see if any personal data such as the SSID of your favourite coffee shop is being broadcasted for the world to see. 

#### Why did you make it?

After seeing numerous videos including [this](https://www.youtube.com/watch?v=Z8RHMUSYTiA&frags=pl%2Cwn) one, I became intrigued by the idea that our devices are unknowingly emitting rather personal data about us in plain text without our knowledge. I thought it was important to find out exactly what sort of information my devices were emitting and therefore what sort of information a person with malicious intent may be able to use against me.

After looking all around GitHub, it was only rarely that I cam across such a tool designed for macOS. Whilst there are other tools such as [ProbeQuest](https://github.com/SkypLabs/probequest) out there which aim to do just that; these tools are designed for Linux operating systems and inherent differences in the ways that Wi-Fi cards in Macs are addressed means that trying to use such tools will not work. As such, I thought it would be an interesting project of mine to create a tool to do just that for the Mac users out there.

## FAQ


> I just ran the script for the first time and I'm not picking anything up! What gives?

First, please have a look in the terminal window and see if there are any errors not mentioned in the readme; if so, please post them in the [Issues](https://github.com/Tommrodrigues/ProbeOSX/issues) section. Next, while the script is scanning, have a look at the menu bar on the top of your screen, you should see an "eye" inside the Wi-Fi icon indicating that you have successfully entered monitor mode. If you have verified this then the chances are that there are just no probe requests going around, this is a good thing! This is common if you live in an isolated area without many Wi-Fi enabled devices. Even if you do own such devices, as mentioned in the [Limiting factors](#limiting-factors) section, many modern devices have been updated to ensure that no unnecessary probe requests are sent out in an effort to increase your privacy. However, you can test whether this is the case by going into the Wi-Fi settings of an IOS device, pressing "Other" and entering random details then pressing Connect; this should force your device to make a probe request.


> I'm receiving an error like `tcpdump: en0: You don't have permission to capture on that device...` what do I do?

Usually, this is a fairly easy fix. Follow the steps linked [here](https://stackoverflow.com/questions/41126943/wireshark-you-dont-have-permission-to-capture-on-that-device-mac) to resolve the problem.


> How does ProbeOSX work? Is it safe?

Feel free to look over the code for ProbeOSX included in the repository and have a look at it for yourself. It is by no means the most elegant code but it gets the job done ;) You can also get a brief overview of how it works by reading the rest of this readme page. As for whether or not ProbeOSX is safe, this first depends on what you mean by "safe". If you are concerned about this damaging your computer (e.g. frying the graphics card, breaking the wireless card etc.), I have personally never experienced any problems with my computer after using ProbeOSX as it is not very demanding but this may differ from device to device especially if you have a less powerful Mac. Be sure to refer to the [Terms of Use](#terms-of-use)!


> Why did you make this?

Please refer to the [Motivations](#motivations) section for more information.


> I've got a question, problem, suggestion to do with ProbeOSX, what should I do?

If you've got a question, issue or suggestion to do with the ProbeOSX code, be sure to post a well documented report in the [Issues](https://github.com/Tommrodrigues/ProbeOSX/issues) section of the repository. If you have any question/issue not relating to the script's code specifically (i.e. hardware problems or any other problem not to do with the running of the ProbeOSX script) then please refer to the [Terms of Use](#terms-of-use) which you agreed to by using the script.


## Terms of Use

Rather than attempting to create fully fledged, EULA style, Terms of Use which would undoubtedly be plagued with loop holes, flaws and discourage people from reading it; I thought the better option would be to lay down some of the obvious "don'ts" below.


> Woah, cool! I can't wait to go to my local coffee shop/airport/other public place and soak up loads of people's previously connected Wi-Fi networks in an effort to exploit this information.

Just a second there, this tool was **NOT** made for you do this! Read the [Motivations](#motivations) section for what this tool *is* made for. Furthermore, we would like to state that we especially prohibit using the tool with the intention of targeting a specific person or a group of people either for the sake of it or to use it as a platform to do something more malicious such as running an Evil Twin attack. We take no responsibility whatsoever for any wrongdoing on your part what so ever as the responsibility of using this script is completely yours.


> Hey man, you never told me doing this was illegal in my country/region; now the police are on my case! Not cool!

Whilst the intention of ProbeOSX is in no way meant to be malicious, there may be rules/laws where they apply to you which forbid the download and/or use of such programs. Be sure to check your local regulations before using your script. You have been warned!


> I think your script damaged my computer, I want you to pay me for the damage.

As mentioned earlier in the readme, I have personally never experienced any problems during/after using the script. However, it should be restated that some of the functions in the script can use up a lot of computing power while the script is running and this may in turn, have differing effects on different hardware. For that reason, we will state now that we take **no** responsibility for any harm which may or may not have come to your computer as a result of using our script, including but not limited to hardware damage or data loss.


> Some other problem/issue not mentioned anywhere in the repository has affected me. Because it's not mentioned there, you are therefore responsible for my actions/problems.

Whilst we are more than happy to try and help you out with any quires to do with the script itself. As was stated in the [FAQ](#faq), if you have any other problem which you feel we are responsible for and you are unclear about due to the fact that it was either not properly or completely not mentioned in the repository, we will try our best to help you out if it is relevant in the [Issues](https://github.com/Tommrodrigues/ProbeOSX/issues) section. However, at the end of the day, to reinstate the point above; we take no responsibility for any problems which may have developed either in a legal, hardware or other any other matter as a result of using our script, including but not limited to hardware damage, data loss or prosecution.


## Contact

###### Please submit any outstanding questions to the [Issues](https://github.com/Tommrodrigues/ProbeOSX/issues) section as per the [FAQ](#faq) on "I've got a question, problem, suggestion to do with ProbeOSX, what should I do?". If you require one-to-one contact please request such in the [Issues](https://github.com/Tommrodrigues/ProbeOSX/issues) section where your case will be dealt with accordingly.

