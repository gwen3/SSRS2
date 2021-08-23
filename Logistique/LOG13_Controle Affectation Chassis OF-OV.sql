-----------------------------------------------
-- LOG13 - Controle Affectation Chassis OF-OV
-----------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

if (@diff = 1)
(select ofab.t_pdno as OrdreFabrication, 
left(ofab.t_mitm, 9) as Projet, 
substring(ofab.t_mitm, 10, len(ofab.t_mitm)) as Article, 
art.t_dsca as DescriptionArticleFabrique, 
ofab.t_prdt as DateDebutFabrication, 
ofab.t_pldt as DateLivraisonPlanifiee, 
ofab.t_orno as CommandeClientOF, 
ofab.t_pono as PositionCommandeClientOF, 
tqc.t_mser as NumeroChassisOF, 
dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOF, 
lcde.t_serl as NumeroChassisOV, 
dbo.convertenum('td','B61C','a9','bull','sls.hdst',cde.t_hdst,'4') as StatutOV, 
lcde.t_ddta as DateProductionGruau, 
cde.t_crep as RepresentantInterne, 
empr.t_nama as NomRepresentantInterne, 
ofab.t_plid as Planificateur, 
empp.t_nama as NomPlanificateur
from ttisfc001500 ofab --Ordres de Fabrication
inner join ttcibd001500 art on art.t_item = ofab.t_mitm --Articles
left outer join ttimfc010500 tqc on tqc.t_pdno = ofab.t_pdno --En-tête tel que conçu
left outer join ttdsls401500 lcde on lcde.t_orno = ofab.t_orno and lcde.t_pono = ofab.t_pono --Lignes Commandes Clients
left outer join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
left outer join ttccom001500 empr on empr.t_emno = cde.t_crep --Employé - Représentant Interne
left outer join ttccom001500 empp on empp.t_emno = ofab.t_plid --Employé - Planificateur
where left(ofab.t_pdno, 2) between @ue_f and @ue_t --On récupère l'UE sur le numéro d'OF
and ofab.t_pdno between @of_f and @of_t --Bornage sur le numéro d'OF
and ofab.t_orno between @ov_f and @ov_t --Bornage sur le numéro d'OV
and ofab.t_osta between @stat_f and @stat_t --Bornage sur le Statut
and ofab.t_pldt between @date_f and @date_t --Bornage sur la Date de Livraison Planifiée
and art.t_seri = 1 --On ne prend que les articles qui sont sérialisés
and left(ofab.t_mitm, 9) != '' --Rajout le 24/10/2017 pour ne pas ramener les kits en enlevant les projets vides
and isnull(lcde.t_serl, '') <> isnull(tqc.t_mser, '') --On ne récupère que les différences en enlevant les enregistrements qui n'existent pas avec isnull
) 
else 
(select ofab.t_pdno as OrdreFabrication, 
left(ofab.t_mitm, 9) as Projet, 
substring(ofab.t_mitm, 10, len(ofab.t_mitm)) as Article, 
art.t_dsca as DescriptionArticleFabrique, 
ofab.t_prdt as DateDebutFabrication, 
ofab.t_pldt as DateLivraisonPlanifiee, 
ofab.t_orno as CommandeClientOF, 
ofab.t_pono as PositionCommandeClientOF, 
tqc.t_mser as NumeroChassisOF, 
dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOF, 
lcde.t_serl as NumeroChassisOV, 
dbo.convertenum('td','B61C','a9','bull','sls.hdst',cde.t_hdst,'4') as StatutOV, 
lcde.t_ddta as DateProductionGruau, 
cde.t_crep as RepresentantInterne, 
empr.t_nama as NomRepresentantInterne, 
ofab.t_plid as Planificateur, 
empp.t_nama as NomPlanificateur
from ttisfc001500 ofab --Ordres de Fabrication
inner join ttcibd001500 art on art.t_item = ofab.t_mitm --Articles
left outer join ttimfc010500 tqc on tqc.t_pdno = ofab.t_pdno --En-tête tel que conçu
left outer join ttdsls401500 lcde on lcde.t_orno = ofab.t_orno and lcde.t_pono = ofab.t_pono --Lignes Commandes Clients
left outer join ttdsls400500 cde on cde.t_orno = lcde.t_orno --Commandes Clients
left outer join ttccom001500 empr on empr.t_emno = cde.t_crep --Employé - Représentant Interne
left outer join ttccom001500 empp on empp.t_emno = ofab.t_plid --Employé - Planificateur
where left(ofab.t_pdno, 2) between @ue_f and @ue_t --On récupère l'UE sur le numéro d'OF
and ofab.t_pdno between @of_f and @of_t --Bornage sur le numéro d'OF
and ofab.t_orno between @ov_f and @ov_t --Bornage sur le numéro d'OV
and ofab.t_osta between @stat_f and @stat_t --Bornage sur le Statut
and ofab.t_pldt between @date_f and @date_t --Bornage sur la Date de Livraison Planifiée
and art.t_seri = 1 --On ne prend que les articles qui sont sérialisés
)