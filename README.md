# id2url

`id2url` opens a set of websites for a list of identifiers or other search
terms. The preset websites are primarily useful for (computational) biologists. Command line
options allow:
* flexible specification of search terms
* multiple websites for each term, allowing combinations of both preset and user-supplied URLs

See below for usage instructions.


# Install id2url

Download the source code and run `id2url`:
* `wget https://github.com/robinvanderlee/id2url/archive/<version>.zip`
* `unzip id2url-<version>.zip`
* `cd id2url-<version>`
* `./id2url.pl`


# Run id2url

Instructions from `id2url.pl --help`:
```
  v1.1
Open a set of web pages for a list of identifiers or other search terms, which can be supplied as a file, or entered by pasting under the -l flag.

    Examples:
      $ ./id2url.pl uniprot_identifiers.txt
      $ cut -f 2 biomart_with_entrez_idenfiers.txt | sort | perl id2url.pl -p 2
      $ ./id2url.pl -b 5 -o 2 -v 1 -l
      $ perl id2url.pl -u \"http:\/\/www.ncbi.nlm.nih.gov\/pubmed?cmd=search&term=%s%20immunity\"
          pubmed_identifiers_search_with_immunity.txt
      $ ./id2url.pl -l -p 2,7,10 -u \"http://www.genome.jp/dbget-bin/www_bget?hsa:%s\"
    
    By default, identifiers should be on different lines (separated by a newline, \n).

    General options. Default values in square brackets []:
               -h        Display this usage help information

               -l        Asks for a list of identifiers on the command line rather 
                           than reading in from a file; execute script with ^D (ctrl+D)
                           after pasting the identifiers
               -i <id>   Open the (single) identifier that is supplied as argument
               
               -v <x>    Verbosity [0]:
                           0 print only dots
                           1 print identifiers
                           2 print full URLs

               -e <expr> Split expression for identifiers [newline ("\n")]
               -b <x>    Batchsize, open <x> URLs at a time [all]
               -o <x>    Go to the URL of every other <x> identifiers [1]
               -s <x>    Sleep time (<x> seconds) before opening next URL, can 
                           be a floating point number [0]
               -r        Open identifier URLs in reversed order
               -unq      Only open unique identfiers from the entered list

    URL options. Multiple URLs, separated by ",", can be supplied using both the -u and -p flags:
               -u <url>  Custom URL, %s will be replaced by the identifier - 
                           e.g. "http://www.uniprot.org/uniprot/%s"
               -p <x>    Preset URLs, <x>:
                           1 UniProt [default]
                           2 Entrez human (9606)
                           3 Ensembl
                           4 RefSeq
                           5 PudMed
                           6 UCSC Genome Browser
                           7 Google (careful, might cause temporary ban!)
                           8 UniProt human search
                           9 Entrez human (9606) search
                           10 GeneCards
                           11 Pfam
                           12 OMIM
                           13 QuickGO
                           14 PDB
                           15 Saccharomyces Genome Database
                           16 dbSNP
                           17 Ensembl variation
                           18 Wikipedia
                           19 InnateDB

    Other options.
               -f        Open a set of URLs in the browser as is (i.e. without any
                           identifier inserted or any other modification)
```


# Browser compatibility and OS-specific instructions

`id2url` has been tested on OSX, Windows and Linux. The application was
developed for graphical browsers. Command line browers are therefore
not supported.

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

