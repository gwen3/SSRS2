------------------------------------
-- FAB15 - Productivité Temps Réel
------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
/*
declare @ue_f varchar(20) = 'LV';
declare @ue_t varchar(20) = 'LV';
declare @date_f date = '01/05/2020';
declare @date_t date = getdate();
declare @ofab_f varchar(20) = 'LV';
declare @ofab_t varchar(20) = 'LVZ';
declare @cc_f varchar(20) = '';
declare @cc_t varchar(20) = 'zzz';
*/
select opof.t_pdno as OrdreFabrication
,dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOF
,ofab.t_cmdt as DateAchevementOF
,(case 
when ofab.t_cmdt > '01/01/1980'
	then datepart(isowk,ofab.t_cmdt)
else ' '
end) as SemaineDateAchevementOF
,(case
when ofab.t_cmdt > '01/01/1980'
	then month(ofab.t_cmdt)
else ' '
end) as MoisDateAchevementOF
,(case
when ofab.t_cmdt > '01/01/1980'
	then year(ofab.t_cmdt)
else ' '
end) as AnneeDateAchevementOF
,left(ofab.t_mitm, 9) as ProjetArticleOperationOF
,substring(ofab.t_mitm, 10, len(ofab.t_mitm)) as ArticleOF
,art.t_dsca as DescriptionArticleOF
,opof.t_qcmp as QuantiteLivreeParOperation
,ofab.t_qdlv as QuantiteLivreeParOrdreFabrication
,(select min(opof2.t_qcmp) from ttisfc010500 opof2 left outer join ttirou001500 cc2 on cc2.t_cwoc = opof2.t_cwoc where opof2.t_pdno = opof.t_pdno and isnull(cc2.t_mnwc, cc2.t_cwoc) = isnull(cc.t_mnwc, cc.t_cwoc)) as QuantiteMinimumLivreeCoupleCentreChargePrincipalOF
,art.t_cuni as Unite
,ofab.t_cwar as Magasin
,ofab.t_apdt as DateReelleDebutFab
,opof.t_opno as OperationOrdreFabrication
,dbo.convertenum('ti','B61C','a9','bull','sfc.opst',opof.t_opst,'4') as StatutOperation
,opof.t_cmdt as DateAchevementOperationOF
,opof.t_tano as Tache
,tache.t_dsca as DescriptionTache
,concat(opof.t_cwoc, ' - ', cc.t_dsca) as CentreCharge
,(case cc.t_mnwc
when ''
	then concat(opof.t_cwoc, ' - ', cc.t_dsca)
else
	concat(cc.t_mnwc, ' - ', ccp.t_dsca)
end) as CentreChargePrincipal
,opof.t_prtm as TempsFabrication
,opof.t_sptm as TempsPasse
,isnull((select min(tps.t_stdt) from tbptmm120500 tps where tps.t_orno = opof.t_pdno and tps.t_opno = opof.t_opno and opof.t_sptm != 0), '01/01/2038') as DateDemarrageOperation --On fait ensuite une formule sur SSRS
,ofab.t_orno as CommandeClient
,ofab.t_pono as PositionCommandeClient
,cde.t_ofbp as TiersAcheteur
,tiersa.t_nama as NomTiersAcheteur
,concat(art.t_citg, ' - ', grpart.t_dsca) as GroupeArticle
,(case ofab.t_osta
when 9
	then opof.t_sptm
else 0
end) as TempsOFFerme
,(case ofab.t_osta
when 8
	then opof.t_sptm
else 0
end) as TempsOFAcheve
,(case opof.t_opst
when 7
	then opof.t_sptm
else 0
end) as TempsOPAcheve
,cde.t_sotp as TypeCommandeClient
,ofab.t_qrdr as QuantiteOrdreOF
from ttisfc010500 opof --Opérations Ordres de Fabrication
inner join ttisfc001500 ofab on ofab.t_pdno = opof.t_pdno --Ordres de Fabrication
inner join ttcibd001500 art on art.t_item = ofab.t_mitm --Articles
left outer join ttirou003500 tache on tache.t_tano = opof.t_tano --Tâches
left outer join ttirou001500 cc on cc.t_cwoc = opof.t_cwoc --Centre de Charge
left outer join ttirou001500 ccp on ccp.t_cwoc = cc.t_mnwc --Centre de Charge Principal
left outer join ttdsls400500 cde on cde.t_orno = ofab.t_orno --Commandes Clients
left outer join ttccom100500 tiersa on tiersa.t_bpid = cde.t_ofbp --Tiers Acheteur
left outer join ttcmcs023500 grpart on grpart.t_citg = art.t_citg --Groupe Article
where ofab.t_osta in (6, 8, 9) --Bornage sur le Statut de l'OF - Actif, Achevé ou Fermé
and left(ofab.t_pdno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Fabrication
and ofab.t_cwar between @mag_f and @mag_t --Bornage sur le magasin
and ofab.t_pdno between @ofab_f and @ofab_t --Bornage sur l'Ordre de Fabrication
and ofab.t_apdt between @date_f and @date_t --Bornage sur la Date réelle de Début de Fabrication
and opof.t_cwoc between @cc_f and @cc_t --Bornage sur le Centre de Charge
--and isnull(cc.t_mnwc, opof.t_cwoc) between @ccp_f and @ccp_t --Bornage sur le Centre de Charge Principal
--and (case cc.t_mnwc when '' then opof.t_cwoc else cc.t_mnwc end) between @ccp_f and @ccp_t --Bornage sur le Centre de Charge Principal - Solution qui doit être OK mais plus nécessaire, à tester si besoin
and ofab.t_cmdt between @dateop_f and @dateop_t --Bornage sur la Date d'Achèvement de l'OF
and art.t_citg between @grpart_f and @grpart_t --Bornage sur le Groupe Article
order by OrdreFabrication, CentreChargePrincipal, DateDemarrageOperation