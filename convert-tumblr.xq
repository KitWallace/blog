(:
   Copy a Tumblr archive for a given year and month
:)

declare variable $local:base := "/db/apps/blog/";
declare variable $local:imagedir := "tumblrimages/";


declare variable $local:months :=
	("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct","Nov", "Dec");

declare function local:zero-pad($i as xs:string) as xs:string {
	if(xs:integer($i) lt 10) then
		concat("0", $i)
	else
		xs:string($i)
};

declare function local:date-to-xs($s) {
 let $s := replace($s,",","")
 let $sp := tokenize($s," ")
 let $day := local:zero-pad($sp[2])
 let $month := local:zero-pad(string(index-of($local:months,$sp[1])))
 return concat($sp[3],"-",$month,"-",$day)
};

declare function local:copy-image($url,$dir,$fn) {
  let $doc := httpclient:get(xs:anyURI($url),false(),())
  let $bin := $doc/httpclient:body/text()
  return xmldb:store($dir,$fn,xs:base64Binary($bin))
};

declare function local:transform($nodes,$postid) {
  for $node in $nodes
  return
     if ($node instance of element(img) and not(contains($node/@src,"asset"))) 
     then 
         let $url := $node/@src
         let $fn := substring-after($url,"/tumblr_inline_")
         let $newfn :=concat($postid,"-",$fn)
         let $copy := local:copy-image($url,concat($local:base,$local:imagedir),$newfn )
         return
            element img {
                  attribute src {concat("../",$local:imagedir,$newfn)}
                  }
     else if ($node instance of element(div) and $node/@class = "post-title")
     then ()
     else if (exists($node/*))
          then element {name($node)} { 
                  $node/@*, 
                  local:transform($node/node(),$postid)} 
     else $node
};

let $login := xmldb:login("/db/apps/blog","admin","password")
let $year := request:get-parameter("year","2014")
let $month := request:get-parameter("month","01")
let $url := concat("http://kitwallace.tumblr.com/archive/",$year,"/",$month)
let $xml := httpclient:get(xs:anyURI($url),false(),())/httpclient:body

let $posts := 
  element posts
    {for $post in $xml//section/div
     let $date := local:date-to-xs($post//span[@class="post_date"])
     let $body := local:transform($post//div[@class="post_content_inner"],concat("A-",$date))
     return 
      element post {
         element title {$post//div[@class="post_title"]/string()},
         element date {$date},
         element tags {
             for $tag in tokenize(normalize-space($post//span[@class="tags"])," ")
             return element tag {substring($tag,2)}
         },  
         element body {$body}
      }
    }

return xmldb:store("/db/apps/blog/tumblr",concat("archive-",$year,"-",$month,".xml"),$posts)
