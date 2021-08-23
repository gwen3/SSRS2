-----------------------------
-- Ordres Planifiés
-----------------------------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

(select 'Ordres Planifiés' as TypeEnregistrement
,dbo.convertenum('tc','B61C','a9','bull','koor',oplan.t_type,'4') as TypeOrdre
,oplan.t_orno as Ordre
,'' as LigneOrdre
,dbo.convertenum('cp','B61C','a9','bull','rrp.osta',oplan.t_osta,'4') as StatutOrdre
,substring(oplan.t_item, 4, 9) as Projet
,substring(oplan.t_item, 13, len(oplan.t_item)) as Article
,art.t_dsca as DescriptionArticle
,oplan.t_quan as QuantiteOrdre
,art.t_cuni as UniteStock
,oplan.t_prdt as DateBesoin
,oplan.t_dwar as Magasin
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
from tcprrp100500 oplan --Ordres Planifiés
left outer join ttcibd001500 art on art.t_item = substring(oplan.t_item, 4, len(oplan.t_item)) --Articles
left outer join ttccom001500 empplan on empplan.t_emno = oplan.t_cplb --Employés - Planificateur
where 
left(oplan.t_item, 2) between @ue_f and @ue_t --Bornage sur l'Unité d'Entreprise définie par le cluster
and oplan.t_plnc = '001' --Bornage sur le Scénario
and oplan.t_type = '30' --Bornage sur le Type d'Ordre : Ordre de distribution planifié
and left(oplan.t_supl, 2) not between  @ue_f and @ue_t -- Ordre de distribution autre que le site lui-même
)
union
(
------------------------------------------------------------
--Transactions Planifiées (Transfert magasin (distribution)
------------------------------------------------------------
select 'Transactions Planifiées' as TypeEnregistrement
,dbo.convertenum('tc','B61C','a9','bull','koor',oplan.t_koor,'4') as TypeOrdre
,oplan.t_orno as Ordre
,oplan.t_pono as LigneOrdre
,dbo.convertenum('tc','B61C','a9','bull','kotr',oplan.t_kotr,'4') as StatutOrdre
,left(oplan.t_item, 9) as Projet
,substring(oplan.t_item, 10, len(oplan.t_item)) as Article
,art.t_dsca as DescriptionArticle
,oplan.t_qana as QuantiteOrdre
,art.t_cuni as UniteStock
,oplan.t_date as DateBesoin
,oplan.t_cwar as Magasin
,artplan.t_plid as Plannificateur
,empplan.t_nama as NomPlanificateur
,dbo.convertenum('tc','B61C','a9','bull','koor',trattnv1.t_koor,'4') as TypeOrdreRattache
,trattnv1.t_orno  as OrdreRattache
--
-- Recherche type ordre et ordre rattaché aval si OF ou OF planifié en amont
,(case
when trattnv1.t_koor in (1,4) then 
	(select top 1 dbo.convertenum('tc','B61C','a9','bull','koor',trattnv3.t_koor,'4') from tcprrp041500 trattnv2  left outer join tcprrp040500 rattnv2 on rattnv2.t_strn = trattnv2.t_trns left outer join tcprrp041500 trattnv3 on trattnv3.t_trns = rattnv2.t_dtrn
		where trattnv2.t_koor = trattnv1.t_koor and trattnv2.t_orno = trattnv1.t_orno and trattnv2.t_koor in ('1','4') and trattnv2.t_pono = '00' and trattnv2.t_kotr = '1')
--Par Défaut
else
	''
end) as TypeOrdreRattache2
--
,(case
when trattnv1.t_koor in (1,4) then 
	(select top 1 trattnv3.t_orno from tcprrp041500 trattnv2  left outer join tcprrp040500 rattnv2 on rattnv2.t_strn = trattnv2.t_trns left outer join tcprrp041500 trattnv3 on trattnv3.t_trns = rattnv2.t_dtrn
		where trattnv2.t_koor = trattnv1.t_koor and trattnv2.t_orno = trattnv1.t_orno and trattnv2.t_koor in ('1','4') and trattnv2.t_pono = '00' and trattnv2.t_kotr = '1')
--Par Défaut
else
	''
end) as OrdreRattache2
--
from twhinp100500 oplan -- Transactions planifiées
left outer join ttcibd001500 art on art.t_item = oplan.t_item --Articles
left outer join tcprpd100500 artplan on artplan.t_cwar = oplan.t_cwar and substring(artplan.t_plni, 4, len(artplan.t_plni)) = art.t_item --Articles Planification
left outer join ttccom001500 empplan on empplan.t_emno = artplan.t_plid --Employés - Planificateur
left outer join tcprrp041500 tratt on tratt.t_koor = oplan.t_koor and tratt.t_orno = oplan.t_orno and tratt.t_pono = oplan.t_pono
left outer join tcprrp040500 ratt on ratt.t_strn = tratt.t_trns --and ratt.t_dtrn != '1'
left outer join tcprrp041500 trattnv1 on trattnv1.t_trns = ratt.t_dtrn-- and ratt.t_dtrn != '1'
where 
oplan.t_koor = '60' --Type d'Ordre : Transfert Magasin (distribution)
and oplan.t_kotr = '1' --Type transaction : Reception planifiée
and left(oplan.t_cwar,2) between @ue_f and @ue_t --Bornage sur l'Unité d'Entreprise 
and (tratt.t_kotr = '1' and (ratt.t_dtrn = NULL or ratt.t_dtrn = (select top 1 rr.t_dtrn from tcprrp040500 rr where rr.t_strn = tratt.t_trns order by rr.t_dtrn)) or 
	not exists (select tr.t_trns from tcprrp041500 tr where tr.t_koor = oplan.t_koor and tr.t_orno = oplan.t_orno and tr.t_pono = oplan.t_pono))
)
--order by 1 
