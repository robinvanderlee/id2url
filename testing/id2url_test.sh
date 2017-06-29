cat mart_export.txt | cut -f 1  | head -2 | ./id2url.pl -v 2 -p 2,10 -u "http://www.genome.jp/dbget-bin/www_bget?hsa:%s"
