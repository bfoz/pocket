/*	Filename: common.js
	Common stuff used by the Parts DB
	Created	June 30, 2005 by Brandon Fosdick
*/

var ConfigWords = eval('<?php echo js_serialize($ConfigWords) ?>');
var ScriptsString = '<?php echo (strlen($row['Scripts']) == 0)?'':js_serialize($Scripts) ?>';
var Scripts;
//if(
//var Scripts = eval('<?php echo js_serialize($Scripts) ?>');

function WriteConfigWordDiv()
{
	var msg = '<button onClick="AddConfigWord()">Add Config Word</button>';
	for(var i in ConfigWords)
	{
		msg += '<fieldset><legend>Config Word '+i+' <a href="javascript:void(0)" onClick="DeleteConfigWord('+i+')">Delete</a></legend>\n';
		msg += 'Blank Value (hex)<input type=text onChange="HandleConfigBlankChange(this, '+i+')" value="'+ConfigWords[i].Blank+'"><br>';
		msg += '<button onClick="AddConfigWordField('+i+')">Add Field</button>';
		for(var j in (ConfigWords[i].Fields))
		{
			msg += '<fieldset><legend>Field  <input type=text onChange="HandleFieldNameChange(this, '+i+', '+j+')" value="'+ConfigWords[i].Fields[j].Name+'"> <a href="javascript:void(0)" onClick="DeleteConfigWordField('+i+', '+j+')">Delete</a></legend>';
			msg += 'Mask (hex)<input type=text onChange="HandleFieldMaskChange(this, '+i+', '+j+')" value="'+ConfigWords[i].Fields[j].Mask+'"><br>';
			for(var k in ConfigWords[i].Fields[j].States)
			{
				msg += 'State <input type=text onChange="HandleStateNameChange(this, '+i+', '+j+', '+k+')" value="'+ConfigWords[i].Fields[j].States[k].Name+'"> = (hex)<input type=text onChange="HandleStateValueChange(this, '+i+', '+j+', '+k+')" value="'+ConfigWords[i].Fields[j].States[k].Value+'"><a href="javascript:void(0)" onClick="DeleteConfigWordFieldState('+i+', '+j+', '+k+')">Delete</a><br>';
			}
			msg += '<button onClick="AddConfigWordFieldState('+i+', '+j+')">Add State</button>';
			msg += '</fieldset>';
		}
		msg += '</fieldset>';
	}
	getElementById("ConfigWordDiv").innerHTML = msg;
}

//Append a new config word and setup some defaults
function AddConfigWord()
{
	var i = ConfigWords.length;
	ConfigWords[i] = new Array();
	ConfigWords[i].Blank = '';
	ConfigWords[i].Fields = new Array();
	
	WriteConfigWordDiv();
}

//Append a new field to the given config word
function AddConfigWordField(config_num)
{
//	alert(config_num);
	var i = ConfigWords[config_num].Fields.length;
//	alert(i);
//	alert(ConfigWords[config_num].Fields);
	ConfigWords[config_num].Fields[i] = new Array();
	ConfigWords[config_num].Fields[i].Name = '';
	ConfigWords[config_num].Fields[i].Mask = '';
	ConfigWords[config_num].Fields[i].States = new Array();

	WriteConfigWordDiv();
}

//Append a new state to the given field in the given config record
function AddConfigWordFieldState(config_num, field)
{
//	alert(config_num);
	var i = ConfigWords[config_num].Fields[field].States.length;
//	alert(i);
//	alert(ConfigWords[config_num].Fields[0]);
	ConfigWords[config_num].Fields[field].States[i] = new Array();
	ConfigWords[config_num].Fields[field].States[i].Name = '';
	ConfigWords[config_num].Fields[field].States[i].Value = '';

	WriteConfigWordDiv();
}

//Delete a config word
function DeleteConfigWord(config_num)
{
	var a = ConfigWords.slice(0, config_num);
	var b = ConfigWords.slice(config_num+1);
	ConfigWords = a.concat(b);
	
	WriteConfigWordDiv();
}

//Delete a field from the given config word
function DeleteConfigWordField(config_num, field)
{
	var a = ConfigWords[config_num].Fields.slice(0, field);
	var b = ConfigWords[config_num].Fields.slice(field+1);
	ConfigWords[config_num].Fields = a.concat(b);

	WriteConfigWordDiv();
}

//Deletet a state from the given field in the given config record
function DeleteConfigWordFieldState(config_num, field, state)
{
	var a = ConfigWords[config_num].Fields[field].States.slice(0, state);
	var b = ConfigWords[config_num].Fields[field].States.slice(state+1);
	ConfigWords[config_num].Fields[field].States = a.concat(b);

	WriteConfigWordDiv();
}

function HandleStateValueChange(v, config_num, field, state)
{
	//Validate the input
	//Store the input
	if( (v.value[0] == '0') && (v.value[1] == 'x') )
		ConfigWords[config_num].Fields[field].States[state].Value = v.value;
	else
		ConfigWords[config_num].Fields[field].States[state].Value = '0x'+v.value;
}

function HandleStateNameChange(v, config_num, field, state)
{
	//Validate the input
	//Store the input
	ConfigWords[config_num].Fields[field].States[state].Name = v.value;
}

function HandleFieldNameChange(v, config_num, field)
{
	//Validate the input
	//Store the input
	ConfigWords[config_num].Fields[field].Name = v.value;
}

function HandleFieldMaskChange(v, config_num, field)
{
	//Validate the input
	//Store the input
	if( (v.value[0] == '0') && (v.value[1] == 'x') )
		ConfigWords[config_num].Fields[field].Mask = v.value;
	else
		ConfigWords[config_num].Fields[field].Mask = '0x'+v.value;
}

function HandleConfigBlankChange(v, config_num)
{
	//Validate the input
	//Store the input
	if( (v.value[0] == '0') && (v.value[1] == 'x') )
		ConfigWords[config_num].Blank = v.value;
	else
		ConfigWords[config_num].Blank = '0x'+v.value;
}

//----------

function WriteScriptDiv()
{
	var msg = '<button onClick="AddScript()">Add Script</button>';
	for(var i in Scripts)
	{
		msg += '<fieldset><legend>Script '+i+' <a href="javascript:void(0)" onClick="DeleteScript('+i+')">Delete</a></legend>\n';
		msg += '<table>';
		msg += '<tr><td>Script ID</td><td><input type=text onChange="HandleScriptIDChange(this, '+i+')" value="'+Scripts[i].ID+'"></td></tr>';
		msg += '<tr><td>Script Name</td><td><input type=text onChange="HandleScriptNameChange(this, '+i+')" value="'+Scripts[i].Name+'"></td></tr>';
		msg += '<tr><td valign=top>Script</td><td><textarea onChange="HandleScriptCodeChange(this, '+i+')" rows=10 cols=80>'+Scripts[i].Code+'</textarea></td></tr>';
		msg += '</table>';
		msg += '</fieldset>';
	}
	getElementById("ScriptDiv").innerHTML = msg;
}

//Append a new config word and setup some defaults
function AddScript()
{
	var i = Scripts.length;
	Scripts[i] = new Array();
	Scripts[i].ID = '';
	Scripts[i].Name = '';
	Scripts[i].Code = '';
	
	WriteScriptDiv();
}

//Delete a config word
function DeleteScript(script_num)
{
	var a = Scripts.slice(0, script_num);
	var b = Scripts.slice(script_num+1);
	Scripts = a.concat(b);
	
	WriteScriptDiv();
}

function HandleScriptIDChange(v, script_num)
{
	Scripts[script_num].ID = v.value;
}

function HandleScriptNameChange(v, script_num)
{
	Scripts[script_num].Name = v.value;
}

function HandleScriptCodeChange(v, script_num)
{
	Scripts[script_num].Code = v.value;
}

function HandleOnLoad()
{
	if(ScriptsString.length == 0)
		Scripts = new Array();
	else
		Scripts = eval(ScriptsString);

	WriteConfigWordDiv();
	WriteScriptDiv();
}

function HandleOnSubmit()
{
//	alert(serialize(ConfigWords));
	window.document.form1.ConfigWords.value = serialize(ConfigWords);
	window.document.form1.Scripts.value = serialize(Scripts);
//	echo(serialize(ConfigWords), serialize(serialize(ConfigWords)));
	return true;
}

