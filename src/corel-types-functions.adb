With
Ada.Containers.Vectors;

Package Body Corel.Types.Functions is
	Use Type WP_Byte;

    function Get_Code(Object : Formatting_Function_Code) Return WP_Byte is
      ( Object.Code );

    Function Size( Object : Formatting_Function_Code )
		    Return Interfaces.Unsigned_32 is
      ( if Object.Code in Single_Byte_Function then 1
	 else 2 + Object.Data'Length
      );

    Function Create( Code : WP_Byte;
		     Data : Bytes )
		     Return Formatting_Function_Code is
	subtype Constrained_Code is Formatting_Function_Code
	  ( Code => Code, Size => Data'Length );
    begin
	Return Result : Constrained_Code do
	    if Data'Length > 0 then
		Result.Data:= Data;
	    end if;
	End Return;
    end Create;


    Package Byte_Vector is new Ada.Containers.Vectors(
		Index_Type   => Positive,
		Element_Type => Byte
	);

    Function To_Array( Input : Byte_Vector.Vector ) Return Bytes is
	Use Interfaces, Byte_Vector;
	Length : constant Unsigned_32 := Unsigned_32( Input.Length );
	Subtype Vector_Range is Unsigned_32 Range 1..Length;
    begin
	Return Result : Bytes(Vector_Range) do
	    For Index in Vector_Range loop
		Result(Index) := Input(Positive(Index));
	    end loop;
	End return;
    end To_Array;

    Use Byte_Vector;

    Function Get_Size( Code : Fixed_Multi_Byte_Function ) Return Byte is
	--	Codes for fixed-length multi-byte functions always appear twice.
	--	The first occurrence is the begin gate, and a second occurrence
	--	is the end gate. The length of each function is fixed and listed
	--	after the function code.
	--
	--	EXAMPLE: Extended Character
	--		Size = 4
	--		<240 (0xF0)>
	--		[WP character] = (<character> <WP character set number>)
	--		<240 (0xF0)>

    begin
	Return Result : Byte do
	    Case Code is
	    When 16#F0#				=> Result:= 4;
	    When 16#F1#				=> Result:= 5;
	    When 16#F2# | 16#F3#		=> Result:= 3;
	    When 16#F4# | 16#F5#		=> Result:= 3;
	    When 16#F6# | 16#F7# | 16#F8#	=> Result:= 4;
	    When 16#F9# | 16#FA#		=> Result:= 5;
	    When 16#FB# | 16#FC#		=> Result:= 6;
	    When 16#FD# | 16#FE#		=> Result:= 8;
	    End Case;
	End Return;
    end Get_Size;


    -- A return of Zero indicates a truely variable code-length,
    -- therefore to get the actual size one must resort to other methods.
    -- {This function exists to get the size as early as possible if
    --  generating your own functions in a stream, it can give some prediction.}
    Function Get_Size( Code	: Variable_Multi_Byte_Function;
		       Subcode	: Byte )
		       Return Byte is

	Undocumented_Code,
	Reserved_Subcode,
	Unassigned_Subcode : Exception;

	Subtype Defined_Code_Range is Byte Range 16#D0#..16#E2#;

	SubType Range_D0 is Byte Range 16#00#..16#8D#;
	SubType Range_D1 is Byte Range 16#00#..16#1F#;
	SubType Range_D2 is Byte Range 16#00#..16#03#;
	SubType Range_D3 is Byte Range 16#00#..16#1A#;
	SubType Range_D4 is Byte Range 16#00#..16#67#;
	SubType Range_D5 is Byte Range 16#00#..16#11#;
	SubType Range_D6 is Byte Range 16#00#..16#06#;
	SubType Range_D7 is Byte Range 16#00#..16#03#;
	SubType Range_D8 is Byte Range 16#00#..16#09#;
	SubType Range_D9 is Byte Range 16#00#..16#09#;
	SubType Range_DA is Byte Range 16#00#..16#15#;
	SubType Range_DB is Byte Range 16#00#..16#09#;
	SubType Range_DC is Byte Range 16#00#..16#09#;
	SubType Range_DD is Byte Range 16#00#..16#0B#;
	SubType Range_DE is Byte Range 16#00#..16#95#;
	SubType Range_DF is Byte Range 16#00#..16#03#;
	SubType Range_E0 is Byte Range 16#00#..16#FF#; -- Tabs.
	SubType Range_E1 is Byte Range 16#00#..16#2D#;
	-- E2: platform dependent, formatter specific, and undocumented.
	SubType Range_E2 is Byte Range 16#00#..16#FF#;

    begin
	Return Result : Byte := 0 do
	    if Code Not in Defined_Code_Range then
		Raise Undocumented_Code;
	    end if;

	    Case Defined_Code_Range(Code) is
	    when 16#D0# =>
		case Range_D0(Subcode) is
		When 16#00#..16#1C# | 16#81# => Null;
		When 16#82# | 16#83# | 16#85# => Result:= 4;
		When 16#80# | 16#88# => Result:= 5;
		When 16#87# => Result:= 6;
		When 16#84# => Result:= 9;
		When 16#86# => Result:= 10;
		When 16#89# => Result:= 11;
		When 16#8A# => Raise Reserved_Subcode;
		When 16#8B# | 16#8C# => Result:= 3;
		When 16#8D# => Result:= 1;
		-- 62 unassigned subcodes.
		When 16#1C#+1..16#80#-1 => Raise Unassigned_Subcode;
		end case;
	    when 16#D1# =>
		case Range_D1(Subcode) is
		When 16#00#..16#0D# | 16#10#..16#18# |
		     16#1C# | 16#1D# => Null;
		When 16#19# => Result:= 11;
		When 16#1A# | 16#1B# => Result:= 12;
		When 16#0F# => Result:= 13;
		When 16#1E# | 16#1F# => Result:= 14;
		When 16#0E# => Result:= 22;
		end case;
	    when 16#D2# =>
		case Range_D2(Subcode) is
		When 16#00# .. 16#03# => Null;
		end case;
	    when 16#D3# =>
		case Range_D3(Subcode) is
		When 16#00#..16#08# | 16#0A#..16#12# |
		     16#17#..16#1A# => Null;
		When 16#14# | 16#15# => Result:= 10;
		When 16#13# => Result:= 11;
		When 16#09# => Result:= 12;
		-- Documentation oddity, size is not explicitly said to be
		-- variable for subfunction $16.
		When 16#16# => Null;
		end case;
	    when 16#D4# =>
		case Range_D4(Subcode) is
		When 16#00#..16#0F# | 16#14#..16#16# |
		     16#18#..16#1B# | 16#1D# | 16#1E# |
		     16#20# | 16#22#..16#25# | 16#27# |
		     16#29# | 16#2A# | 16#2E# |
		     16#30#..16#32# | 16#34# |
		     16#38#..16#3B# | 16#44# | 16#46#..16#5E# |
		     16#62#..16#65# => Null;
		When 16#11# | 16#13# | 16#21# | 16#28# |
		     16#2B# | 16#2F# | 16#33# |
		     16#35#..16#37# | 16#3C# | 16#3D# |
		     16#3F#..16#43# | 16#45# | 16#67# => Result:= 10;
		When 16#1F# | 16#2D# | 16#66# => Result:= 11;
		When 16#10# | 16#1C# | 16#26# | 16#3E# => Result:= 12;
		When 16#17# => Result:= 13;
		When 16#60# | 16#61# => Result:= 14;
		When 16#5F# => Result:= 16;
		When 16#12# => Result:= 18;
		-- Documentation oddity, size is listed as 27 or 33, but
		-- nothing indicates how this should be discriminated.
		When 16#2C# => Result:= (if TRUE then 27 else 33);
		end case;
	    when 16#D5# =>
		case Range_D5(Subcode) is
		    -- All $D5 subfunctions are variable.
		When Others => Null;
		end case;
	    when 16#D6# =>
		case Range_D6(Subcode) is
		    -- All $D6 subfunctions are variable.
		When Others => Null;
		end case;
	    when 16#D7# =>
		case Range_D7(Subcode) is
		When 16#00# => Null;
		When 16#01# | 16#03# => Result:= 10;
		When 16#02# => Result:= 13;
		end case;
	    when 16#D8# =>
		case Range_D8(Subcode) is
		    -- All $D8 subfunctions are variable.
		When Others => Null;
		end case;
	    when 16#D9# =>
		case Range_D9(Subcode) is
		    -- All $D9 subfunctions are variable.
		When Others => Null;
		end case;
	    when 16#DA# =>
		-- The subfunctions in this list are paired so that the
		-- even-numbered codes are the On functions and the odd
		-- numbered codes are the Off functions. Each instance of
		-- a subfunction will consist of the On subfunction, the
		-- associated information, and the Off subfunction.
		-- NOTES:
		--	1) The ON-CODEs are variable, the OFF-CODEs fixed.
		--	2) The subtype conversion is kept to ensure that
		--	   no invalid subfunctions are inadvertantly kept.
		Result:= (if Range_DA(Subcode) mod 2 = 1 then 10 else 0);
	    when 16#DB# =>
		case Range_DB(Subcode) is
		    -- All $DB subfunctions are variable.
		When Others => Null;
		end case;
	    when 16#DC# =>
		case Range_DC(Subcode) is
		    -- All $DC subfunctions are variable.
		When Others => Null;
		end case;
	    when 16#DD# =>
		case Range_DD(Subcode) is
		When 16#00#..16#05# | 16#07#..16#0B# => Null;
		When 16#06# => Result:= 12;
		end case;
	    when 16#DE# =>
		case Range_DE(Subcode) is
		When 16#00#..16#20# => Null;
		When 16#30#..16#95# => Result:=
					(if Subcode mod 2 = 1 then 10 else 0);
		When Others => Raise Unassigned_Subcode;
		end case;
	    when 16#DF# =>
		case Range_DF(Subcode) is
		When 16#00#..16#03# => Null;
		end case;
	    when 16#E0# =>
		case Range_E0(Subcode) is
		    -- NOTE: What would be the size-byte is instead the
		    --       tab-definition; this means that we may have
		    --       to move interpretation here.
		When Others => Null;
		end case;
	    when 16#E1# =>
		case Range_E1(Subcode) is
		When 16#02#..16#05# | 16#07# | 16#09# |
		     16#0B# | 16#14#..16#17# | 16#1C#..16#1E# |
		     16#20# | 16#22# | 16#25#..16#2D# => Null;
		When 16#06# | 16#1F# | 16#21# | 16#23# => Result:= 10;
		When 16#0A# | 16#1B# => Result:= 11;
		When 16#10# | 16#11# | 16#1A# | 16#24# => Result:= 12;
		When 16#08# | 16#0C# | 16#0E# | 16#12# |
		     16#18# => Result:= 14;
		When 16#00# | 16#01# => Result:= 17;
		When 16#0D# | 16#0F# | 16#13# | 16#19# => Result:= 18;
		end case;
	    when 16#E2# =>
		case Range_E2(Subcode) is
		    -- All $E2 subfunctions are variable.
		When Others => Null;
		end case;
	    End case;
	Exception
	    When Constraint_Error => Raise Unassigned_Subcode;
	End return;
    end Get_Size;



    Procedure Read_Function ( Stream : Not Null Access Root_Stream_Type'Class;
			      Item   : out Formatting_Function_Code ) is

	Procedure Handle_Closing_Gate( Start_Code : WP_Byte ) with Inline;
	Procedure Handle_Closing_Gate( Start_Code : WP_Byte ) is
	    End_Code : WP_Byte;
	begin
	    WP_Byte'Read( Stream, End_Code );
	    if End_Code /= Start_Code then
		raise Program_Error with "FUNCTIONS DO NOT MATCH";
	    end if;
	end Handle_Closing_Gate;


	Function Create( Code : WP_Byte;
			 Size : Interfaces.Unsigned_32 := 0 )
		     Return Formatting_Function_Code is
	    subtype Constrained_Code is Formatting_Function_Code
	      ( Code => Code, Size => Size );
	begin
	    Return Result : Constrained_Code do
		if Code not in Single_Byte_Function then
		    For Item of Result.Data loop
			WP_Byte'Read( Stream, Item );
		    end loop;

		    Handle_Closing_Gate(code);
		end if;
	    End Return;
	end Create;

	Function_Code : WP_Byte;
	Use Interfaces;
    Begin
	Byte'Read( Stream, Function_Code );
	case Function_Code is
	when Single_Byte_Function =>
	    Item:= Create( Code => Function_Code );
	when Fixed_Multi_Byte_Function =>
	    declare
	    -- Because the open-gate and the close-gate are not part of the
	    -- data carried in the data component of the Formatting_Function
	    -- we reduce the result by two (the size of the gates).
		Size : Unsigned_32:= Unsigned_32( Get_Size(Function_Code)-2 );
	    begin
		Item:= Create( Code => Function_Code, Size => Size );
	    end;
	when Variable_Multi_Byte_Function =>
	    declare
		Data : Byte_Vector.Vector;
		Min,
		Count: Natural := 2; -- 1 for fn, +1 for subcode.
		Subfunction,
		Item : Byte;
	    begin
		Byte'Read( Stream, Subfunction );
		Min:= Natural( Get_Size(
				Code    => Function_Code,
				Subcode => Subfunction
			));
		loop
		    Count:= Count + 1;
		    Byte'Read( Stream, Item );
		    -- Note this causes the closing-gate function-code to NOT
		    -- be added to our vector.
		    exit when Item = Function_Code and Count > min;
		    Data.Append( Item );
		end loop;
		Read_Function.Item:= Create(
			      Code => Function_Code,
			      Data => To_Array( Data )
    		  );
	    end;
	when Others => Raise Program_Error;
	end case;
    End Read_Function;


    Procedure Write_Function ( Stream : Not Null Access Root_Stream_Type'Class;
			       Item   : in Formatting_Function_Code ) is
    Begin
	WP_Byte'Write( Stream, Item.Code );
	if Item.Code not in Single_Byte_Function then
	    for Item of Write_Function.Item.Data loop
		WP_Byte'Write( Stream, Item );
	    end loop;
	    WP_Byte'Write( Stream, Item.code );
	end if;
    End Write_Function;

End Corel.Types.Functions;
