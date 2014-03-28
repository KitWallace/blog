declare option exist:serialize "method=xhtml media-type=text/html";

let $year := request:get-parameter("year","2014")
let $month := request:get-parameter("month","01")
let $archive := doc(concat("/db/apps/blog/tumblr/","archive-",$year,"-",$month,".xml"))/posts
return
<html>
   <head>
      <title>Tumblr archive {$year} {$month} </title>
   </head>
   <body>
   <h1>Tumblr archive {$year} {$month}</h1>
   {for $post in $archive/post
    return
      <div>
       <h2>{$post/title/string()} on {$post/date/string()}  </h2>
       <h3>Tags - {string-join($post/tags/tag,",")}</h3>
       {$post/body}
      </div>
   }
   </body>
</html>
