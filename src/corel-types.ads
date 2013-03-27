Private With Ada.Streams;

Package Corel.Types with Pure, Elaborate_Body is
    -- Preelaborate_Body is given to force a body for this package.

    --------------------------
    --  UNSIGNED INTERGERS  --
    --------------------------
    SubType Byte  is Interfaces.Unsigned_8;
    SubType Short is Interfaces.Unsigned_16;
    SubType Long  is Interfaces.Unsigned_32;
    SubType Quad  is Interfaces.Unsigned_64;

    ------------------------
    --  SIGNED INTERGERS  --
    ------------------------

    -- Unknown if needed.



    Type File_Types is
      (
       ---------------------
       --  G E N E R A L  --
       ---------------------
       Macro_File,
       Help_File,
       Keyboard_File,		-- Keyboard definition file
       VAX_Keyboard_File,	-- VAX keyboard definition file added 30 Mar 90.
       -----------------------
       --  S P E C I F I C  --
       -----------------------
       WordPerfect_File,
       Dictionary_File,
       Thesaurus_File,
       Block,
       Rectangular_Block,
       Column_Block,
       PRS_File,		-- Printer Resource File (.PRS)
       Setup_File,		-- System values for WP{WP}.SET (Setup values)
       ALL_File,		-- Printer resource file (.ALL)
       DRS_File,		-- Display resource file (.DRS)
       Overlay_File,		-- Overlay file (WP.FIL)
       WP_Graphics_File,	-- WP graphic file (.WPG)
       Hyphenation_Code_File,	-- Hyphenation code module
       Hyphenation_Data_File,	-- Hyphenation data module
       Macro_Resource_File,	-- Macro resource file (.MRS)
       Graphics_Driver_File,	-- Graphics screen-driver file (.VRS)
       Hyphenation_Lex_Module,	-- Hyphenation lex module
       Printer_Q_File,		-- Printer Q codes (used by VAX/DG)
       Spell_Code_File,		-- Spell code module word list
       Equation_Resource_File,	-- WP.QRS file (WP 5.1 equation resource file)
       VAX_Set_File,		-- VAX.SET
       Spell_Code_Rule_File,	-- Spell code module rules
       Dictionary_Rule_File,	-- Dictionary rules
       WPD_File,
       Rhymer_Word_File,	-- Rhymer word file (Corel TSR product)
       Rhymer_Pronunciation,	-- Rhymer pronunciation file
       WP_51_INS,		-- WP 51.INS file (install options file)
       Mouse_Driver,		-- Mouse driver for WP5.1
       UNIX_Setup,		-- UNIX setup file for WP5.0
       Macintosh_2,		-- Macintosh WP2.0 document
       VAX_File,		-- VAX file (WP4.2 document)
       Ext_Spell_Code,		-- External spell code module (WP5.1 DOS)
       Ext_Spell_Dict,		-- External spell dictionary (WP5.1 DOS)
       SOFT_File,		-- Macintosh SOFT (Sequential Object Format)*
				--	* graphics file for the Macintosh WP.
       Resource_Library		-- Application Resource Library (WPWin 5.1)
      );


    For File_Types Use
      (
       Macro_File		=>  1,
       Help_File		=>  2,
       Keyboard_File		=>  3,
       VAX_Keyboard_File	=>  4,

       WordPerfect_File		=> 16#0A#,
       Dictionary_File		=> 16#0B#,
       Thesaurus_File		=> 16#0C#,
       Block			=> 16#0D#,
       Rectangular_Block	=> 16#0E#,
       Column_Block		=> 16#0F#,
       PRS_File			=> 16#10#,
       Setup_File		=> 16#11#,
       ALL_File			=> 16#13#,
       DRS_File			=> 16#14#,
       Overlay_File		=> 16#15#,
       WP_Graphics_File		=> 16#16#,
       Hyphenation_Code_File	=> 16#17#,
       Hyphenation_Data_File	=> 16#18#,
       Macro_Resource_File	=> 16#19#,
       Graphics_Driver_File	=> 16#1A#,
       Hyphenation_Lex_Module	=> 16#1B#,
       Printer_Q_File		=> 16#1C#,
       Spell_Code_File		=> 16#1D#,
       Equation_Resource_File	=> 16#1E#,
       VAX_Set_File		=> 16#20#,
       Spell_Code_Rule_File	=> 16#21#,
       Dictionary_Rule_File	=> 16#22#,
       WPD_File			=> 16#24#,
       Rhymer_Word_File		=> 16#25#,
       Rhymer_Pronunciation	=> 16#26#,
       WP_51_INS		=> 16#29#,
       Mouse_Driver		=> 16#2A#,
       UNIX_Setup		=> 16#2B#,
       Macintosh_2		=> 16#2C#,
       VAX_File			=> 16#2D#,
       Ext_Spell_Code		=> 16#2E#,
       Ext_Spell_Dict		=> 16#2F#,
       SOFT_File		=> 16#30#,
       Resource_Library		=> 16#38#
      );

    -- Product-specific file types corel uses.
    Subtype Corel_File_Types is File_Types Range
      WordPerfect_File..File_Types'Last;


    -----------------
    --  C O L O R  --
    -----------------

    Type Color_Items is (Red, Green, Blue, Alt);
    Subtype RGB is Color_Items Range Red..Blue;
    Type Color_Values is Array(Color_Items Range <>) of Interfaces.Unsigned_8;


    Type Color is tagged record
	Color_Value : Color_Values(RGB);
    end record;
    Not Overriding Function Get_color( Item : Color ) Return Color_Values;

    Type Shaded_Color is new Color with record
	Shading	: Interfaces.Unsigned_8;
    end record;

    Type Transparent_Color is new Color with record
	Transparency : Interfaces.Unsigned_8;
    end record;

    Function Values( Item : Color'Class ) Return Color_Values;


    ------------------------
    --  Units of Measure  --
    ------------------------

    -- WPU stands for WordPerfect Unit, which is one 1200th of an inch.
    -- Dimensions are usually given in WordPerfect Units.
    Type WPU is delta 1.0/1200.0 range 0.0 .. 32.0 with size => 16;


    -- WPFP stands for WordPerfect Fixed Point Value.
    -- This is an unsigned 16-bit number which representing a fraction
    -- between 0 and 1. 0x8000 is equal to 0.5 and 0xFFFF is treated as 1.0.
    -- It is used to specify a percentage value or a fraction.
    -- It is also used as the fractional part of WPSP.
    Type WPFP is delta 1.0/16#FFFF# range 0.0..1.0 with size => 16;


    -- WPSP is used to specify spacing values.
    -- This denotes a 32-bit value composed of a 16-bit fraction (WPFP) and
    -- a 16-bit integer in that order. The fractional value is always positive.
    -- The associated integer value is signed which allows the values to be
    -- added as though they were one 32-bit value. For example, to code the
    -- number -3.75 the integer would be -4 and the fraction would be +0.25
    -- (0x4000). When the integer and fraction are added, the result is -3.75.
    Type WPSP is record
	Fractional : WPFP;
	Integral   : Interfaces.Integer_16;
    end record with size => 32;

    -- PSU stands for Printer Scalable Unit.
    -- It is in 10,000ths of the point size of the font.
    Type PSU is delta 1.0/10_000.0 range 0.0..4.0 with size => 16;

    -- Font point sizes
    -- These are given in 3600ths of an inch and are denoted as 3600ths.
    Type Font_Point is delta 1.0/3_600.0 range 0.0..16.0 with Size => 16;

--      Type FFC(<>) is tagged private;
--      Function Get_Code( Object : FFC ) Return Interfaces.Unsigned_8
--      with Inline;

--    QuarterInch           300     // .25 * 1200
--    HalfInch              600     // .50 * 1200
--    ThreeQuarterInch      900     // .75 * 1200
Private

    Overriding
    Function Get_color( Item : Shaded_Color ) Return Color_Values is
      ( Item.Color_Value & (Alt => Item.Shading) );

    Overriding
    Function Get_color( Item : Transparent_Color ) Return Color_Values is
      ( Item.Color_Value & (Alt => Item.Transparency) );

    Function Values( Item : Color'Class ) Return Color_Values is
      (Item.Get_color);

    Function Get_color( Item : Color ) Return Color_Values is
      ( Item.Color_Value );

End Corel.Types;
