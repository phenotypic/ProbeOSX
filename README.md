# ProbeOSX

ProbeOSX allows macOS users to sniff for [probe requests](https://medium.com/@brannondorsey/wi-fi-is-broken-3f6054210fa5) and obtain plain text information like MAC addresses and previously connected networks.

This information could allow an attacker to maliciously clone a network and trick devices into connecting, thereby routing all traffic through the attacker. [This](https://www.youtube.com/watch?v=Z8RHMUSYTiA&frags=pl%2Cwn) video shows how a Linux user may do this using a similar tool.

## Usage

Download with:
```
git clone https://github.com/phenotypic/ProbeOSX.git
```

Run from same directory with:
```
bash ProbeOSX.sh
```

The script is fairly easy to use, simply run it using the command above. Here are some flags you can add:

| Flag | Description |
| --- | --- |
| `-h` | Help: Display all availabe flags |
| `-v` | Verbose: Show **ALL** probe requests, even those from the same MAC address asking for the same network. Not recommended |
| `-na` | No analysis: Mutes the analysis feature at the end of a scan |
| `-i <interface>` | Interface: Manually set Wi-Fi interface (script should normally auto-detect the correct interface) |

### Notes

The script will only run if there is a MAC address lookup table in its directory called `mac-vendor.txt`. A file is included in the repository so it shouldn't be a problem. However, if you would like to use a custom lookup table, make sure it follows this format:

```
<VENDORID>	<VENDORNAME>
00000E	Fujitsu
FCE998	Apple, Inc.
...
```

**When you want to stop**, simply press `control` + `c`.

### Interpreting the output

The table below contains a short description of all of the data outputted by the script:

| Name | Description |
| --- | --- |
| `Time` | The time the probe request was sent (in Hours:Minutes:Seconds). |
| `Signal` | This is the signal strength of the probe request when received by your computer in dBm. The closer the value is to 0, the stronger the signal. |
| `MAC address` | Address unique to every device with Wi-Fi capability, may be used to fingerprint a device (can be spoofed). |
| `Target Network` | This is the name (SSID) of network which the device has requested to connect to. |
| `Vendor` | This is the manufacturer of whichever device has made the request; determined by the first 6 characters of the MAC. |

If you have enabled verbose output (`-v`) or have intercepted multiple probe requests from one MAC address asking for multiple networks and haven't suppressed the analysis with `-na`, then you will recieve an analysis following the scan which will show the multiple networks that each MAC address has requested.
