With Corel.Types;
Use Corel.Types;

Private With Interfaces;

Package Corel.WordPerfect is

    Type File_Header is private with size => 512 * 8;

Private
    Use Interfaces;


    Type File_Header is record
	Padding_Prefix	: Interfaces.Unsigned_8;
	Signature	: String(1..3);
	Document_Offset	: Interfaces.Unsigned_32;
	--Product		: Product_Type;
	Document_Type	: File_Types;
    end record
    with Type_Invariant =>
			File_Header.Padding_Prefix = 16#FF#
		AND	File_Header.Signature = "WPC";

--  {Pointer to Document Area} 	Long pointer to document area (the absolute offset from the beginning of the file)
--  <Product type> 	Product # (see Product Type Field below) WordPerfect program = 1
--  <File type> 	File type (see WordPerfect File Types below)
--  <Major version> 	Major version of file. WP 8.0 = 2
--  <Minor version> 	Minor version of file. WP 8.0 = 1
--  [Encryption] 	If nonzero, document is encrypted
--  [pointer to index area] 	Offset to the index header (0x200)
--  <reserved> 	Beginning of extended file header = 5
--  <reserved> 	0
--  [reserved] 	0
--  {file size} 	File size, not including pad characters at EOF
--  <extended header> x 488

End Corel.WordPerfect;
