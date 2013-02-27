module namespace convert = "http:/kitwallace.co.uk/ns/convertblog";

import module namespace date= "http://kitwallace.co.uk/ns/blogdate" at "../lib/date.xqm";

declare namespace b = "http:/kitwallace.co.uk/ns/data/blog";
declare variable $convert:reject := ("blogger-post-footer");


declare function convert:copy-transform($node) {
  element {name($node)} {
            $node/@*,
            convert:transform($node/node())
   }
};

declare function convert:transform($nodes) {
  for $node in $nodes 
  return
     typeswitch ($node)
     case text() return $node
     case element(img) return
         element img {
              attribute src {
                   if (starts-with($node/@src,"../"))
                   then concat("../images/",tokenize($node/@src,"/")[last()])
                   else $node/@src/string()
                   },
              $node/(@* except @src)
          }
     case element(div) return
         if ($node/@class = $convert:reject)
         then ()
         else convert:copy-transform($node)
     case element(a) return
         if (starts-with($node/@href,"https://gist.github.com"))
         then 
             let $id :=  substring-after($node/@href,"https://gist.github.com/")
             return 
                 <script src="http://gist.github.com/{$id}.js"></script>
         else 
             element a {
               attribute class {"external"},
               $node/@*,
               $node/node()
             }
     case element(code) return
        element pre {convert:transform($node/node()) }
               
 (:
    case element(p) return
            if (string-length($node)) 
            then ()
            else element p {convert:transform($node/node())}
 :)
  
     default return
         convert:copy-transform($node)
};

declare function convert:comment($li) {
  let $date := date:blogdate-to-dateTime($li//div[@class='response_time']) 
  let $date := xs:dateTime($date) - xs:dayTimeDuration("PT8H")
  let $name := substring-before($li//div[@class='response_name']," responded")
  let $body := $li/div[@class='response_body']/node()
  return
     element b:comment {
        attribute date {$date},
        attribute name {$name},
        $body
     }
};

declare function convert:html-to-item($filename) {
let $xml := util:binary-to-string(file:read-binary($filename))
let $xml := substring-after($xml,"<!DOCTYPE html>")
let $xml := util:parse-html($xml)
let $date := date:blogdate-to-dateTime($xml//span[@class='post_time'])
(: times need to be adjusted by -8 hours because the time zone has been lost :)
let $date := xs:dateTime($date) - xs:dayTimeDuration("PT8H")
let $posterousname := substring-before(tokenize($filename,"/")[last()],"html")
let $title :=string($xml//div[@class="post_header"]/h3)
let $body := convert:transform($xml//div[@class="post_body"]/node())
let $comments := for $comment in $xml//ul[@class='post_responses list']/li return convert:comment($comment)
let $tags := tokenize($xml//div[@class="post_tags_list"],",\s*")
let $views := number(substring-before($xml//div[@class="post_responses"]," "))
let $status := if ($views < 40) then "draft" else "published"   (: hack this because html does not contain status data :)
return 
  element b:item {
      attribute date {$date},
      attribute posterous {$posterousname},
      attribute month {substring($date,1,7)},
      attribute title {$title},
      attribute status {$status},
      attribute views {$views},
      element b:tags {for $tag in $tags return element b:tag {$tag} },
      element b:body {$body},
      element b:comments {$comments}
   }
};


declare function convert:posterous( $source,$target) {
<div>
<ul>
{
for $file in (file:directory-list($source,'*.html')//file:file/@name/string())
let $filename := concat($source,$file)
let $item := convert:html-to-item($filename)
let $save := xmldb:store($target,concat("A-",replace($item/@date,":","-"),".xml"),$item)
return 
   <li>{$item/@date/string()} - {$item/@title/string()} - {$save}</li>
}
</ul>
</div>
};

