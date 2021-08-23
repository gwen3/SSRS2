---------------------------------------
-- EDI02 - X82Navette - Commandes EDI
---------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select ligprog.t_ofbp as TiersAcheteur, 
ligprog.t_stbp as TiersDestinataire, 
ligprog.t_schn as ProgrammeVente, 
ligprog.t_sctp as TypeProgramme, 
ligprog.t_revn as RevisionProgramme, 
ligprog.t_spon as PositionProgramme, 
ligprog.t_rtyp as CodeTypeBesoin, 
dbo.convertenum('td','B61C','a9','bull','pur.rtyp',ligprog.t_rtyp,'4') as TypeBesoin, 
progven.t_stat as CodeStatut, 
dbo.convertenum('td','B61C','a9','bull','sls.hstat',progven.t_stat,'4') as Statut, 
ligprog.t_stat as CodeStatutLigne, 
dbo.convertenum('td','B61C','a9','bull','sls.stat',ligprog.t_stat,'4') as StatutLigne, 
progven.t_citm as ArticleClient, 
substring(ligprog.t_item, 10, len(ligprog.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
ligprog.t_qrrq as QuantiteCommande, 
stk.t_ordr as StockEnCommande, 
ligprog.t_odat as DateCommande, 
ligprog.t_sdat as DateDebut, 
(case
when ligprog.t_refe = ''
	then ligprog.t_refs 
else ligprog.t_refe 
end) as RAN, --Correspond au champ Reference, mais c'est en fait le RAN
info.t_fd10 as TransportID, 
info.t_fd22 as EDIShipTo, 
info.t_fd05 as Kanban, 
info.t_fd02 as PointConso, 
isnull((select stk.t_qhnd from twhinr140500 stk where stk.t_item = ligprog.t_item and stk.t_cwar = 'LV4103' and stk.t_loca = 'CONTROLE'), 0) as StockPhysiqueEnControle, 
isnull((select sexp.t_qhnd from twhinr140500 sexp where sexp.t_item = ligprog.t_item and sexp.t_cwar = 'LV4103' and sexp.t_loca = 'EXPEDITION'), 0) as StockEnCoursExpedition, 
isnull((select (sum(s.t_qhnd) - isnull((select stk.t_qhnd from twhinr140500 stk where stk.t_item = ligprog.t_item and stk.t_cwar = 'LV4103' and stk.t_loca = 'CONTROLE'), 0) - isnull((select sexp.t_qhnd from twhinr140500 sexp where sexp.t_item = ligprog.t_item and sexp.t_cwar = 'LV4103' and sexp.t_loca = 'EXPEDITION'), 0)) from twhinr140500 s where s.t_item = ligprog.t_item and s.t_cwar = 'LV4103'), 0) as StockDisponible, 
ligprog.t_samt as MontantLigne 
from ttdsls307500 ligprog --Lignes de Programmes de Ventes
left outer join ttcstl210500 info on info.t_adin = ligprog.t_adin --Informations Supplémentaires
left outer join ttdsls311500 progven on progven.t_schn = ligprog.t_schn and progven.t_sctp = ligprog.t_sctp and progven.t_revn = ligprog.t_revn --Programmes de Ventes
left outer join ttcibd001500 art on art.t_item = ligprog.t_item --Articles
left outer join ttcibd100500 stk on stk.t_item = ligprog.t_item --Stock des Articles par Magasin
where ligprog.t_revn = (select top 1 prog1.t_revn from ttdsls307500 prog1 where prog1.t_schn = ligprog.t_schn and prog1.t_sctp = ligprog.t_sctp order by prog1.t_revn desc)
and ligprog.t_sctp between @type_f and @type_t --Bornage sur le Type de Programme
and ligprog.t_ofbp between @tiers_f and @tiers_t --On veut borner par Tiers
and ligprog.t_qrrq != 0 --On ne prend pas les quantités à 0
and ligprog.t_stat != 11 --On enlève le Statut des Lignes Annulé
and progven.t_stat != 4 --On enlève les programmes résiliés
and progven.t_stat != 5 --On enlève les programmes au statut résiliation en cours
order by ligprog.t_sdat, ligprog.t_item --On trie par Date de Debut et par Article