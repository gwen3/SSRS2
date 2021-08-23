-- =============================================
-- Author:		<Bernard REVOL>
-- Create date: <13/04/2021>
-- Description:	<Cette fonction permet de convertir un texte baan en une chaîne de caractères>
--              Pour récuperer les textes de la base de copie
-- Cette fonction est une copie de dbo.textnumtotext
-- =============================================
CREATE FUNCTION [dbo].[textnumtotextCopy] 
(
	-- Add the parameters for the function here
 	@textvalue		INT,
 	@language		NVARCHAR(1)

)
RETURNS nvarchar(max)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @description nvarchar(max);

-- 	select @description = (SELECT ltrim(convert(varchar(240), texte.t_text)) +'###'  as 'data()' 
	select @description = (SELECT ltrim(dbo.temphextostr(convert(varchar(500), texte.t_text,2))) +'###'  as 'data()' 
 	from SRVSQLPRD2.ln6prddb.dbo.ttttxt010500 texte 
 	where texte.t_ctxt = @textvalue 
	and texte.t_clan = @language
	for XML PATH(''))

	IF @description IS NULL RETURN ''

	select @description = REPLACE(@description,'&#x0D;','')	-- Suppression des saut de ligne
	select @description = REPLACE(@description,'### ','')	-- Suppression du blanc qui est ajouté par la concaténation des lignes
	select @description = REPLACE(@description,'###','')
	select @description = REPLACE(@description,'&#x9B','')
	select @description = REPLACE(@description,'&amp;','&')
	select @description = ltrim(@description)
	
	RETURN @description
END