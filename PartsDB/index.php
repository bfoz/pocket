<?php
/*	Filename:	index.php
	Top level for PartsDB
	PartsDB is a database of Microchip part info needed by pocket
	
	Created	April 30, 2005 Brandon Fosdick
	
	Copyright 2005 Brandon Fosdick under the BSD license (http://osi.org)
*/
    include_once '/home/bfoz/public_html/include/common.php';
?>
<html>
	<head>
		<title>Microchip Part Database</title>
		<link rel="stylesheet" href="<?php echo $HOME_URL ?>/style.css" type="text/css" />
		<link rel="stylesheet" href="style.css" type="text/css" />
	</head>
	<body>

		<h1>Microchip Part Database for <a href="http://kitsrus.com">Kitsrus</a> Programmers</h1>
		<p>This is the web interface for the database containing the info necessary for Kitsrus DIY programmers. Its maintained on a volunteer basis, so please feel free to correct any missing or eroneous entries.</p>
		<a href="export.php?format=cid">Download chipinfo.cid</a><br>
		<a href="export.php?format=diy">Download chipinfo.diy</a><br>
		<a href="export.php?format=extattr">Download chipinfo.xattr</a>

	<br>
	<form action="edit.php" method="get">
		<input type=hidden name="new" value="1" />
		<button type=submit>New Chip</button>
	</form>

<?php
   	//Connect to the MySQL database
	$link = new mysqli('localhost',$MYSQL_PUBLIC_USER, $MYSQL_PUBLIC_PASS);
	
	if(mysqli_connect_errno())
		die("Can't connect to MySQL server because<br>\n".mysqli_connect_error());

    $query = "SELECT * FROM $BFOZ_DB.$BFOZ_PROJECTS_POCKET_PARTS ORDER BY Name ASC";
?>
        <table>
            <tr>
<!--                <th></th> -->
					 <th>Name</th>
            </tr>
<?php
	if($parts = $link->query($query))
	{
		$i =0;
		while($row = $parts->fetch_assoc())
		{
			echo "<tr><td><a href=\"edit.php?ID=".$row['ID']."\">".$row['Name'].'</a></td><td>[Delete]</td></tr>';
			++$i;
		}
    }
    else
    {
        die("Couldn't get part list");
    }
	 $link->close();
?>
        </table>
    </body>
</html>
