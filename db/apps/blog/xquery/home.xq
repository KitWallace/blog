import module namespace blog = "http://kitwallace.co.uk/ns/blog" at "../lib/blog.xqm";

declare option exist:serialize "method=xhtml media-type=text/html";

let $query :=
  element query {
     element type {request:get-parameter("type","item")},
     let $value := request:get-parameter("value",())
     return 
        if (exists($value))
        then element value {$value}
        else ()
  }
  
let $content := blog:content($query)
return
<html>
<head>
   <title>The Wallace Line</title>
   <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
   <script src="../jscript/sorttable.js"></script>
   <link rel="stylesheet" href="../css/blueprint/screen.css" type="text/css" media="screen, projection"/>
   <link rel="stylesheet" href="../css/blueprint/print.css" type="text/css" media="print"/>
   <!--[if IE ]><link rel="stylesheet" href="../css/blueprint/ie.css" type="text/css" media="screen, projection" /><![endif]-->
   <link rel="stylesheet" href="../css/screen.css" type="text/css" media="screen, projection"/>
   <link rel="stylesheet" href="../css/print.css" type="text/css" media="print"/>
  </head>
  <body> 
              <div class="container">
                    <div class="span-24 last">
                        <div class="span-16">
                            <div class="banner">
                                  <h1> The Wallace Line</h1>
                            </div>
                        </div>
                        <div class="span-8 last noprint ">
                            {$content/div[@id='search-form']}
                        </div> 
                    </div> 
                    <div class="span-24 last noprint">
                        <hr/>
                    </div>
                    <div class="span-24 last">
                      <div class="span-3 noprint">
                        <div class="inner">
                            {$content/div[@id='side']}
                        </div>
                      </div>
                      <div class="span-21 last">
                        <div class="inner">
                            {$content/div[@id='body']}
                        </div>
                      </div>
                    </div>
                    <div class="span-24 last noprint">
                        <hr/>
                        <div class="inner">
                            <div class="footer bordered">
                                <div id="footerlinks">
                                    <a href="http://kitwallace.co.uk/">Kit Wallace</a> | 
                                    <a href="http://exist-db.org">eXist-db</a> | 
                                  </div>
                            </div>
                        </div>
                    </div>
                </div>
  </body>
</html>