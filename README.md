vlc-plugin-radiospi
===================

[VLC] plugin written in [Lua], to load Radio Service Information (SI) files, as specified in [ETSI TS 102 818].
This allows you to play the radio stations listed by broadcasters.


Installation
------------

Put the `radio-spi.lua` file in :  

- **Windows (all users)**
`%ProgramFiles%\VideoLAN\VLC\lua\playlist\`

- **Windows (current user)**
`%APPDATA%\VLC\lua\playlist\`

- **Linux (all users)**
`/usr/lib/vlc/lua/playlist/`

- **Linux (current user)**
`~/.local/share/vlc/lua/playlist/`

- **Mac OS X (all users)**
`/Applications/VLC.app/Contents/MacOS/share/lua/playlist/`

- **Mac OS X (current user)**
`/Users/$USER/Library/Application\ Support/org.videolan.vlc/lua/playlist/`

Note: create the directories if they do not exist.


Example SI files
----------------

Many broadcasters publish Service Information files (SI), describing the services that they broadcast.
Within these files is metadata about the services and stream URLs.

- Bauer: <http://listenapi.planetradio.co.uk/radiodns/spi/3.1/SI.xml>
- Global: <http://epg.musicradio.com/radiodns/spi/3.1/SI.xml>
- Wireless: <http://wireless.radiodns.metadata.radio/radiodns/spi/3.1/SI.xml>


License
-------

`vlc-plugin-radiospi` is licensed under the terms of the MIT license.
See the file [LICENSE](/LICENSE.md) for details.


Contact
-------

* Author:    Nicholas J Humfrey
* Twitter:   [@njh](http://twitter.com/njh)



[VLC]:  http://www.videolan.org/vlc/
[Lua]:  https://www.lua.org/docs.html
[ETSI TS 102 818]:  https://www.etsi.org/deliver/etsi_ts/102800_102899/102818/03.04.01_60/ts_102818v030401p.pdf
