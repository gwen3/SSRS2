--------------------------------------------------
-- VER06 - Solutions Installées en Prod par Date
--------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- 01/06/2018 liste des solutions installées en production dans la semaine
-- 20/06/2019 passage de TST0 à EDBTST0

declare @date date = DATEADD(DD, -240, CAST(CURRENT_TIMESTAMP AS DATE));
declare @Status varchar(10) = 5;
declare @VRC1 varchar(20) = 'bull'; -- bull
declare @VRC2 varchar(20) = ''; -- standard
declare @VRC3 varchar(20) = 'tt'; -- tools
declare @VRC4 varchar(20) = 'ext'; -- extensions
declare @VRC5 varchar(20) = 'grup'; -- infor

select
distinct top 1000
tttpmc100000_PRD.t_desc,
tttpmc100000_PRD.t_txtn,
convert(char(10),tttpmc260000_PRD.t_date,103),
tttpmc201000_PRD.t_csol /*,
tttpmc201000_PRE0.t_csol,(
tttpmc201000_EDBTST0.t_csol*/
from
      PRD.ln6prddb.dbo.tttpmc201000 tttpmc201000_PRD -- Solutions and Patches by Update VRC environnement de test
		  left join PRD.ln6prddb.dbo.tttpmc260000 tttpmc260000_PRD -- Solution History
			on tttpmc201000_PRD.t_csol = tttpmc260000_PRD.t_csol -- solution
			and tttpmc201000_PRD.t_rsta = tttpmc260000_PRD.t_rsta -- statut
			and tttpmc260000_PRD.t_cpac = '' -- pas de composant indiqué dans l'historique pour la solution elle-même
		  left join PRD.ln6prddb.dbo.tttpmc100000 tttpmc100000_PRD -- Solutions and Patches
			on tttpmc201000_PRD.t_csol = tttpmc100000_PRD.t_csol -- solution
	  left join PRE0.ln6db.dbo.tttpmc201000 tttpmc201000_PRE0 -- Solutions and Patches by Update VRC environnement de pre-prod
		on tttpmc201000_PRD.t_csol = tttpmc201000_PRE0.t_csol
	  left join EDBTST0.ln6fp9db.dbo.tttpmc201000 tttpmc201000_EDBTST0 -- Solutions and Patches by Update VRC environnement de prod
		on tttpmc201000_PRD.t_csol = tttpmc201000_EDBTST0.t_csol
where
       tttpmc201000_PRD.t_cust in (@VRC1,@VRC2,@VRC3,@VRC4,@VRC5) AND
       -- tttpmc260000_PRD.t_ucus=@VRC AND
       /*s.t_csol=t.t_csol  and
       s.t_rsta=t.t_rsta  and*/
	   tttpmc260000_PRD.t_date>@date and
	   tttpmc201000_PRD.t_rsta=@Status /*and
 	   (tttpmc201000_EDBTST0.t_csol is NULL
	   or
	   tttpmc201000_PRE0.t_csol is NULL
	   )*/
order by tttpmc201000_PRD.t_csol
