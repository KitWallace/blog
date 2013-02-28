## a blog


This project is a replacement for my Posterous blog now (Feb '13)
 that Posterous is scheduled to cease operation in April.

Export from Posterous is reformated with an XQuery script to an internal XML format using xquery/convert-posterous.xq.

Basic browsing os provided by the xquery/home.xq script, supporting faceted access by tag, month, sequential access and free text search.

Much remains to be done.

The development is discussed in the blog itself 

http://kitwallace.co.uk/blog/xquery/home.xq

## Pre-requisites
Tested on both 1.4 and 2.0 . The browser code for 2.0 uses the xsl:format-date function which is not available in 1.4 and will need replacing with the corresonding datetime function (but note that the picture format is different)

