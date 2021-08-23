-------------------------------------------------------------------------
-- MDM13 - Ctrl NCMR 
--(Pilote, propriétaire avec une date départ de la société)
-------------------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select 
 ncmr.t_ncmr as NCMR
,ncmr.t_dsca as Decription_NCMR
,dbo.convertenum('qm','B61C','a9','bull','ncm.stat',ncmr.t_stat,'4') as StatutNcmr
,ncmr.t_rpdt as DateRapport
,ncmr.t_rptr as UtilRapport
,ncmr.t_ownr as Proprietaire
,empp.t_nama as NomProprietaire
,edpp.t_edte as DateDepartProp
,ncmr.t_pilo as PiloteAnalyse
,emppa.t_nama as NomPiloteAnalyse
,edppa.t_edte as DateDepartPilote
from tqmncm100500 ncmr
inner join tbpmdm001500 edpp on edpp.t_emno = ncmr.t_ownr
inner join ttccom001500 empp on empp.t_emno = ncmr.t_ownr
inner join tbpmdm001500 edppa on edppa.t_emno = ncmr.t_pilo
inner join ttccom001500 emppa on emppa.t_emno = ncmr.t_pilo
where
left(ncmr.t_ncmr,2) between @ue_f and @ue_t
and ncmr.t_rpdt between @rpdt_f and @rpdt_t
and ncmr.t_stat <= '4' -- Statut <> Annulé et fermé
and ((edpp.t_edte between '01/01/1970' and getdate() -1)
	 or (edppa.t_edte between '01/01/1970' and getdate() -1))