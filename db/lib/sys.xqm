module namespace sys = "http://kitwallace.co.uk/ns/sys";
(: various system functions :)

(:
  save the zip resources file to a directory on the web so that the file can be download eg using wget
  files are not timestamped so only one backup per resourcefile name is stored
:)

declare function sys:zip($resources as xs:string*) {
let $uris := 
    for $resource in $resources
    return xs:anyURI($resource)

return compression:zip($uris,true())
};

declare function sys:list-resources($resources) {
let $base := $resources/@base
return
      <table border ="1" class="sortable">
            <tr><th width="30%">Resource</th><th>Export?</th><th>Filestore?</th><th>Description</th><th>Links</th></tr>
            {for $resource in $resources/resource
             let $path := 
               if (starts-with($resource/@path,"/")) 
               then $resource/@path/string()
               else concat($base,$resource/@path)
             let $suffix := tokenize(tokenize($path,"/")[last()],"\.")[last()]
             return 
               <tr>
                   <td>
                      {if ($suffix = ("xml","xsl","css","conf","xconf","js","txt"))
                       then <a href="/exist/rest/{$path}">{$path}</a>                     
                       else $path
                      }
                   </td>
                   <td>{if (empty($resource/@ignore)) then "yes" else () }</td>
                   <td>{if ($resource/@fspath) then "yes" else () } </td>
                   <td>{$resource/description/string()} {if ($resource/@fspath) then concat (" [ ", $resource/@fspath, "]") else () } </td>
                   <td>{for $link in $resource/link
                        return <a href="{$link}">{$link/string()}</a>
                        }
                    </td>
               </tr>
            }
         </table>
};

declare function sys:view-resources($resourceFile) {
let $resources := doc($resourceFile)/resources
return
 <div>
     {sys:list-resources($resources)}
 </div>
};

declare function sys:zip-resources($resourceFile) {
let $resources := doc($resourceFile)/resources
let $base := $resources/@base
let $backupdir := $resources/@backupdir
return

    let $zipfilename := concat($resources/@name,current-dateTime(),"-backup.zip")
    let $paths := 
      for $path in $resources/resource[empty(@ignore)]/@path
      return 
        if (starts-with($path,"/")) 
        then $path
        else concat($base,$path)

    let $zip := sys:zip($paths)
    let $zipfile := concat($backupdir,$zipfilename)
    let $store := file:serialize-binary($zip,<name>{$zipfile}</name>)
    return
      if ($store)
      then 
       <div> 
         <h2>{$resources/@name/string()} - {$resourceFile}</h2>
         <div>zip file saved to {$zipfile}</div>
       </div>
    else 
    <div>
        <h2>{$resources/@name/string()} - {$resourceFile}</h2>
        <div> zip or store failed</div>
    </div>
};

declare function sys:system-properties() {
element div{
  element version {system:get-version()},
  element revision {system:get-revision()}, 
  element build {system:get-build()},
  element uptime-hours {days-from-duration(system:get-uptime())* 24 + hours-from-duration(system:get-uptime())},
  element active-instances {system:count-instances-active()},
  element available-instances {system:count-instances-available()},
  element max-instances {system:count-instances-max()},
  element memory-free {round(system:get-memory-free() div 1024) },
  element memory-max {round(system:get-memory-max() div 1024 )},
  element memory-total {round(system:get-memory-total() div 1024)},
  element modules {
  for $module in util:registered-modules() 
  order by $module
   return
    element module {$module}
  }
}

};