With
GNAT.Spitbol,
Corel.WordPerfect,
Corel.Types,
Corel.Types.Functions;

--  FROM: http://support.microsoft.com/kb/104140
--
--     interface IUnknown {
--         virtual HRESULT QueryInterface( REFIID, VOID FAR *) = 0;
--         virtual ULONG   AddRef() = 0;
--         virtual ULONG   Release() = 0;
--     };
--
--  SEE ALSO:	http://msdn.microsoft.com/en-us/library/ms890810.aspx
--		http://support.microsoft.com/kb/186898
--

Procedure WP_Test is
    C : Corel.Types.Color:= (others => <>);
begin
    null;
end WP_Test;
