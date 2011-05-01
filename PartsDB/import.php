<?php
/*	Filename:	index.php
	Import the old chipinfo.cid format into the database
	
	Created	April 30, 2005 Brandon Fosdick
	
	Copyright 2005 Brandon Fosdick under the BSD license (http://osi.org)
*/
    include_once '/home/bfoz/public_html/include/common.php';
?>
<html>
    <head>
        <title>Microchip Part Database Import</title>
        <link rel="stylesheet" href="<?php echo $HOME_URL ?>/style.css" type="text/css" />
    </head>
    <body>
	 	<form method=POST enctype="multipart/form-data">
			Chip Info File: <input name="file1" type="file" /><br>
			<input type=submit value='Import' />
		</form>
<?php

//Model for the PartDB
//	Member names are identical to column names
class ChipInfo
{
	public $Name;
	public $Deprecated;
	public $FlashROM;
	public $BandGap;
	public $NumROMWords;
	public $NumConfigWords;
	public $NumEEPROMBytes;
	public $CalibrationAddressConfig;
	public $CalibrationAddressAbsolute;
	public $ChipID;
	public $ChipIDAddressConfig;
	public $ChipIDAddressAbsolute;
	public $ConfigAddressConfig;
	public $ConfigAddressAbsolute;
	public $ProgramWordMask;
	public $NominalVdd;
	public $OverProgram;
	public $NumPayloadBits;
	public $NumPayloadCommandBits;
	public $PowerSequence;
	
	public $ProgramDelay;				//int
	public $SocketImage;					//text
	public $UserIDAddressConfig;		//int
	public $UserIDAddressAbsolute;	//int
	public $OscCalROMAddressConfig;	//int
	public $OscCalROMAddressAbsolute;	//int
	
//	Fuses is an array with one element for each config word in the part.
//	Each element of Fuses is an array of FuseFields
	public $Fuses;

//Orphaned fields from the old chipinfo.cid file
//	Recorded for legacy support
	public $EraseMode;	//text
	public $ProgramTries;	//int
	public $CoreType;	//text
	public $CPwarn;	//bool
	public $CALword;	//bool
	public $ICSPonly;	//bool
};

/*
//Blank is a special state that all fuses must have
class FuseFieldState
{
	public $Name;
	public $Value;
};

//The name Reserved is for bits that aren't used. 
//	The States array for reserved bits should have count of zero
class FuseField
{
	public $Name;
	public $Mask;
	public $States;	//An array of FuseFieldState, one for each state of the field
};

class FuseInfo
{
	public $Blank;
	public $Fields;
};
*/
/*
function serialize_config($fuses)
{
	$s = '{';
	foreach($fuses as $k => $v)
	{
		$s .= '{'.$v['Blank']."\t";
		foreach($v['Fields'] as $fk => $fv)
		{
			if(strlen($fv['Mask'])==0)
				$fv['Mask'] = '0x0000';
			$s .= "{\"$fk\" ".$fv['Mask'];
			foreach($fv as $sk => $sv)
			{
				if( $sk != 'Mask' )
				{
					$s .= " \"$sk\"=$sv";
				}
			}
			$s .= "}\t";
		}
		$s .= "}\n";
	}
	$s .= '}';
	
	return $s;
}*/

	//Map keys from the chip file to members of the info object
	$key_to_member = array(
							"CHIPname"=>"Name", 
							"INCLUDE"=>"Deprecated", 
							"SocketImage"=>"SocketImage", 
							"EraseMode"=>"EraseMode", 
							"FlashChip"=>"FlashROM", 
							"PowerSequence"=>"PowerSequence", 
							"ProgramDelay"=>"ProgramDelay", 
							"ProgramTries"=>"ProgramTries", 
							"OverProgram"=>"OverProgram", 
							"CoreType"=>"CoreType", 
							"ROMsize"=>"NumROMWords", 
							"EEPROMsize"=>"NumEEPROMBytes", 
							"FUSEblank"=>"Fuses", 
							"CPwarn"=>"CPwarn", 
							"CALword"=>"CALword", 
							"BandGap"=>"BandGap", 
							"ICSPonly"=>"ICSPonly", 
							"ChipID"=>"ChipID");

	//Process the uploaded file
	if((array_key_exists('file1', $_FILES)) && ($_FILES['file1']['size']!=0) && ($_FILES['file1']['error']==0))
	{
//		$contents = file_get_contents($_FILES['file1']['tmp_name']);
		$lines = file($_FILES['file1']['tmp_name']);
		if($lines === FALSE)
			die("No lines");

		//Connect to the MySQL database
		$link = new mysqli('localhost',$MYSQL_PUBLIC_USER, $MYSQL_PUBLIC_PASS);
		if(mysqli_connect_errno())
			die("Can't connect to MySQL server because<br>\n".mysqli_connect_error());

		foreach($lines as $line)
		{
			$line = trim($line);	//Lose the newline and any other junk
			//If this is a blank line, we're moving to a new record
			if( strlen($line) == 0 )
			{
				//Write the current info to the database
				$serial_config = serialize($info->Fuses);
				echo "<pre>$serial_config</pre><br>\n";
				$query = "INSERT INTO $BFOZ_DB.$BFOZ_PROJECTS_POCKET_PARTS (CreateTimeStamp, Name, Type, SocketImageType, EraseMode, FlashROM, PowerSequence, ProgramDelay, ProgramTries, OverProgram, CoreType, NumROMWords, NumConfigWords, NumEEPROMBytes, ConfigWordDescriptions, CPwarn, CALword, BandGap, ICSPonly, ChipID1) VALUES (now(), \"PIC$info->Name\", \"PIC\", $info->Deprecated, \"$info->SocketImage\", $info->EraseMode, $info->FlashROM, \"$info->PowerSequence\", $info->ProgramDelay, $info->ProgramTries, $info->OverProgram, \"$info->CoreType\", $info->NumROMWords, \"$info->NumConfigWords\", $info->NumEEPROMBytes, \"".$link->escape_string($serial_config)."\", $info->CPwarn, $info->CALword, $info->BandGap, $info->ICSPonly, \"$info->ChipID\")";
				echo $query."<br>\n";
				$link->query($query) or die("Couldn't insert record: ".$link->error);
				//Create a new info object
				$info = new ChipInfo();
				echo '<br>';
			}
			//If the line is a FUSEblank or doesn't have a space it must be a key=value pair
			else if( (strpos( $line, ' ') === FALSE) || (strpos($line, 'FUSEblank')===0) )
			{
				list($key, $value) = explode('=', $line);
				if( isset($key_to_member[$key]) )
				{
					$member = $key_to_member[$key];
//					echo "key = $key<br>\n";
//					echo 'member = '.$member."<br>\n";
					if( strlen($member) == 0 )
					{
						echo "<font color=red>Unmapped key: $line</font><br>\n";
					}
					else
					{
						switch($key)
						{
							case	'INCLUDE':
//								$info->{$member} = ($value=='Y')?0:1;
//								break;
							case	'FlashChip':
							case	'BandGap':
							case	'CPwarn':
							case	'CALword':
							case	'ICSPonly':
								$info->{$member} = ($value=='Y')?1:0;
								break;
							case	'ChipID':
								$info->{$member} = '0x'.$value;
							case	'ROMsize':
							case	'EEPROMsize':
								$ltrim_value = ltrim($value, '0');
								if(strlen($ltrim_value)==0) $ltrim_value = '00';
								$info->{$member} = '0x'.$ltrim_value;
								break;
							case	'FUSEblank':
//								echo "<font color=blue>$member = $value<br>\n";
								$exploded_fuse_blank = explode(' ', $value);
								$info->NumConfigWords = count($exploded_fuse_blank);
								foreach($exploded_fuse_blank as $k => $v)
								{
//									echo "<font color=blue>$k = $v<br>\n";
									$info->{$member}[$k]['Blank'] = '0x'.$v;
//									echo "<font color=blue>$k = ".$info->{$member}[$k]['Blank']."<br>\n";
								}
//								echo "<font color=blue>$line</font><br>\n";
								break;
							default:
								$info->{$key_to_member[$key]} = $value;
								break;			
						}
//						if($key == 'CHIPname')
//							echo $member.' = '.$info->{$member}."<br>\n";		
//						echo $member.' = '.$info->{$member}."<br>\n";
//						echo $key.' = '.$value."<br>\n";
					}
				}
				else
				{
					die("Unknown key: $line<br>\n");
				}
			}
			else	//Handle FUSE lines
			{
				$no_fuse = substr($line, strpos($line, ' ')+1+4);
				$config_number = substr($no_fuse, 0, strpos($no_fuse, ' ')) - 1;	//Extract the config number
				$first_quote = strpos($no_fuse, '"');
				$second_quote = strpos($no_fuse, '"', $first_quote+1);
				$field_name = substr($no_fuse, $first_quote+1, $second_quote-$first_quote-1);
				if( isset($info->Fuses[$config_number]['Fields']) )
					$field_number = count($info->Fuses[$config_number]['Fields']);
				else
					$field_number = 0;
				$info->Fuses[$config_number]['Fields'][$field_number]['Name'] = $field_name;

				$a = explode(' ', trim(substr($no_fuse, $second_quote+1)));
				$prefix = '';	//Kludge to handle spaces in field names
				$state_number = 0;
				foreach($a as $k => $v)
				{
					if( strpos($v, '=') === FALSE )	//Kludge to handle spaces in field names
					{
						$prefix .= $v.' ';
						continue;
					}
					list($state_name, $state_value) = explode('=', $prefix.$v);
					$prefix = '';	//Kludge to handle spaces in field names
					$state_name = trim($state_name, '"');
//					echo "<font color=blue>$state_name = $state_value</font><br>\n";
					$info->Fuses[$config_number]['Fields'][$field_number]['Mask'] = '';
					$info->Fuses[$config_number]['Fields'][$field_number]['States'][$state_number]['Name'] = $state_name;
					$info->Fuses[$config_number]['Fields'][$field_number]['States'][$state_number]['Value'] = '0x'.$state_value;
					++$state_number;
				}
//				echo "<font color=blue>$config_number: $field_name: $no_fuse</font><br>\n";
			}
		}
		$link->close();
	}
?>
    </body>
</html>
