module namespace date= "http://kitwallace.co.uk/ns/blogdate";

(: extract from the full date module :)

declare variable $date:months :=
	("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct","Nov", "Dec");
	
declare variable $date:otherMonths :=
	("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct","Nov", "Dec");

declare variable $date:fullMonths :=
	("January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
	"November", "December");

declare variable $date:days :=
  ( "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday");

declare variable $date:shortDays :=
  ( "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun");

declare function date:zero-pad($i) as xs:string {
	if(xs:integer($i) lt 10) then
		concat("0", $i)
	else
		xs:string($i)
};

declare function date:blogdate-to-dateTime($date as xs:string) {
(: e.g. January 10 2008,  2:24 PM 

could do this with the two generl functions but need to add AM/PM to time 
:)
  let $d := tokenize(normalize-space($date),"\s")
  let $month := date:zero-pad((index-of($date:months,$d[1]), index-of($date:fullMonths,$d[1]),index-of($date:otherMonths,$date[1]))[1])
  let $day := date:zero-pad($d[2])
  let $year := substring($d[3],1,4)
  let $time := tokenize($d[4],":")
  let $hour  := number($time[1]) 
  let $pm := if($d[5] = "PM" and $hour <= 11 ) then 12 else 0
  let $hour := date:zero-pad($hour+ $pm)
  let $minute := $time[2]
  return concat($year,"-",$month,"-",$day,"T",$hour,":",$minute,":00Z")
};

declare function date:format-month($month) {
  let $m := number(substring($month,6,2))
  return $date:months[$m]
};
