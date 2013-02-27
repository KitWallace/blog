import module namespace blog = "http://kitwallace.co.uk/ns/blog" at "../lib/blog.xqm";
import module namespace sys = "http://kitwallace.co.uk/ns/sys" at "/db/lib/sys.xqm";
declare option exist:serialize "method=xhtml media-type=text/html";

let $op := request:get-parameter("op",())
return
<html>
<body>
  <ul>
   <li><a href="?op=refresh">Refresh index</a></li>
   <li><a href="?op=view">View Resources</a></li>
   <li><a href="?op=zip">Zip resources</a></li>
   <li><a href="?op=properties">Properties</a></li>
  </ul>
  {if ($op = "refresh")
  then blog:refresh()
  else if ($op="view")
  then sys:view-resources(concat($blog:base,"system/application.xml"))
  else if ($op="zip")
  then sys:zip-resources(concat($blog:base,"system/application.xml"))
  else if ($op="properties")
  then util:serialize(sys:system-properties(),())
  else ()
  }
</body>
</html>
