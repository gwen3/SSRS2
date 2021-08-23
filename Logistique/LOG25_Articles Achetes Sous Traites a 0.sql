----------------------------------------------
-- LOG25 - Articles Achetés Sous Traités à 0
----------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select lcde.t_orno as CommandeFournisseur,
lcde.t_pono as LigneCommandeFournisseur,
--lcde.t_sqnb as SequenceCommandeFournisseur,
left(lcde.t_item, 9) as ProjetArticle,
substring(lcde.t_item, 10, len(lcde.t_item)) as Article,
art.t_dsca as DescriptionArticle,
lcde.t_cwar as Magasin,
appro.t_msqn as SequenceMatiere,
left(appro.t_item, 9) as ProjetArticleMatiere,
substring(appro.t_item, 10, len(appro.t_item)) as ArticleMatiere,
artmat.t_dsca as DescriptionArticleMatiere,
appro.t_stwh as MagasinApproA,
(case
	when exists(select lcf.t_qoor from ttdpur401500 lcf where lcf.t_orno = lcde.t_orno and lcf.t_pono = lcde.t_pono and lcf.t_oltp = '1')
		then (select lcf.t_qoor from ttdpur401500 lcf where lcf.t_orno = lcde.t_orno and lcf.t_pono = lcde.t_pono and lcf.t_oltp = '1') 
		else (select lcf.t_qoor from ttdpur401500 lcf where lcf.t_orno = lcde.t_orno and lcf.t_pono = lcde.t_pono and lcf.t_oltp = '4')
end) as Qte_Totale_Cdee,
--
(case
	when exists(select lc.t_qidl from ttdpur401500 lc where lc.t_orno = lcde.t_orno and lc.t_pono = lcde.t_pono and lc.t_oltp = '1')
		then (select lc.t_qidl from ttdpur401500 lc where lc.t_orno = lcde.t_orno and lc.t_pono = lcde.t_pono and lc.t_oltp = '1') 
		else (select lcf.t_qidl from ttdpur401500 lcf where lcf.t_orno = lcde.t_orno and lcf.t_pono = lcde.t_pono and lcf.t_oltp = '4')
end) as Qte_Totale_Recue,

--
(select sum(la.t_qirq) from ttdpur416500 la where la.t_orno = lcde.t_orno and la.t_pono = lcde.t_pono and la.t_msqn = appro.t_msqn) as QuantiteTotaleDemandee,
--
--
(round((sum(appro.t_qirq) / (case
		when exists(select lcf.t_qoor from ttdpur401500 lcf where lcf.t_orno = lcde.t_orno and lcf.t_pono = lcde.t_pono and lcf.t_oltp = '1')
			then (select lcf.t_qoor from ttdpur401500 lcf where lcf.t_orno = lcde.t_orno and lcf.t_pono = lcde.t_pono and lcf.t_oltp = '1') 
			else (select lcf.t_qoor from ttdpur401500 lcf where lcf.t_orno = lcde.t_orno and lcf.t_pono = lcde.t_pono and lcf.t_oltp = '4')
		end)) * (case
		when exists(select lc.t_qidl from ttdpur401500 lc where lc.t_orno = lcde.t_orno and lc.t_pono = lcde.t_pono and lc.t_oltp = '1')
			then (select lc.t_qidl from ttdpur401500 lc where lc.t_orno = lcde.t_orno and lc.t_pono = lcde.t_pono and lc.t_oltp = '1') 
			else (select lcf.t_qidl from ttdpur401500 lcf where lcf.t_orno = lcde.t_orno and lcf.t_pono = lcde.t_pono and lcf.t_oltp = '4')
		end),4,0)) as QuantiteDemandee,
--
sum(appro.t_qssu) as QuantiteApprovisionnement,
sum(appro.t_qics) as QuantiteConsommee,
(select top 1 rec.t_ddte from ttdpur406500 rec where rec.t_orno = lcde.t_orno and rec.t_pono = lcde.t_pono and rec.t_ddte between @daterec_f and @daterec_t
	order by rec.t_ddte desc) as DateDerniereReception
from ttdpur401500 lcde --Commandes Fournisseurs
inner join ttcibd001500 art on art.t_item = lcde.t_item --Articles
inner join ttdpur416500 appro on appro.t_orno = lcde.t_orno and appro.t_pono = lcde.t_pono and appro.t_sqnb = lcde.t_sqnb --Lignes d'Approvisionnement en Matières de Commandes
inner join ttcibd001500 artmat on artmat.t_item = appro.t_item --Articles - Matières
where 
left(lcde.t_orno, 2) between @ue_f and @ue_t --Bornage sur les Commandes Fournisseurs
and exists(select top 1 rec.t_rcno from ttdpur406500 rec where rec.t_orno = lcde.t_orno and rec.t_pono = lcde.t_pono and rec.t_ddte between @daterec_f and @daterec_t) --Réceptions Cdes Fournisseurs
and(case
	when exists(select lcf.t_qoor from ttdpur401500 lcf where lcf.t_orno = lcde.t_orno and lcf.t_pono = lcde.t_pono and lcf.t_oltp = '1')
		then (select lcf.t_qoor from ttdpur401500 lcf where lcf.t_orno = lcde.t_orno and lcf.t_pono = lcde.t_pono and lcf.t_oltp = '1') 
		else (select lcf.t_qoor from ttdpur401500 lcf where lcf.t_orno = lcde.t_orno and lcf.t_pono = lcde.t_pono and lcf.t_oltp = '4')
end) != 0 -- Qté commandée différent de 0
--
group by lcde.t_orno,lcde.t_pono,left(lcde.t_item, 9),substring(lcde.t_item, 10, len(lcde.t_item)),art.t_dsca,lcde.t_cwar,appro.t_msqn,left(appro.t_item, 9),substring(appro.t_item, 10, len(appro.t_item)),artmat.t_dsca,appro.t_stwh
having round((sum(appro.t_qirq) / (case
		when exists(select lcf.t_qoor from ttdpur401500 lcf where lcf.t_orno = lcde.t_orno and lcf.t_pono = lcde.t_pono and lcf.t_oltp = '1')
			then (select lcf.t_qoor from ttdpur401500 lcf where lcf.t_orno = lcde.t_orno and lcf.t_pono = lcde.t_pono and lcf.t_oltp = '1') 
			else (select lcf.t_qoor from ttdpur401500 lcf where lcf.t_orno = lcde.t_orno and lcf.t_pono = lcde.t_pono and lcf.t_oltp = '4')
		end)) * (case
		when exists(select lc.t_qidl from ttdpur401500 lc where lc.t_orno = lcde.t_orno and lc.t_pono = lcde.t_pono and lc.t_oltp = '1')
			then (select lc.t_qidl from ttdpur401500 lc where lc.t_orno = lcde.t_orno and lc.t_pono = lcde.t_pono and lc.t_oltp = '1') 
			else (select lcf.t_qidl from ttdpur401500 lcf where lcf.t_orno = lcde.t_orno and lcf.t_pono = lcde.t_pono and lcf.t_oltp = '4')
		end),4,0) != round(sum(appro.t_qics),4,0)
--
order by CommandeFournisseur, LigneCommandeFournisseur, SequenceMatiere