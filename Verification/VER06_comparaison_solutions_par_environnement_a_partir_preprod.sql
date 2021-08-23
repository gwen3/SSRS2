---------------------------------------------------------------------------
-- VER06 - Comparaison Solutions par Environnement à partir de la PreProd
---------------------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

declare @date date = DATEADD(DD, -30, CAST(CURRENT_TIMESTAMP AS DATE));
declare @Status varchar(10) = 5;
declare @VRC1 varchar(20) = 'bull';
declare @VRC2 varchar(20) = 'stnd';

select
distinct
top 1000
tttpmc100000_PRE0.t_desc,
tttpmc100000_PRE0.t_txtn,
-- convert(char(10),tttpmc260000_PRE0.t_date,103),
tttpmc201000_PRE0.t_csol,
tttpmc201000_PRD.t_csol,
tttpmc201000_TST0.t_csol
from
      PRE0.ln6db.dbo.tttpmc201000 tttpmc201000_PRE0 -- Solutions and Patches by Update VRC environnement de test
		  left join PRE0.ln6db.dbo.tttpmc260000 tttpmc260000_PRE0 -- Solution History
			on tttpmc201000_PRE0.t_csol = tttpmc260000_PRE0.t_csol -- solution
			and tttpmc201000_PRE0.t_rsta = tttpmc260000_PRE0.t_rsta -- statut
			and tttpmc260000_PRE0.t_cpac = '' -- pas de composant indiqué dans l'historique pour la solution elle-même
		  left join PRE0.ln6db.dbo.tttpmc100000 tttpmc100000_PRE0 -- Solutions and Patches
			on tttpmc201000_PRE0.t_csol = tttpmc100000_PRE0.t_csol -- solution
	  left join PRD.ln6prddb.dbo.tttpmc201000 tttpmc201000_PRD -- Solutions and Patches by Update VRC environnement de pre-prod
		on tttpmc201000_PRE0.t_csol = tttpmc201000_PRD.t_csol
	  left join TST0.ln6fp9db.dbo.tttpmc201000 tttpmc201000_TST0 -- Solutions and Patches by Update VRC environnement de prod
		on tttpmc201000_PRE0.t_csol = tttpmc201000_TST0.t_csol
where
       tttpmc201000_PRE0.t_ucus in (@VRC1,@VRC2)
       -- tttpmc260000_PRE0.t_ucus=@VRC AND
--	   tttpmc260000_PRE0.t_date>@date and
	   and tttpmc201000_PRE0.t_rsta=@Status
 	   and
	   (tttpmc201000_TST0.t_csol is NULL
	   or
	   tttpmc201000_PRD.t_csol is NULL
	   )
-- tests
	   -- tttpmc201000_PRE0.t_csol='1686491'
order by tttpmc201000_PRE0.t_csol
