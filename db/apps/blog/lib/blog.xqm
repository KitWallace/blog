module namespace blog = "http://kitwallace.co.uk/ns/blog";
import module namespace date= "http://kitwallace.co.uk/ns/blogdate" at "../lib/date.xqm";

declare namespace b = "http:/kitwallace.co.uk/ns/data/blog";

declare variable $blog:base := "/db/apps/blog/";
declare variable $blog:items := concat($blog:base,"items/");
declare variable $blog:index := concat($blog:items,"index.xml");

declare function blog:format-date($date) {
    xsl:format-dateTime(xs:dateTime($date),"DD MMM ''YY hh:mm")
};

declare function blog:items() {
   collection($blog:items)/b:item
};

declare function blog:tags($items) {
   distinct-values($items//b:tag)
};

declare function blog:months($items, $year) {
   distinct-values($items/@month[substring(.,1,4) = $year])
};

declare function blog:years($items) {
   distinct-values($items/substring(@month,1,4))
};

declare function blog:items-at-month($month) {
  collection($blog:items)/b:item[@month=$month]
};

declare function blog:item-at-date($date) {
   collection($blog:items)/b:item[@date=$date]
};

declare function blog:items-at-tag($tag) {
   collection($blog:items)/b:item[b:tags/b:tag=$tag]
};

declare function blog:items-at-q($q) {
   collection($blog:items)/b:item[ft:query(b:body, $q)]
};

declare function blog:next-item($item) {
   let $entry := doc($blog:index)//b:item[@date = $item/@date]
   return ($entry/following-sibling::*)[1]/@date
};

declare function blog:prev-item($item) {
   let $entry := doc($blog:index)//b:item[@date = $item/@date]
   return $entry/preceding-sibling::*[1]/@date
};

declare function blog:item-index() {
 element b:index {
     for $item in blog:items() 
     order by $item/@date
     return 
       element b:item {
           $item/@*
       }
  }
};

declare function blog:refresh() {
  let $index := blog:item-index()
  let $store := xmldb:store(concat($blog:base,"items"),"index.xml",$index)
  return true()
};

declare function blog:items-as-html($items as element(b:item) *)  as element(div){
 <div>
    <table class="sortable">
    <thead>
       <tr><th>Date</th><th>Title</th></tr>
    </thead>
    <tbody>
   {for $item in $items
    order by $item/@date descending
    return
      <tr><td sorttable_customkey="{$item/@date}" width="15%"><a href="?type=item&amp;value={$item/@date}">{blog:format-date($item/@date)}</a></td><td> {$item/@title/string()} </td></tr>
    }
    </tbody>
    </table>
 </div>
};

declare function blog:item-side-as-html($item) {
let $later := (blog:next-item($item),$item/@date)[1]
let $earlier := (blog:prev-item($item),$item/@date)[1]
return
<div>
 <div>{xsl:format-date(xs:dateTime($item/@date),"DD MMM YYYY")}</div>
 <div> <a href="?type=item&amp;value={$later}">Later</a></div>
 <div> <a href="?type=item&amp;value={$earlier}">Earlier</a></div>
 <hr/>
 <div class="tag"> 
    {for $tag in $item//b:tag 
     return 
     <div class="tag"><a href="?type=tag&amp;value={$tag}">{$tag/string()}</a></div>
    }
 </div>
</div>
};

declare function blog:item-as-html($item) {
  <div>
    <h2>{$item/@title/string()}</h2>
       <div  class="body">
          {$item/b:body/node()}
       </div>
    <div class="comments">
      { for $comment in $item//b:comment
        return
           <div>
              <div class="byline">by {$comment/@name/string()} on {blog:format-date($comment/@date)}</div>
              <div class="comment">{$comment/node()} </div> 
            </div>
      }
    </div>
  </div>
};

declare function blog:tags-as-html($items) {
  <div>
    <h2>Tags</h2>
      {for $tag at $i in
           for $tag in blog:tags($items)
           order by $tag
           return $tag
       return 
          (<span class="tag"><a href="?type=tag&amp;value={$tag}">{$tag}</a>&#160;</span>,
           if ($i mod 8 = 0 ) then <br/> else ()
          )
      }
  </div>
};

declare function blog:months-as-html($items) {
  <div>
    <h2>Months</h2>
      {
       for $year in blog:years($items)
       order by $year
       return 
        <div>
         <span>{$year}</span> 
         {
          for $month in blog:months($items,$year)
          order by $month
          return 
          <span>
             <a href="?type=month&amp;value={$month}">{date:format-month($month)}</a>
              <span>({count(blog:items-at-month($month))})</span>
          </span>
          }
        </div>
      }
  </div>
};

declare function blog:content($query) {
<div>
  <div id="search-form">
         <form action="?">
           <input type="hidden"  name="type" value="search"/>
           Search <input type="text" name="value" value="{if ($query/type ="search") then $query/value else ()}" size="20"/>
         </form>
  </div>
  <div id="body">
    {
          if ($query/type="item" and empty($query/value) )   then blog:items-as-html(blog:items())
     else if ($query/type="item" and exists($query/value) )  then blog:item-as-html(blog:item-at-date($query/value))
     else if ($query/type="tag"  and empty($query/value))    then blog:tags-as-html(blog:items())
     else if ($query/type="tag"  and exists($query/value))   then blog:items-as-html(blog:items-at-tag($query/value))
     else if ($query/type="month" and empty($query/value))   then blog:months-as-html(blog:items())
     else if ($query/type="month" and exists($query/value))  then blog:items-as-html(blog:items-at-month($query/value))
     else if ($query/type="search" and exists($query/value)) then blog:items-as-html(blog:items-at-q($query/value/string()))
     
     else ()
    }
  </div>
  <div id="side">
     <div><a href="?type=item">Index</a></div> 
     <div><a href="?type=tag">Tags</a></div> 
     <div><a href="?type=month">Months</a></div>  
     <hr/>
    
     {
        if ($query/type="item" and exists($query/value) )  
        then blog:item-side-as-html(blog:item-at-date($query/value))
        else ()
    } 
  
  </div>
</div> 
};