function JPSpan_Encode_PHP() {
    this.Serialize = new JPSpan_Serialize(this);
};

JPSpan_Encode_PHP.prototype = {

    // Used by rawpost request objects
    contentType: 'text/plain; charset=US-ASCII',
    
    encode: function(data) {
        return this.Serialize.serialize(data);
    },
    
    encodeInteger: function(v) {
        return 'i:'+v+';';
    },
    
    encodeDouble: function(v) {
        return 'd:'+v+';';
    },
    
    encodeString: function(v) {
        var s = ''
        for(var n=0; n<v.length; n++) {
            var c=v.charCodeAt(n);
            // Ignore everything but ASCII
            if (c<128) {
                s += String.fromCharCode(c);
            }
        }
        return 's:'+s.length+':"'+s+'";';
    },
    
    encodeNull: function() {
        return 'N;';
    },
    
    encodeTrue: function() {
        return 'b:1;';
    },
    
    encodeFalse: function() {
        return 'b:0;';
    },
    
    encodeArray: function(v, Serializer) {
        var indexed = new Array();
        var count = v.length;
        var s = '';
        for (var i=0; i<v.length; i++) {
            indexed[i] = true;
            s += 'i:'+i+';'+Serializer.serialize(v[i]);
        };

        for ( var prop in v ) {
            if ( indexed[prop] ) {
                continue;
            };
            s += Serializer.serialize(prop)+Serializer.serialize(v[prop]);
            count++;
        };
        
        s = 'a:'+count+':{'+s;
        s += '}';
        return s;
    },
    
	 //Added May 7, 2005 by Brandon Fosdick <bfoz@bfoz.net>
	 encodeAssocArray: function(v, Serializer)
	 {
	 	var s = '';
		var count = 0;
		for( var prop in v )
		{
         s += 's:'+prop.length+':"'+prop+'";';
         if (v[prop]!=null)
			{
				s += Serializer.serialize(v[prop]);
         }
			else
			{
				s +='N;';
         };
			++count;
		}
		s = 'a:'+count+':{'+s+'}';   
		return s;
	 },
	 
    encodeObject: function(v, Serializer, cname) {
        var s='';
        var count=0;
        for (var prop in v) {
            s += 's:'+prop.length+':"'+prop+'";';
            if (v[prop]!=null) {
                s += Serializer.serialize(v[prop]);
            } else {
                s +='N;';
            };
            count++;
        };
        s = 'O:'+cname.length+':"'+cname.toLowerCase()+'":'+count+':{'+s+'}';   
        return s;
    },
    
    encodeError: function(v, Serializer, cname) {
        var e = new Object();
        if ( !v.name ) {
            e.name = cname;
            e.message = v.description;
        } else {
            e.name = v.name;
            e.message = v.message;
        };
        return this.encodeObject(e,Serializer,cname);
    }
}// $Id: serialize.js,v 1.5 2004/11/21 11:14:05 harryf Exp $
// Notes:
// - Watch out for recursive references - call inside a try/catch block if uncertain
// - Objects are serialized to PHP class name JPSpan_Object by default
// - Errors are serialized to PHP class name JPSpan_Error by default
//
// See discussion below for notes on Javascript reflection
// http://www.webreference.com/dhtml/column68/
function JPSpan_Serialize(Encoder) {
    this.Encoder = Encoder;
    this.typeMap = new Object();
};

JPSpan_Serialize.prototype = {

	typeMap: null,

	addType: function(cname, callback) {
	  this.typeMap[cname] = callback;
	},

	serialize: function(v) {

		switch(dltypeof(v)) {		//bfoz May 7, 2005
			case 'array':		//bfoz May 7, 2005
				return this.Encoder.encodeArray(v,this);
			break;
			
			case 'jsobject':
				// It's a null value
				if ( v === null ) {
					return this.Encoder.encodeNull();
				}

				// Get the constructor
				var c = v.constructor;
				if (c != null )
				{
					// Get the class name
					var match = c.toString().match( /\s*function (.*)\(/ );

					if ( match == null ) {
					  return this.Encoder.encodeObject(v,this,'JPSpan_Object');
					}

					// Strip space for IE
					var cname = match[1].replace(/\s/,'');

					// Has the user registers a callback for serializing this class?
					if ( this.typeMap[cname] ) {
					  return this.typeMap[cname](v, this, cname);

					} else {
					  // Check for error objects
					  var match = cname.match(/Error/);

					  if ( match == null ) {
      					return this.Encoder.encodeAssocArray(v,this);		//bfoz May 7, 2005
					  } else {
      					return this.Encoder.encodeError(v,this,'JPSpan_Error');
					  }

					}					
				}
				else
				{
					// Return null if constructor is null
					return this.Encoder.encodeNull();
				}
			break;

   		//-------------------------------------------------------------------
   		case 'string':
      		 return this.Encoder.encodeString(v);
   		break;

   		//-------------------------------------------------------------------
   		case 'number':
      		 if (Math.round(v) == v) {
         		  return this.Encoder.encodeInteger(v);
      		 } else {
         		  return this.Encoder.encodeDouble(v);
      		 };
   		break;

   		//-------------------------------------------------------------------
   		case 'boolean':
      		 if (v == true) {
         		  return this.Encoder.encodeTrue();
      		 } else {
         		  return this.Encoder.encodeFalse();
      		 };
   		break;

   		//-------------------------------------------------------------------
   		default:
      		 return this.Encoder.encodeNull();
   		break;
		}
	}
}

// $Id: data.js,v 1.2 2004/11/12 22:27:23 harryf Exp $
function JPSpan_Util_Data() {
    this.Serialize = new JPSpan_Serialize(this);
    this.indent = '';
};

JPSpan_Util_Data.prototype = {
    dump: function(data) {
        return this.Serialize.serialize(data);
    },
    
    encodeInteger: function(v) {
        return 'Integer: '+v+"\n";
    },
    
    encodeDouble: function(v) {
        return 'Double: '+v+"\n";
    },
    
    encodeString: function(v) {
        return "String("+v.length+"): "+v+"\n";
    },
    
    encodeNull: function() {
        return "Null\n";
    },
    
    encodeTrue: function() {
        return "Boolean(true)\n"
    },
    
    encodeFalse: function() {
        return "Boolean(false)\n"
    },
    
    encodeArray: function(v, Serializer) {
        var a=v;
        var indexed = new Array();
        var out="Array("+a.length+")\n";
        this.indent += "  ";
        if ( a.length>0 ) {
            for (var i=0; i < a.length; i++) {
                indexed[i] = true;
                out+=this.indent+"["+i+"]";
                if ( (a[i]+'') == 'undefined') {
                    out+= " = undefined\n";
                    continue;
                };
                out+= " = "+Serializer.serialize(a[i])+"\n";
            };
        };
        var assoc='';
        for ( var prop in a ) {
            if ( indexed[prop] ) {
                continue;
            };
            assoc+=this.indent+"[\""+prop+"\"]";
            if ( (a[prop]+'') == 'undefined') {
                assoc+= " = undefined\n";
                continue;
            };
            assoc+= " = "+Serializer.serialize(a[prop])+"\n";
        };
        if ( assoc.length > 0 ) {
            out += assoc;
        };
        this.indent = this.indent.substr(0,this.indent.length-2);
        return out;
    },
    
    encodeObject: function(v, Serializer, cname) {
        var o=v;
        if (o==null) return "Null\n";
        var out="Object("+cname+")\n";
        this.indent += "  ";
        for (var prop in o) {
            out+=this.indent+"."+prop+" = ";
            if (o[prop]==null) {
                out+="null\n";
                continue;
            };
            out+=Serializer.serialize(o[prop])+"\n";
        };
        this.indent = this.indent.substr(0,this.indent.length-2);
        return out;
    },
    
    encodeError: function(v, Serializer, cname) {
        var e = new Object();
        if ( !v.name ) {
            e.name = cname;
            e.message = v.description;
        } else {
            e.name = v.name;
            e.message = v.message;
        };
        return this.encodeObject(e,Serializer,cname);
    }
};


function var_dump(data) {
    var Data = new JPSpan_Util_Data();
    return Data.dump(data);
}

function echo(d, s) {
    document.getElementById("JSdiv").innerHTML +=
        "<hr><h2>Var_dump</h2><pre>"+var_dump(d)+"</pre><h2>Serialized</h2>"+s;
}


function serialize(data) {
    var Encoder = new JPSpan_Encode_PHP();
    return Encoder.encode(data);
}
