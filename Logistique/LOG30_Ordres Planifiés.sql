-----------------------------
-- LOG30 - Ordres Planifiés
-----------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select dbo.convertenum('tc','B61C','a9','bull','koor',oplan.t_type,'4') as TypeOrdre
,left(oplan.t_item, 3) as Cluster
,substring(oplan.t_item, 4, 9) as Projet
,substring(oplan.t_item, 13, len(oplan.t_item)) as Article
,art.t_dsca as DescriptionArticle
,oplan.t_orno as OrdrePlanifie
,oplan.t_quan as QuantiteOrdre
,art.t_cuni as UniteStock
,oplan.t_psdt as DateDebutPlanifie
,oplan.t_pfdt as DateFinPlanifie
,oplan.t_prdt as DateBesoin
,dbo.convertenum('cp','B61C','a9','bull','rrp.osta',oplan.t_osta,'4') as StatutOrdre
,oplan.t_dwar as Magasin
,mag.t_dsca as DescriptionMagasin
,oplan.t_cplb as Planificateur
,empplan.t_nama as NomPlanificateur
,dbo.convertenum('tc','B61C','a9','bull','koor',oplan.t_peko,'4') as TypeOrdreRattache
,oplan.t_peor as OrdreRattache
,(case oplan.t_peko
when 1
	then 'Commande Client'
else
	(select dbo.convertenum('tc','B61C','a9','bull','koor',oplan2.t_peko,'4') from tcprrp100500 oplan2 where oplan2.t_orno = oplan.t_peor and oplan2.t_type = oplan.t_peko)
end) as TypeOrdreRattache2
,(case oplan.t_peko
when 1
	then (select ofab.t_orno from ttisfc001500 ofab where ofab.t_pdno = oplan.t_peor)
else
	(select oplan2.t_peor from tcprrp100500 oplan2 where oplan2.t_orno = oplan.t_peor and oplan2.t_type = oplan.t_peko)
end) as OrdreRattache2
,oplan.t_plnc as Scenario
from tcprrp100500 oplan --Ordres Planifiés
left outer join ttcibd001500 art on art.t_item = substring(oplan.t_item, 4, len(oplan.t_item)) --Articles
left outer join ttcmcs003500 mag on mag.t_cwar = oplan.t_dwar --Magasin
left outer join ttccom001500 empplan on empplan.t_emno = oplan.t_cplb --Employés - Planificateur
where left(oplan.t_item, 2) between @ue_f and @ue_t --Bornage sur l'Unité d'Entreprise définie par le cluster
and left(oplan.t_item, 3) between @clus_f and @clus_t --Bornage sur le CLUSTER
and oplan.t_plnc between @scenar_f and @scenar_t --Bornage sur le Scénario
and oplan.t_type between @type_f and @type_t --Bornage sur le Type d'Ordre
and substring(oplan.t_item, 13, len(oplan.t_item)) between @art_f and @art_t --Bornage sur l'Article
and oplan.t_cplb between @planif_f and @planif_t --Bornage sur le Planificateur
and oplan.t_prdt <= @datehorizon --Bornage sur l'horizon du besoin (Nombre de jours jusqu'à la date du besoin)