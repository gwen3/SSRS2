---------------------------------------------
-- EDI01 - Retard et Ecart de Livraison EDI
---------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

(select 'Retard' as Source, 
dbo.convertenum('td','B61C','a9','bull','sls.hstat',progven.t_stat,'4') as StatutProgramme, 
ligprog.t_ofbp as TiersAcheteur, 
ligprog.t_stbp as TiersDestinataire, 
ligprog.t_schn as ProgrammeVente, 
ligprog.t_spon as PositionProgramme, 
ligprog.t_revn as RevisionProgramme, 
ligprog.t_sdat as DateDebut, 
ligprog.t_ddta as DateLivraison, 
substring(ligprog.t_item, 10, len(ligprog.t_item)) as ReferenceGruau, 
art.t_dsca as DescriptionArticle, 
progven.t_citm as ReferenceClient, 
(case
when ligprog.t_refe = ''
	then ligprog.t_refs 
else ligprog.t_refe 
end) as ReferenceExpedition, --Correspond au champ Reference, mais c'est en fait le RAN
info.t_fd05 as Kanban, 
dbo.convertenum('td','B61C','a9','bull','sls.stat',ligprog.t_stat,'4') as StatutLigne, 
ligprog.t_qrrq as QuantiteCommandee, 
ligprog.t_qidl as QuantiteLivree 
from ttdsls307500 ligprog --Lignes de Programmes de Ventes
left outer join ttdsls311500 progven on progven.t_schn = ligprog.t_schn and progven.t_sctp = ligprog.t_sctp and progven.t_revn = ligprog.t_revn --Programmes de Ventes
left outer join ttcstl210500 info on info.t_adin = ligprog.t_adin --Informations Supplémentaires
left outer join ttcibd001500 art on art.t_item = ligprog.t_item --Articles
where ligprog.t_ofbp between @tiers_f and @tiers_t --On veut borner par Tiers
and ligprog.t_sdat between @datedeb_f and @datedeb_t --Bornage sur la Date de Début qui doit être inférieure à la date donnée (par défaut la date du jour)
and ligprog.t_sctp = 2 --Bornage sur le Type de Programme qui doit être un Programme d'Expédition
and ligprog.t_stat <= 4 --On prend les lignes 
and left(ligprog.t_schn, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par le Programme de Vente
and ligprog.t_revn != 0 --On ne prend pas la révision 0
) union all 
(select 'Ecart' as Source, 
dbo.convertenum('td','B61C','a9','bull','sls.hstat',progven.t_stat,'4') as StatutProgramme, 
ligprog.t_ofbp as TiersAcheteur, 
ligprog.t_stbp as TiersDestinataire, 
ligprog.t_schn as ProgrammeVente, 
ligprog.t_spon as PositionProgramme, 
ligprog.t_revn as RevisionProgramme, 
ligprog.t_sdat as DateDebut, 
ligprog.t_ddta as DateLivraison, 
substring(ligprog.t_item, 10, len(ligprog.t_item)) as ReferenceGruau, 
art.t_dsca as DescriptionArticle, 
progven.t_citm as ReferenceClient, 
(case
when ligprog.t_refe = ''
	then ligprog.t_refs 
else ligprog.t_refe 
end) as ReferenceExpedition, --Correspond au champ Reference, mais c'est en fait le RAN
info.t_fd05 as Kanban, 
dbo.convertenum('td','B61C','a9','bull','sls.stat',ligprog.t_stat,'4') as StatutLigne, 
ligprog.t_qrrq as QuantiteCommandee, 
ligprog.t_qidl as QuantiteLivree 
from ttdsls307500 ligprog --Lignes de Programmes de Ventes
left outer join ttdsls311500 progven on progven.t_schn = ligprog.t_schn and progven.t_sctp = ligprog.t_sctp and progven.t_revn = ligprog.t_revn --Programmes de Ventes
left outer join ttcstl210500 info on info.t_adin = ligprog.t_adin --Informations Supplémentaires
left outer join ttcibd001500 art on art.t_item = ligprog.t_item --Articles
where ligprog.t_ofbp between @tiers_f and @tiers_t --On veut borner par Tiers
and ligprog.t_ddta between @dateliv_f and @dateliv_t --Bornage sur la Date de Début qui doit être inférieure à la date donnée (par défaut la date du jour)
and ligprog.t_sctp = 2 --Bornage sur le Type de Programme qui doit être un Programme d'Expédition
and ligprog.t_qrrq <> ligprog.t_qidl --On ne prend que les quantités commandées différentes des quantités livrées
and ligprog.t_stat <= 10 --On prend les lignes de Créées à Traitées
and left(ligprog.t_schn, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par le Programme de Vente
and ligprog.t_revn != 0 --On ne prend pas la révision 0
)