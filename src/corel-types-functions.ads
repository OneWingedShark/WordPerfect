Private With Ada.Streams;


-- Defines the formatting function codes and operators.
Package Corel.Types.Functions with Elaborate_Body is

    Type Bytes is Array(Interfaces.Unsigned_32 Range <>) of Byte;

    -- 16#FF# is reserved.
    SubType WP_Byte is Byte Range 16#00#..16#FE#;

    -- Single-byte functions range from 128 (0x80) through 207 (0xCF).
    SubType Single_Byte_Function is WP_Byte Range 16#80#..16#CF#;

    -- Variable-length multi-byte functions are 208 (0xD0) through 239 (0xEF).
    SubType Variable_Multi_Byte_Function is WP_Byte Range 16#D0#..16#EF#;

    -- Fixed-length multi-byte functions 240 (0xF0) through 255 (0xFF)
    -- However, #FF is reserved so no size is assigned to this value.
    SubType Fixed_Multi_Byte_Function is WP_Byte Range 16#F0#..16#FE#;


    Type Formatting_Function_Code(<>) is private;
    Function Size( Object : Formatting_Function_Code )
		   Return Interfaces.Unsigned_32;
    Function Get_Code(Object : Formatting_Function_Code)
		      Return WP_Byte;
    Function Variable_Length( Object : Formatting_Function_Code )
			      Return Boolean;

    SubType Varible_Length_Code is Formatting_Function_Code
      with Static_Predicate => Variable_Length( Varible_Length_Code );




Private
    Use Ada.Streams;
    Use Type Interfaces.Integer_8, Interfaces.Unsigned_32;

    Function Get_Size( Code : Fixed_Multi_Byte_Function )
		       Return Byte
    with Inline, Pure_Function;

    Function Get_Size( Code	: Variable_Multi_Byte_Function;
		       Subcode	: Byte )
		       Return Byte
    with Inline, Pure_Function;


    -------------------------------------------
    --  Formatting Code Primitive Functions  --
    -------------------------------------------

    Function Create( Code : WP_Byte;
		     Data : Bytes )
		     Return Formatting_Function_Code;

    Procedure Read_Function ( Stream : Not Null Access Root_Stream_Type'Class;
			      Item : out Formatting_Function_Code );
    Procedure Write_Function( Stream : Not Null Access Root_Stream_Type'Class;
			      Item : in  Formatting_Function_Code );

    --    1 = Simple paired function.	Begin/On codes are even subfunctions and End/Off codes are the next subfunction.
    --    2 = Encased/paired function.	Begin/On codes are mod 4=0 subfunctions (multiple-of-4 subfunctions) followed
    --					immediately by Begin/Off, End/On and End/Off codes numbered consecutively.
    --    3 = Encased function.		Begin/On codes are even subfunctions and End/Off codes are the next odd subfunction.
    --    4 = reserved
    --    5 = reserved
    --    6 = revert function off.
    --    7 = revert function on.
    Type Function_Type is (None, Simple_Paired,	Encased_Paired,	Encased,
			   Revert_Off, Revert_On)
      with Size => 3;

    For Function_Type Use
      (
       None		=> 0,
       Simple_Paired	=> 1,
       Encased_Paired	=> 2,
       Encased		=> 3,
       Revert_Off	=> 6,
       Revert_On	=> 7
      );

    Type Function_Flags is record
	Style			: Function_Type;
	Reserved_A,
	Reserved_B,
	Reserved_C,
	Inactive_Function,
	Prefixes_Follow		: Boolean;
    end record
    with Pack, Size => 8;

    -----------------------------------------------------
    --  Full Declaration for Formatting_Function_Code  --
    -----------------------------------------------------

    Type Formatting_Function_Code(Code : WP_Byte;
				  Size : Interfaces.Unsigned_32) is
	record
	    Case Size is
	    When 0 => null;
	    when others =>
		Data : Bytes(1..Size);
		Case Code is
		When Variable_Multi_Byte_Function =>
		    --  subgroup byte,
		    --  a value of size short (16 bits),
		    --  and a function flags byte.
		    Subgroup	: Byte;
		    vSize	: Interfaces.Unsigned_16;
		    Flags	: Function_Flags;
		When Others => Null;
		End Case;
	    end case;
	end record
    with Read => Read_Function, Write => Write_Function,
	 Static_Predicate => Formatting_Function_Code.Data'Length < Interfaces.Unsigned_32'Last;


        Function Variable_Length( Object : Formatting_Function_Code )
				 Return Boolean is
	( Object.Code in Variable_Multi_Byte_Function );


End Corel.Types.Functions;
