<?php

header('Content-type: text/xml', true);
$rootURL = "http://" . $_SERVER[HTTP_HOST] . $_SERVER[REQUEST_URI];
$rootURL =  substr($rootURL, 0, strrpos ($rootURL, "/")); 


$folder="mp3"; //folder, where mp3s are

$title      = "Podcast Feed";
$author     = "you";
$description= "Your Podcasts";
$link       = "http://www.yourweb.com/";
$subtitle   = "MP4 Podcasting";
$summary    = "MP4 feed";
$language   = "en";
$copyright  = "you";
$owner_name = "you";
$owner_email= "you@email.com";
$image      = "http://www.slava.pri.ee/podcast/doppler.jpg";
$category   = "MP4";
$subcategory= "";
$type       = "video/mp4";
$extension  = ".mp4";

print"<?xml version='1.0' encoding='UTF-8'?>\n";
?>
<rss version="2.0"
   xmlns:content="http://purl.org/rss/1.0/modules/content/"
   xmlns:wfw="http://wellformedweb.org/CommentAPI/"
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:atom="http://www.w3.org/2005/Atom"
   xmlns:sy="http://purl.org/rss/1.0/modules/syndication/"
   xmlns:slash="http://purl.org/rss/1.0/modules/slash/"
   >
<?php
print"<channel>\n";
print"   <title>$title</title>\n";
print"   <atom:link href=\"$link\" rel=\"self\" type=\"application/rss+xml\"/> \n";
print"   <link>$link</link>\n";
print"   <description>$description</description>\n";
print"   <language>$language</language>\n";
print"   <sy:updatePeriod>hourly</sy:updatePeriod>\n";
print"   <sy:updateFrequency>1</sy:updateFrequency>\n";

?>

<!--
 // Other Fields that can be used 
 <title>title</title>
 <link>http://hyperlink</link>
 <dc:creator>creator</dc:creator>
 <category><![CDATA[Video]]></category> 
 <guid isPermaLink="false">http://link</guid>
 <description><![CDATA[Shownotes:Description[...]]]</description>
 <pubDate>Fri, 21 Aug 2009 02:20:43 +0000</pubDate>   

   -->

<?php
$dirArray = getDir($folder."/", $extension);

while (list($filename, $filedate) = each($dirArray)) {
   $filename     = $folder."/".$filename;
   $filesize     = filesize($filename);
   $filenameHTML = htmlentities(str_replace(" ", "%20", $filename));
   print "     <item>\n";
   print "        <enclosure url=\"$rootURL/$filenameHTML\" length=\"$filesize\" type=\"$type\" />\n";
   print "     </item>\n";
}
?>
   </channel>
</rss>

<?php
function getDir($folder, $extension) {	

	$dirArray = array();
	$diskdir = "./$folder/";
	if (is_dir($diskdir)) {
		$dh = opendir($diskdir);
		while (($file = readdir($dh)) != false ) {
			if (filetype($diskdir . $file) == "file" && $file[0]  != ".") {
				if (strrchr(strtolower($file), ".") == $extension) {
					$ftime = filemtime($folder."/".$file); 
					$dirArray[$file] = $ftime;
				}
			}
		}
		closedir($dh);
	}
	asort($dirArray);
	$dirArray = array_reverse($dirArray);
	return $dirArray;
}
?>
