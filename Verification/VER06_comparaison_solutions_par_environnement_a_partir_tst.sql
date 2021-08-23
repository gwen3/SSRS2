------------------------------------------------------------------------
-- VER06 - Comparaison Solutions par Environnement à partir de la Test
------------------------------------------------------------------------
-- 03/01/2019 passage sur base VRC plutôt qu'update VRC, le champ ucus étant vide pour les tools en update VRC
-- 09/01/2019 ajout de ibr pour les solutions standard IWM
-- 20/06/2019 passage de TST0 à EDBTST0
-- 08/11/2019 ajout de cust dans le résultat et l'agrégation
-- 19/08/2020 ajout du tri via cust avant csol

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

declare @date date = DATEADD(DD, -300, CAST(CURRENT_TIMESTAMP AS DATE));
declare @Status varchar(10) = 5;
declare @VRC1 varchar(20) = 'bull'; -- bull
declare @VRC2 varchar(20) = '--'; -- standard '' pour lister les solutions standards
declare @VRC3 varchar(20) = 'tt'; -- tools
declare @VRC4 varchar(20) = 'ext'; -- extensions
declare @VRC5 varchar(20) = 'grup'; -- infor
declare @VRC6 varchar(20) = 'ibr'; -- standard IWM
-- declare @VRC6 varchar(20) = 'ta'; -- tools ta

select
top 10000
tttpmc100000_EDBTST0.t_desc,
tttpmc100000_EDBTST0.t_txtn,
convert(char(10),max(tttpmc260000_EDBTST0.t_date),103),
tttpmc201000_EDBTST0.t_csol,
tttpmc201000_PRE0.t_rsta,
tttpmc201000_PRD.t_rsta,
tttpmc201000_EDBTST0.t_ucus,
tttpmc201000_EDBTST0.t_cust
-- tests
-- ,tttpmc201000_EDBTST0.t_rsta
from
      EDBTST0.ln6fp9db.dbo.tttpmc201000 tttpmc201000_EDBTST0 -- Solutions and Patches by Update VRC environnement de test
		  left join EDBTST0.ln6fp9db.dbo.tttpmc260000 tttpmc260000_EDBTST0 -- Solution History
			on tttpmc201000_EDBTST0.t_csol = tttpmc260000_EDBTST0.t_csol -- solution
			and tttpmc201000_EDBTST0.t_rsta = tttpmc260000_EDBTST0.t_rsta -- statut
			and tttpmc260000_EDBTST0.t_cpac = '' -- pas de composant indiqué dans l'historique pour la solution elle-même
		  left join EDBTST0.ln6fp9db.dbo.tttpmc100000 tttpmc100000_EDBTST0 -- Solutions and Patches
			on tttpmc201000_EDBTST0.t_csol = tttpmc100000_EDBTST0.t_csol -- solution
	  left join PRE0.ln6db.dbo.tttpmc201000 tttpmc201000_PRE0 -- Solutions and Patches by Update VRC environnement de pre-prod
		on tttpmc201000_EDBTST0.t_csol = tttpmc201000_PRE0.t_csol
	  left join PRD.ln6prddb.dbo.tttpmc201000 tttpmc201000_PRD -- Solutions and Patches by Update VRC environnement de prod
		on tttpmc201000_EDBTST0.t_csol = tttpmc201000_PRD.t_csol
where
       tttpmc201000_EDBTST0.t_cust in (@VRC1,@VRC2,@VRC3,@VRC4,@VRC5,@VRC6) AND
       -- tttpmc260000_EDBTST0.t_ucus=@VRC AND
       /*s.t_csol=t.t_csol  and
       s.t_rsta=t.t_rsta  and*/
--	   tttpmc260000_EDBTST0.t_date>@date and
	   tttpmc201000_EDBTST0.t_rsta=@Status and
 	   (tttpmc201000_PRD.t_rsta <> 5 or tttpmc201000_PRD.t_rsta is NULL
	   or
	   tttpmc201000_PRE0.t_rsta <> 5 or tttpmc201000_PRE0.t_rsta is NULL
	   )
-- tests
-- and tttpmc201000_PRE0.t_rsta=5
-- order by tttpmc201000_EDBTST0.t_csol
group by tttpmc100000_EDBTST0.t_desc,
tttpmc100000_EDBTST0.t_txtn,
tttpmc201000_EDBTST0.t_csol,
tttpmc201000_PRE0.t_rsta,
tttpmc201000_PRD.t_rsta,
tttpmc201000_EDBTST0.t_ucus,
tttpmc201000_EDBTST0.t_cust
-- tests
-- ,tttpmc201000_EDBTST0.t_rsta
-- order by max(tttpmc260000_EDBTST0.t_date) desc
order by tttpmc201000_EDBTST0.t_cust,max(tttpmc260000_EDBTST0.t_csol) desc