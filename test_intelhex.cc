/*	Filename: test_intelhex.cc
 *	Test the functionality of the intelhex module
 *	Created	20020901	Brandon Fosdick
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