import module namespace convert = "http:/kitwallace.co.uk/ns/convertblog" at "../lib/convert.xqm";

declare option exist:serialize "method=xhtml media-type=text/html";

let $login := xmldb:login("/db","admin","password")
let $source := 'file:///home/chris/blog/pages/'
let $target := '/db/apps/blog/items/'
return convert:posterous($source,$target)

