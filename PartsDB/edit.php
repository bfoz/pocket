<?php
/*	Filename:	edit.php
	Edit a part record
	PartsDB is a database of Microchip part info needed by pocket
	
	Created	May 3, 2005 Brandon Fosdick
	
	Copyright 2005 Brandon Fosdick under the BSD license (http://osi.org)
*/
    include_once '/home/bfoz/public_html/include/common.php';
    include_once '/home/bfoz/public_html/include/js_serialize.php';


//	foreach($_GET as $k => $v)
//		echo "$k => $v<br>\n";

/*	if( isset($_POST) )
		foreach($_POST as $k => $v)
			echo "$k => $v<br>\n";
*/
/*
	[config_number]['Blank']
	[config_number]['Fields'][field_number]['Name']
	[config_number]['Fields'][field_number]['Mask']
	[config_number]['Fields'][field_number]['States'][state_number]['Name']
	[config_number]['Fields'][field_number]['States'][state_number]['Value']
*/

	//Connect to the MySQL database
	$link = new mysqli('localhost',$MYSQL_PUBLIC_USER, $MYSQL_PUBLIC_PASS);

	if(mysqli_connect_errno())
		die("Can't connect to MySQL server because<br>\n".mysqli_connect_error());

	if(isset($_GET['new']))
	{
		$query = "INSERT INTO $BFOZ_DB.$BFOZ_PROJECTS_POCKET_PARTS (CreateTimeStamp) VALUES (now())";
		if(!$link->query($query))
			die("Couldn't create the new record: ".$link->error);
		$_GET['ID'] = $link->insert_id;
	}

	if( isset($_POST['submit']) )
	{

		//Convert checkboxes to boolean
		$FlashROM = isset($_POST['FlashROM'])?1:0;
		$BandGap = isset($_POST['BandGap'])?1:0;
		$CPwarn = isset($_POST['CPwarn'])?1:0;
		$CALword = isset($_POST['CALword'])?1:0;
		$ICSPonly = isset($_POST['ICSPonly'])?1:0;

		//Assume that this module only updates existing records. Creating new records is handled someplace else.
		$query = "UPDATE $BFOZ_DB.$BFOZ_PROJECTS_POCKET_PARTS SET Name=\"".$_POST['Name']."\", Type=\"".$_POST['Type']."\", Status=\"".$_POST['Status']."\", FlashROM=$FlashROM, BandGap=$BandGap, NumROMWords=\"".$_POST['NumROMWords']."\", NumConfigWords=\"".$_POST['NumConfigWords']."\", NumEEPROMBytes=\"".$_POST['NumEEPROMBytes']."\", CalibrationAddressConfig=\"".$_POST['CalibrationAddressConfig']."\", CalibrationAddressAbsolute=\"".$_POST['CalibrationAddressAbsolute']."\", ChipID1=\"".$_POST['ChipID1']."\", ChipID2=\"".$_POST['ChipID2']."\", ChipIDAddressConfig=\"".$_POST['ChipIDAddressConfig']."\", ChipIDAddressAbsolute=\"".$_POST['ChipIDAddressAbsolute']."\", ConfigAddressConfig=\"".$_POST['ConfigAddressConfig']."\", ConfigAddressAbsolute=\"".$_POST['ConfigAddressAbsolute']."\", ProgramWordMask=\"".$_POST['ProgramWordMask']."\", NominalVdd=\"".$_POST['NominalVdd']."\", OverProgram=\"".$_POST['OverProgram']."\", NumPayloadBits=\"".$_POST['NumPayloadBits']."\", NumPayloadCommandBits=\"".$_POST['NumPayloadCommandBits']."\", PowerSequence=\"".$_POST['PowerSequence']."\", ProgramDelay=\"".$_POST['ProgramDelay']."\", SocketImageType=\"".$_POST['SocketImageType']."\", UserIDAddressConfig=\"".$_POST['UserIDAddressConfig']."\", UserIDAddressAbsolute=\"".$_POST['UserIDAddressAbsolute']."\", OscCalROMAddressConfig=\"".$_POST['OscCalROMAddressConfig']."\", EraseMode=\"".$_POST['EraseMode']."\",  ProgramTries=\"".$_POST['ProgramTries']."\", CoreType=\"".$_POST['CoreType']."\", OscCalROMAddressAbsolute=\"".$_POST['OscCalROMAddressAbsolute']."\", CPwarn=$CPwarn, CALword=$CALword, ICSPonly=$ICSPonly, ConfigWordDescriptions=\"".$link->escape_string($_POST['ConfigWords'])."\", Scripts=\"".$link->escape_string(str_replace("\n", "", $_POST['Scripts']))."\" WHERE ID=".$_POST['ID'];
//		echo "<br>Submitted<br>\n";
//		echo "$query<br>\n";
		if(!$link->query($query))
			die("Couldn't update the record: ".$link->error);
	}

	$query = "SELECT count(*) as Num FROM $BFOZ_DB.$BFOZ_PROJECTS_POCKET_PARTS";
	if($result = $link->query($query))
	{
		if($row = $result->fetch_assoc())
			$NumRecords = $row['Num'];
		else
			die("Couldn't get the count: ".$link->error);
	}
	else
		die("Couldn't get the count 2: ".$link->error);
	
	$next_id = $_GET['ID']+1;
	$prev_id = $_GET['ID']-1;
	if($next_id > $NumRecords)
		$next_id = 0;

	$query = "SELECT * FROM $BFOZ_DB.$BFOZ_PROJECTS_POCKET_PARTS WHERE ID=\"".$_GET['ID']."\"";
	if($parts = $link->query($query))
	{
		if(!($row = $parts->fetch_assoc()))
		{
			die("Couldn't get the part");
		}
	}
	else
	{
		die("Couldn't get the part 2");
	}

	//Make the options for the Type select element
	$query = "DESCRIBE $BFOZ_DB.$BFOZ_PROJECTS_POCKET_PARTS Type";
	if($result = $link->query($query))
	{
		if($r = $result->fetch_assoc())
			$Types = explode(',', str_replace("'", "", substr(substr($r['Type'], 5), 0, -1)));
		else
			die("Couldn't get the description row: ".$link->error);
	}
	else
		die("Couldn't get the description: ".$link->error);
	
	$TypeOptions = '';
	foreach($Types as $t)
		$TypeOptions .= '<option '.(($row['Type']==$t)?'selected':'')." value=\"$t\">$t</option>";

	//Make the options for the Status select element
	$query = "DESCRIBE $BFOZ_DB.$BFOZ_PROJECTS_POCKET_PARTS Status";
	if($result = $link->query($query))
	{
		if($r = $result->fetch_assoc())
			$Status = explode(',', str_replace("'", "", substr(substr($r['Type'], 5), 0, -1)));
		else
			die("Couldn't get the description row: ".$link->error);
	}
	else
		die("Couldn't get the description: ".$link->error);
	
	$StatusOptions = '';
	foreach($Status as $t)
		$StatusOptions .= '<option '.(($row['Status']==$t)?'selected':'')." value=\"$t\">$t</option>";

//	echo $row['ConfigWordDescriptions']."<br>\n<br>\n";
//	echo $row['Scripts']."<br>\n<br>\n";
	$ConfigWords = unserialize($row['ConfigWordDescriptions']);
	if( strlen($row['Scripts']) == 0 )
		$Scripts = '';
	else
		$Scripts = unserialize($row['Scripts']);

/*	echo '<pre>';
	var_dump($ConfigWords);
	echo "</pre><br>\n<br>\n";
	echo js_serialize($ConfigWords)."<br>\n<br>\n";
	echo "<div id=\"JSdiv\"></div>\n";
*/
	$link->close();
?>
<html>
	<head>
		<title>Microchip Part Database</title>
		<link rel="stylesheet" href="<?php echo $HOME_URL ?>/style.css" type="text/css" />
		<link rel="stylesheet" href="style.css" type="text/css" />
		<script language="JavaScript" src="/include/util.js"></script>
		<script language="JavaScript" src="/include/dltypeof.js"></script>
		<script language="JavaScript" src="./jspan_serialize.js"></script>
		<script language="JavaScript" src ="./common.js"></script>
	</head>
		<body onLoad="HandleOnLoad()">

<?php
?>
		<p>The form doesn't force any of the fields to be filled. That way you can submit whatever you know and leave the rest to somebody else.</p>
		<p><strong>Note 1: </strong>All numeric fields are decimal unless otherwise noted.</p>
		<p><strong>Note 2: </strong>Hex values don't need any sort of prefix (i.e. no h' or '0x'), but it won't hurt if they have '0x'.</p>

		<a href="?ID=<?=$prev_id?>" <?=$prev_id?"":"onClick='return false'"?>>Previous</a> <a href=".">Up</a> <a href="?ID=<?=$next_id?>" <?=$next_id?"":"onClick='return false'"?>>Next</a>
		<form name="form1" method=POST onSubmit="return HandleOnSubmit();" >
			<input type=hidden name="ID" value="<?php echo $row['ID'];?>">
			<input type=hidden name="ConfigWords">
			<input type=hidden name="Scripts">
			<fieldset>
					<table>
	            	<tr><td>Name</td><td><input type=text name="Name" value="<?=$row['Name'] ?>"></td></tr>
						<tr><td>Type</td><td><select name="Type"><?php echo $TypeOptions; ?></select></td></tr>
						<tr><td>Status</td><td><select name="Status"><?php echo $StatusOptions; ?></select></td></tr>
						<tr><td>Program Word Mask (hex)</td><td><input type=text name="ProgramWordMask" value="<?=$row['ProgramWordMask'] ?>"></td></tr>
						<tr><td>Nominal Vdd</td><td><input type=text name="NominalVdd" value="<?=$row['NominalVdd'] ?>"></td></tr>
						<tr><td>Over Program Count</td><td><input type=text name="OverProgram" value="<?=$row['OverProgram'] ?>"></td></tr>
						<tr><td>Number of Payload Bits</td><td><input type=text name="NumPayloadBits" value="<?=$row['NumPayloadBits'] ?>"></td></tr>
						<tr><td>Number of Payload Command Bits</td><td><input type=text name="NumPayloadCommandBits" value="<?=$row['NumPayloadCommandBits'] ?>"></td></tr>
						<tr><td>Power Sequence</td><td><input type=text name="PowerSequence" value="<?=$row['PowerSequence'] ?>"></td></tr>
						<tr><td>Program Delay</td><td><input type=text name="ProgramDelay" value="<?=$row['ProgramDelay'] ?>"></td></tr>
						<tr><td>Socket Image Type</td><td><input type=text name="SocketImageType" value="<?=$row['SocketImageType'] ?>"></td></tr>
					</table>
				</fieldset>
				<fieldset><legend>Flags</legend>
					<input type=checkbox name="FlashROM" <?= $row['FlashROM']?'checked':''?>> Flash Part?<br>
					<input type=checkbox name="BandGap" <?= $row['BandGap']?'checked':''?>> Band Gap?<br>
					<input type=checkbox name="CPwarn" <?= $row['CPwarn']?'checked':''?>> Code Protect Warning? (P018 only)<br>
					<input type=checkbox name="CALword" <?= $row['CALword']?'checked':''?>> Has Cal Word?  (P018 only)<br>
					<input type=checkbox name="ICSPonly" <?= $row['ICSPonly']?'checked':''?>> ICSP Only?  (P018 only)<br>
				</fieldset>
				<fieldset><legend>Memory Sizes</legend>
					<table>
	            	<tr><td>Number of ROM Words</td><td><input type=text name="NumROMWords" value="<?=$row['NumROMWords'] ?>"></td></tr>
						<tr><td>Number of Config Words</td><td><input type=text name="NumConfigWords" value="<?=$row['NumConfigWords'] ?>"></td></tr>
						<tr><td>Number of EEPROM Bytes</td><td><input type=text name="NumEEPROMBytes" value="<?=$row['NumEEPROMBytes'] ?>"></td></tr>
					</table>
				</fieldset>
				<fieldset><legend>Calibration Address</legend>
					<table>
						<tr><td>Config Space Address</td><td><input type=text name="CalibrationAddressConfig" value="<?=$row['CalibrationAddressConfig'] ?>"><br>
						<tr><td>Absolute Address</td><td><input type=text name="CalibrationAddressAbsolute" value="<?=$row['CalibrationAddressAbsolute'] ?>"><br>
					</table>
				</fieldset>
				<fieldset><legend>OscCal ROM</legend>
					<table>
						<tr><td>Config Space Address</td><td><input type=text name="OscCalROMAddressConfig" value="<?=$row['OscCalROMAddressConfig'] ?>"></td></tr>
						<tr><td>Absolute Address</td><td><input type=text name="OscCalROMAddressAbsolute" value="<?=$row['OscCalROMAddressAbsolute'] ?>"></td></tr>
					</table>
				</fieldset>
				<fieldset><legend>Chip ID</legend>
					<table>
						<tr><td>Chip ID 1 (hex)</td><td><input type=text name="ChipID1" value="<?=$row['ChipID1'] ?>"><br>
						<tr><td>Chip ID 2 (hex)</td><td><input type=text name="ChipID2" value="<?=$row['ChipID2'] ?>"><br>
						<tr><td>Config Space Address</td><td><input type=text name="ChipIDAddressConfig" value="<?=$row['ChipIDAddressConfig'] ?>"></td></tr>
						<tr><td>Absolute Address</td><td><input type=text name="ChipIDAddressAbsolute" value="<?=$row['ChipIDAddressAbsolute'] ?>"></td></tr>
					</table>
				</fieldset>
				<fieldset><legend>Config Words</legend>
					<table>
						<tr><td>Config Space Address</td><td><input type=text name="ConfigAddressConfig" value="<?=$row['ConfigAddressConfig'] ?>"></td></tr>
						<tr><td>Absolute Address</td><td><input type=text name="ConfigAddressAbsolute" value="<?=$row['ConfigAddressAbsolute'] ?>"></td></tr>
					</table>
				</fieldset>
				<fieldset><legend>User ID</legend>
					<table>
						<tr><td>Config Space Address</td><td><input type=text name="UserIDAddressConfig" value="<?=$row['UserIDAddressConfig'] ?>"></td></tr>
						<tr><td>Absolute Address</td><td><input type=text name="UserIDAddressAbsolute" value="<?=$row['UserIDAddressAbsolute'] ?>"></td></tr>
					</table>
				</fieldset>
				<fieldset><legend>Misc P018 Stuff</legend>
					<table>
						<tr><td>Core Type (optional)</td><td><input type=text name="CoreType" value="<?=$row['CoreType'] ?>"></td></tr>
						<tr><td>Erase Mode</td><td><input type=text name="EraseMode" value="<?=$row['EraseMode'] ?>"></td></tr>
						<tr><td>Program Tries</td><td><input type=text name="ProgramTries" value="<?=$row['ProgramTries'] ?>"></td></tr>
					</table>
				</fieldset>
				<fieldset><legend>Config Words</legend>
					<p>These settings are only used for display purposes in GUI-based programming software. Otherwise they're optional, since they don't have anything to do with the actual programming of the chip.</p>
					<div id="ConfigWordDiv"></div>
				</fieldset>
				<fieldset><legend>Microcode Scripts</legend>
					<div id="ScriptDiv"></div>
				</fieldset>
				<button type=submit name="submit">Submit</button>
        </form>
    </body>
</html>
