<?php
/*	Filename:	export.php
	Export the chip info to a flat file
	Three Formats:
		chipinfo.cid	Old P018 file format
		chipinfo.diy	New P019 format
		extattr			Key/value pairs for use by pocket to set its ext attributes
	
	NOTE: Returning extended attributes is the default
	
	For the two chipinfo options headers are returned for downloading a file
	The extended attributes option returns plain ASCII text with the keys and values on seperate lines like so:
		key1
		value1
		key2
		value2
		...
	
	Created	May 8, 2005 Brandon Fosdick
	
	Copyright 2005 Brandon Fosdick under the BSD license (http://osi.org)
*/
    include_once '/home/bfoz/public_html/include/common.php';

$query = "SELECT * FROM $BFOZ_DB.$BFOZ_PROJECTS_POCKET_PARTS WHERE Status!='Deprecated'";
$query_pic = $query." AND Type=\"PIC\"";
$query_i2c = $query." AND Type=\"I2C\"";

function make_cid($db)
{
	global $query_pic;
	
	$S = '';
	$result = $db->query($query_pic) or die("Couldn't get PIC records: ".$db->error);
	while($row = $result->fetch_assoc())
	{
		$s = 'CHIPname='.$row['Name']."\n";
		if($row['Status']=='Production')
			$s .= "INCLUDE=Y\n";
		else
			$s .= "INCLUDE=N\n";
		$s .= 'SocketImage='.$row['SocketImageType']."\n";
		$s .= 'EraseMode='.$row['EraseMode']."\n";
		$s .= 'FlashChip='.($row['FlashROM']?'Y':'N')."\n";
		$s .= 'PowerSequence='.$row['PowerSequence']."\n";
		$s .= 'ProgramDelay='.$row['ProgramDelay']."\n";
		$s .= 'ProgramTries='.$row['ProgramTries']."\n";
		$s .= 'OverProgram='.$row['OverProgram']."\n";
		$s .= 'CoreType='.$row['CoreType']."\n";
		$s .= 'ROMsize='.sprintf("%X", $row['NumROMWords'])."\n";
		$s .= 'EEPROMsize='.sprintf("%X", $row['NumEEPROMBytes'])."\n";
		$s .= "FUSEblank=%FUSEBLANK%\n";	//replace later
		$s .= 'CPwarn='.($row['CPwarn']?'Y':'N')."\n";
		$s .= 'CALword='.($row['CALword']?'Y':'N')."\n";
		$s .= 'BandGap='.($row['BandGap']?'Y':'N')."\n";
		$s .= 'ICSPonly='.($row['ICSPonly']?'Y':'N')."\n";
		$s .= 'ChipID='.str_replace("0x", '', $row['ChipID1'])."\n";

		//Make the config words
		$configs = unserialize($row['ConfigWordDescriptions']);
		$list_num = 1;
		$fuse_blank = '';
		foreach( $configs as $k => $v )
		{
			$fuse_blank[$k] = str_replace("0x", '', $v['Blank']);
			foreach( $v['Fields'] as $fv )
			{
				$s .= 'LIST'.$list_num.' FUSE'.($k+1)." \"".$fv['Name']."\"";
				foreach( $fv['States'] as $sv )
					$s .= ' "'.$sv['Name'].'"='.str_replace("0x", '', $sv['Value']);
				$s .= "\n";
				++$list_num;
			}
		}
		$S .= str_replace("%FUSEBLANK%", implode(' ', $fuse_blank), $s)."\n";
	}
	
	return $S;
}

function make_diy($db)
{
	global $query;
	
	$S = '';
	$result = $db->query($query) or die("Couldn't get records: ".$db->error);
	while($row = $result->fetch_assoc())
	{
		if($row['Type']=='PIC')
			$s = 'PICname=';
		else if($row['Type']=='I2C')
			$s = 'I2Cname=';
		$s .= $row['Name']."\n";
		if($row['Status']=='Production')
			$s .= "INCLUDE=Y\n";
		else
			$s .= "INCLUDE=N\n";
		if($row['Type']=='I2C')
			if( strlen($row['I2CStrategy']) != 0 )
				$s .= "I2CStrategy=\n";
		$s .= 'SocketImage='.$row['SocketImageType']."\n";
		$s .= 'EraseMode='.$row['EraseMode']."\n";
		$s .= 'FlashChip='.($row['FlashROM']?'Y':'N')."\n";
		$s .= 'PowerSequence='.$row['PowerSequence']."\n";
		$s .= 'ProgramDelay='.$row['ProgramDelay']."\n";
		$s .= 'ProgramTries='.$row['ProgramTries']."\n";
		$s .= 'OverProgram='.$row['OverProgram']."\n";
		$s .= 'CoreType='.$row['CoreType']."\n";
		$s .= 'ROMsize='.sprintf("0x%X", $row['NumROMWords'])."\n";
		$s .= 'EEDATAsize='.sprintf("0x%X", $row['NumEEPROMBytes'])."\n";
		$s .= "FUSEblank=%FUSEBLANK%\n";	//replace later
		$s .= 'CPwarn='.($row['CPwarn']?'Y':'N')."\n";
		$s .= 'CALword='.($row['CALword']?'Y':'N')."\n";
		$s .= 'BandGap='.($row['BandGap']?'Y':'N')."\n";
		$s .= 'ICSPonly='.($row['ICSPonly']?'Y':'N')."\n";
		$s .= 'MaskDataFrame='.$row['ProgramWordMask']."\n";
		$s .= 'NomVDD='.$row['NominalVdd']."\n";
		$s .= 'PayloadBits='.$row['NumPayloadBits']."\n";
		$s .= 'PayloadComBits='.$row['NumPayloadCommandBits']."\n";
		if( (strlen($row['CalibrationAddressConfig'])!=0) && (strlen($row['CalibrationAddressAbsolute'])!=0) )
			$s .= 'CalValLoc= '.$row['CalibrationAddressConfig'].sprintf(", 0x%X\n", $row['CalibrationAddressAbsolute']);
		$s .= 'ChipID1='.$row['ChipID1']."\n";
		if( strlen($row['ChipID2'])!=0 )
			$s .= 'ChipID2='.$row['ChipID2']."\n";
		if( (strlen($row['ChipIDAddressConfig'])!=0) && (strlen($row['ChipIDAddressAbsolute'])!=0) )
			$s .= 'DeviceIDLoc= '.$row['ChipIDAddressConfig'].sprintf(", 0x%X\n", $row['ChipIDAddressAbsolute']);
		if( (strlen($row['ConfigAddressConfig'])!=0) && (strlen($row['ConfigAddressAbsolute'])!=0) )
			$s .= 'ConfigLoc= '.$row['ConfigAddressConfig'].sprintf(", 0x%X\n", $row['ConfigAddressAbsolute']);
		if( (strlen($row['OscCalROMAddressConfig'])!=0) && (strlen($row['OscCalROMAddressAbsolute'])!=0) )
			$s .= 'OscCalROM= '.$row['OscCalROMAddressConfig'].sprintf(", 0x%X\n", $row['OscCalROMAddressAbsolute']);
		if( (strlen($row['UserIDAddressConfig'])!=0) && (strlen($row['UserIDAddressAbsolute'])!=0) )
			$s .= 'DeviceIDLoc= '.$row['UserIDAddressConfig'].sprintf(", 0x%X\n", $row['UserIDAddressAbsolute']);

		//Make the config words
		$configs = unserialize($row['ConfigWordDescriptions']);
		$list_num = 1;
		$fuse_blank = '';
		foreach( $configs as $k => $v )
		{
			$fuse_blank[$k] = $v['Blank'];
			foreach( $v['Fields'] as $fv )
			{
				$s .= 'LIST'.$list_num.' FUSE'.($k+1)." \"".$fv['Name']."\"";
				foreach( $fv['States'] as $sv )
					$s .= ' "'.$sv['Name'].'"='.$sv['Value'];
				$s .= "\n";
				++$list_num;
			}
		}
		
		//Emit the scripts
		$Scripts = unserialize($v);
		foreach( $Scripts as $sk => $sv )
		{
			$s .= 'CODE "'.$sv['ID'].'" "'.$sv['Name'].'": '.str_replace("\n", " ", $sv['Code'])."\n";
		}

		$S .= str_replace("%FUSEBLANK%", implode(' ', $fuse_blank), $s)."\n";
	}
	
	return $S;
}

function make_xattr($db, $Prefix, $seperator)
{
	global $query;

//	$Prefix = 'net.bfoz/projects/pocket/PartsDB/';
	$S = '';
	$result = $db->query($query) or die("make_xattr: Couldn't get the records: ".$db->error);
	while($row = $result->fetch_assoc())
	{
		$Name = $row['Name'];	//Make a copy (don't mess up the array pointer)
		foreach($row as $k => $v)
		{
			switch($k)
			{
				case 'ID':				//Fields to ignore
				case 'Name':
				case 'Deprecated':
				case 'CreateTimeStamp':
					break;
				case 'ConfigWordDescriptions':
					if( strlen($v) != 0 )
					{
						$ConfigWords = unserialize($v);
						foreach( $ConfigWords as $ck => $cv )
						{
							$s = implode($seperator, array($Prefix.$Name, $k, $ck)).$seperator;
	//						$s = $Prefix.$Name.'/'.$k.'/'.$ck.'/';
							$S .= $s."Blank\n".$cv['Blank']."\n";
							if( isset( $cv['Fields'] ) )
							{
								foreach( $cv['Fields'] as $cfk => $cfv )
								{
									$a = $s."Fields/$cfk/";
									$S .= $a."Name\n".$cfv['Name']."\n";
									$S .= $a."Mask\n".$cfv['Mask']."\n";
									foreach( $cfv['States'] as $csk => $csv )
									{
										$b = $a."States/$csk/";
										$S .= $b."Name\n".$csv['Name']."\n";
										$S .= $b."Value\n".$csv['Value']."\n";
									}
								}
							}
						}
					}
					break;
				case 'Scripts':
					if( strlen($v) != 0 )
					{
						$Scripts = unserialize($v);
						foreach( $Scripts as $sk => $sv )
						{
							$s = $Prefix.$Name.'/'.$k.'/'.$sk.'/';
							$S .= $s."ID\n".$sv['ID']."\n";
							$S .= $s."Name\n".$sv['Name']."\n";
							$S .= $s."Code\n".$sv['Code']."\n";
						}
					}
					break;
				default:
					$S .= $Prefix.$Name."/$k\n$v\n";
					break;
			}
		}
	}
	return $S;
}

function do_header($size, $name)
{
	Header("Content-Type: text/plain");
	if(strlen($name) != 0)
	{
		Header("Content-Length: $size");
		Header("Content-Disposition: attachment; filename=$name");
	}
}

	//Connect to the MySQL database
	$link = new mysqli('localhost',$MYSQL_PUBLIC_USER, $MYSQL_PUBLIC_PASS);
	if(mysqli_connect_errno())
		die("Can't connect to MySQL server because<br>\n".mysqli_connect_error());

//	Header("Content-Type: text/plain");
	switch(isset($_GET['format'])?$_GET['format']:'')
	{
		case 'cid':
			$S = make_cid($link);
			do_header(strlen($S), "chipinfo.cid");
			break;
		case 'diy':
			$S = make_diy($link);
//			do_header(strlen($S), "chipinfo.diy");
			do_header(strlen($S), "");
			break;
		case	'extattr':
		default:
			do_header(0, "");
			$prefix = isset($_GET['noprefix']) ? '' : 'net.bfoz/projects/pocket/PartsDB/';
			$S = make_xattr($link, $prefix, '/');
			if( isset($_GET['noslashes']) )
				$S = str_replace('/', ':', $S);
			break;
	}
	echo $S;
	$link->close();
?>
