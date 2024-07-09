# #UKGE2024 Results Explorer for the BBC Micro

Are you tired of looking at fancy hypertext pages with graphs and pie charts for your election results? Worry no longer, because now you can browse them the old-fashioned way, on your BBC Micro!

Just load the .ssd into your hardware or emulator of choice and hit <kbd>SHIFT</kbd>+<kbd>BREAK</kbd> to boot the disk. The program will start automatically, displaying the instructions page.

![image](https://github.com/danj2k/ge24rex/assets/29895048/8c78367a-4faa-48ea-b2f6-624332919fe5)

Hit <kbd>f1</kbd> to switch between the main menu and the instructions screen.

![image](https://github.com/danj2k/ge24rex/assets/29895048/fd60a26a-9cd0-4dc8-9195-14377641f13f)

<kbd>f3</kbd> will allow you to perform searching, and when you're done searching or you want to try a different kind of search you can hit <kbd>SHIFT</kbd>+<kbd>f3</kbd> to clear the current search.

![image](https://github.com/danj2k/ge24rex/assets/29895048/d0e0e622-1da5-4df8-9655-a54080d8f1dc)

Selecting a constituency and pressing <kbd>RETURN</kbd> will show you the full name of that constituency (if it was truncated in the menu) and the result, including which party won and which party lost (if applicable) in that constituency.

Candidate-level results aren't due to be released until Friday 12th July but some time after that point I do plan to add the top 4 parties in each constituency to the constituency info screen.

## Building from source

To build the binary data file you'll need the source "winners" spreadsheet from [here](https://commonslibrary.parliament.uk/research-briefings/cbp-10009/) which is licensed under the [Open Parliament Licence v3.0](https://www.parliament.uk/site-information/copyright-parliament/open-parliament-licence/).
