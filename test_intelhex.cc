/*	Filename: test_intelhex.cc
 *	Test the functionality of the intelhex module

	Copyright (c) 2002, Terran Development Corporation
	All rights reserved.
	This code is made available to the public under a BSD-like license, a copy of which
	should have been provided with this code in the file LICENSE. For a copy of the BSD 
	license template please visit http://www.opensource.org/licenses/bsd-license.php

 *	*/

#include "intelhex.h"

int main(int argc, char *argv[])
{
	intelhex::hex_data	hexd;
	if(argc<3)
	{
		cout << argv[0] << " <input_file> <output_file>\n";
		exit(0);
	}
	hexd.load(argv[1]);
	hexd.write(argv[2]);
//	hexd.write(cout);
//	cout << endl << argv[0] << " finished \n";
	exit(0);
}