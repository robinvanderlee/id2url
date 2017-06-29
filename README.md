# id2url

`id2url` opens a set of websites for a list of identifiers or other search
terms. The preset websites are useful for (computational) biologists. Command line
options allow:
* flexible specification of search terms
* multiple websites for each term, allowing combinations of both preset and custom URLs

# Install and run id2url:

Download the source code and run `id2url`:
* `wget https://github.com/cmbi/id2url/archive/<version>.zip`
* `unzip id2url-<version>.zip`
* `cd id2url-<version>`
* `./id2url.pl`

# Browser compatibility and OS-specific instructions

`id2url` has been tested on OSX, Windows and Linux. The application was
developed for graphical browsers. Command line browers are therefore
not supported. If you encounter any problems, please report an issue.

## Additional information for Linux

The application uses the command `x-www-browser`, which opens the default web
browser.
To list the available web browsers for the command `x-www-browser`:
```
sudo update-alternatives --list x-www-browser
```
If you have a browser installed that should be compatible with x-www-browser,
but is not visible in the list (e.g. firefox), install it using
```
sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox 90
```
To change the default web browser, type
```
sudo update-alternatives --config x-www-browser
```
and select your preferred browser.

