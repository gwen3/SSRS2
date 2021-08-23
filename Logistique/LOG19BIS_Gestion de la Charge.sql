---------------------------------
-- LOG19 - Gestion de la Charge
---------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--Demande de Ludovic Chardon le 17/07/2017 pour ramener en plus la charge prévisionnel
(select 'Ferme' as Source, 
opt.t_cwoc as CentreCharge, 
rou.t_dsca as DescriptionCentreCharge, 
opt.t_mcho as HeuresMachines, 
year(opt.t_trno) as AnneeFabrication, 
datepart(isowk,opt.t_trno) as SemaineFabrication, 
opt.t_prdt as DateDebutPreparationExecution, 
opt.t_trno as DateFinPreparationExecution, --Champ Transport A (Opération Suivante)
opt.t_pdno as OrdreFabrication, 
opt.t_opno as OperationOF, 
opt.t_tano as Tache, 
tac.t_dsca as DescriptionTache, 
opt.t_opst as CodeStatutOperation, 
dbo.convertenum('ti','B61C','a9','bull','sfc.opst',opt.t_opst,'4') as StatutOperation, 
left(ofab.t_mitm, 9) as Projet, 
substring(ofab.t_mitm, 10, len(ofab.t_mitm)) as Article, 
art.t_dsca as DescriptionArticle, 
ofab.t_plid as Planificateur, 
emp.t_nama as NomPlanificateur, 
emp.t_namd as FamillePlanificateur, 
ofab.t_prcd as Priorite, 
opt.t_mcno as Machine, 
--rajout par rbesnier le 23/10/2017 suite à la demande de Terence
--opt.t_maho as HeureMainOeuvreAllouees, 
--opt.t_sptm as HeureMainOeuvrePassees, 
--rajout par rbesnier le 02/11/2017 suite à la demande de Terence
opt.t_prtm as HeureMainOeuvreAllouees, 
opt.t_sptm as HeureMainOeuvrePassees, 
--rajout par rbesnier le 25/10/2017 suite aux erreurs remarquées par Louis Renie
--(opt.t_maho - opt.t_sptm) as TempsRestant, 
opt.t_retm as TempsRestant, 
(case
when opt.t_qplo != 0
	then ((opt.t_prtm/opt.t_qplo) * (opt.t_qplo - opt.t_qcmp)) 
else 0
end) as TempsRestantCalcule, 
--(select sum(uti.t_qpln) from ttisfc011500 uti where uti.t_pdno = opt.t_pdno and uti.t_opno = opt.t_opno and uti.t_prdt = opt.t_prdt) as QuantitePlanifiee, 
opt.t_qplo as QuantitePlanifiee, 
ofab.t_grid as GroupeOrdreSFC, 
opt.t_sutm as TempsPreparationMoyen, 
ofab.t_qdlv as QuantiteLivree, 
--((select sum(uti.t_qpln) from ttisfc011500 uti where uti.t_pdno = opt.t_pdno and uti.t_opno = opt.t_opno and uti.t_prdt = opt.t_prdt) - ofab.t_qdlv) as QuantiteResteALivrer, 
(opt.t_qplo - opt.t_qcmp) as QuantiteResteALivrer, 
--rajout par rbesnier le 23/10/2017 suite aux demandes de Louis Renié
opt.t_qcmp as QuantiteCumuleeAchevee, 
opt.t_qrjc as QuantiteCumuleeRejetee, 
art.t_ctyp as TypeProduit, 
(case 
when opt.t_prdt < getdate() 
	then 'OUI' 
else 'NON' 
end) as RetardDateDebutPreparation, 
(case 
when opt.t_trno < getdate() 
	then 'OUI' 
else 'NON' 
end) as RetardDateFinPreparation, 
ofab.t_rdld as DateLivraisonRequise, 
ofab.t_pldt as DateLivraisonPlanifiee, 
--Ajout par rbesnier le 07/12/2017
dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOF, 
(case 
when ofab.t_rdld < getdate() 
	then 'OUI' 
else 'NON' 
end) as RetardDateLivraisonRequise, 
ofab.t_orno as CommandeClient, 
ofab.t_pono as PositionCommandeClient, 
lcde.t_sqnb as SequenceCommandeClient, 
lcde.t_ofbp as TiersAcheteur, 
tiers.t_nama as NomTiersAcheteur, 
lcde.t_prdt as DateMADCPrev, 
cde.t_sotp as TypeCommandeClient, 
cde.t_cofc as ServiceVente, 
--rajout par rbesnier le 15/01/2018 suite à demande de Stéphane Emery et Dominique Gerard
ofab.t_prdt as DateDebutOF, 
year(ofab.t_prdt) as AnneeDebutOF, 
datepart(isowk,ofab.t_prdt) as SemaineDebutOF, 
--rajout par rbesnier le 14/09/2018 suite à la demande de Fabrice Chamarre
art.t_dscc as Taille 
from ttisfc010500 opt --Opération des Ordres de Fabrication
inner join ttisfc001500 ofab on ofab.t_pdno = opt.t_pdno --Ordre de Fabrication
left outer join ttcibd001500 art on art.t_item = ofab.t_mitm --Articles
left outer join ttirou001500 rou on rou.t_cwoc = opt.t_cwoc --Centre de Charge
left outer join ttccom001500 emp on emp.t_emno = ofab.t_plid --Employés - Planificateur
left outer join ttirou003500 tac on tac.t_tano = opt.t_tano --Tâches
left outer join ttdsls401500 lcde on lcde.t_orno = ofab.t_orno and lcde.t_pono = ofab.t_pono --Lignes de Commandes Clients
left outer join ttccom100500 tiers on tiers.t_bpid = lcde.t_ofbp --Tiers
left outer join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
where opt.t_opst < 7 --On prend tous les OFs qui ne sont pas achevés
and left(opt.t_pdno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Fabrication
--and opt.t_cwoc between @cwoc_f and @cwoc_t --Bornage sur le Centre de Charge
and opt.t_cwoc in (@cwoc) --Bornage sur le Centre de Charge
and opt.t_prdt between @date_f and @date_t --Bornage sur la Date Début de Préparation Exécution
)union all 
(select 'Prévisionnel' as Source, 
capa.t_cwoc as CentreCharge, 
rou.t_dsca as DescriptionCentreCharge, 
capa.t_mccs as HeuresMachines, 
year(capa.t_trno) as AnneeFabrication, 
datepart(isowk,capa.t_trno) as SemaineFabrication, 
capa.t_prdt as DateDebutPreparationExecution, 
capa.t_trno as DateFinPreparationExecution, --Champ Transport A (Opération Suivante)
capa.t_orno as OrdreFabrication, 
capa.t_opno as OperationOF, 
opt.t_tano as Tache, 
tac.t_dsca as DescriptionTache, 
'' as CodeStatutOperation, 
'A planifier' as StatutOperation, 
left(capa.t_item, 9) as Projet, 
substring(capa.t_item, 10, len(capa.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
oplan.t_cplb as Planificateur, 
emp.t_nama as NomPlanificateur, 
emp.t_namd as FamillePlanificateur, 
'999' as Priorite, 
capa.t_mcno as Machine, 
--rajout par rbesnier le 23/10/2017 suite à la demande de Terence
(capa.t_macs + capa.t_macp) as HeureMainOeuvreAllouees, 
'0' as HeureMainOeuvrePassees, 
(capa.t_macs + capa.t_macp) as TempsRestant, --On est dans le prévisionnel donc le temps restant est le temps prévu
(capa.t_macs + capa.t_macp) as TempsRestantCalcule,
capa.t_qpli as QuantitePlanifiee, 
'' as GroupeOrdreSFC, 
capa.t_sutm as TempsPreparationMoyen, 
'0' as QuantiteLivree, 
capa.t_qpli as QuantiteResteALivrer, 
--rajout par rbesnier le 23/10/2017 suite aux demandes de Louis Renié
'' as QuantiteCumuleeAchevee, 
'' as QuantiteCumuleeRejetee, 
art.t_ctyp as TypeProduit, 
(case 
when capa.t_prdt < getdate() 
	then 'OUI' 
else 'NON' 
end) as RetardDateDebutPreparation, 
(case 
when capa.t_trno < getdate() 
	then 'OUI' 
else 'NON' 
end) as RetardDateFinPreparation, 
'' as DateLivraisonRequise, 
'' as DateLivraisonPlanifiee, 
--Ajout par rbesnier le 07/12/2017
'' as StatutOF, 
'' as RetardDateLivraisonRequise, 
'' as CommandeClient, 
'' as PositionCommandeClient, 
'' as SequenceCommandeClient, 
'' as TiersAcheteur, 
'' as NomTiersAcheteur, 
'' as DateMADCPrev, 
'' as TypeCommandeClient, 
'' as ServiceVente, 
--rajout par rbesnier le 15/01/2018 suite à demande de Stéphane Emery et Dominique Gerard
oplan.t_psdt as DateDebutOF, 
year(oplan.t_psdt) as AnneeDebutOF, 
datepart(isowk,oplan.t_psdt) as SemaineDebutOF, 
--rajout par rbesnier le 14/09/2018 suite à la demande de Fabrice Chamarre
art.t_dscc as Taille 
from tcprrp200500 capa --Utilisation des capacités planifiées par ordre
inner join tcprrp100500 oplan on oplan.t_orno = capa.t_orno and oplan.t_plnc = capa.t_plnc and oplan.t_type = capa.t_koor --Ordre Planifiés
left outer join ttcibd001500 art on art.t_item = capa.t_item --Articles
left outer join ttirou001500 rou on rou.t_cwoc = capa.t_cwoc --Centre de Charge
left outer join ttccom001500 emp on emp.t_emno = oplan.t_cplb --Employés - Planificateur
left outer join ttisfc010500 opt on opt.t_pdno = capa.t_orno and opt.t_opno = capa.t_opno --Opérations des Ordres de Fabrication
left outer join ttirou003500 tac on tac.t_tano = opt.t_tano --Tâches
where left(capa.t_cwoc, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Fabrication
--and capa.t_cwoc between @cwoc_f and @cwoc_t --Bornage sur le Centre de Charge
and capa.t_cwoc in (@cwoc) --Bornage sur le Centre de Charge
and capa.t_prdt between @date_f and @date_t --Bornage sur la Date Début de Préparation Exécution
) order by Source, CentreCharge, DateDebutPreparationExecution --On tri par Centre de Charge et par date de début, du plus vieux au plus récent