-----------------------------------------------------
-- LOG22A - Analyse Parametres Stock par Emplacement
-- L'article est séparé en deux colonnes : Article-Projet et le code article lui-même
-----------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

/*
declare @art_f nvarchar(9) = ' ';
declare @art_t nvarchar(25) = 'ZZZZZZZZZZZZZZZZZZZ';
declare @date_f date = '01/01/2000';
declare @date_t date = '01/01/2038';
declare @mag_f nvarchar(6) = 'LV4103';
declare @mag_t nvarchar(6) = 'LV4103';
declare @ue_f nvarchar(2) = 'LV';
declare @ue_t nvarchar(2) = 'LV';
*/

select art.t_cwar as Magasin
,left(art.t_item, 9) as Article_Projet
,convert(varchar,substring(art.t_item, 10, len(art.t_item))) as Article 
,artgen.t_dsca as DescriptionArticle
,artgen.t_citg as GroupeArticle
,grpart.t_dsca as DescriptionGroupe
,artgen.t_csig as CodeSignal
,artgen.t_cuni as UniteStock
,(select top 1 emp.t_loca from twhwmd302500 emp where emp.t_cwar = art.t_cwar and emp.t_item = art.t_item order by emp.t_prio, emp.t_loca) as EmplacementFixe
,artgen.t_kitm as CodeTypeArticle
,dbo.convertenum('tc','B61C','a9','bull','kitm',artgen.t_kitm,'4') as TypeArticle
,art.t_supw as MagasinApprovisionnement
,art.t_oqmf as IncrementQuantiteOrdre
,art.t_mioq as QuantiteMinimum
,art.t_maoq as QuantiteMaximum
,art.t_fioq as QuantiteCommandeFixe
,art.t_ecoq as QuantiteCommandeEconomique
,art.t_maxs as StockMaximum
,art.t_reop as SeuilReapprovisionnement
,art.t_sfst as StockSecurite
,art.t_oint as IntervalleOrdre
,art.t_oivu as UniteIntervalleOrdre
,artplan.t_cwar as MagasinArticlePlan
,artplan.t_plid as Plannificateur
,nomemp.t_nama as NomPlannificateur
,artplan.t_plni as ArticlePlan
,magstok.t_ltdt as DateDerniereTransaction
,magstok.t_qcis as SortieCumulee
,magstok.t_qhnd as StockPhysique
,magstok.t_qall as StockReserve
,(magstok.t_qhnd - magstok.t_qall) as StockDisponible
,magstok.t_qord as StockEnCommande
,(magstok.t_qhnd + magstok.t_qord - magstok.t_qall) as StockEconomique
,art.t_sftm as DelaiDeSecurite
,dbo.convertenum('tc','B61C','a9','bull','tope',t_sftu,'4') as UniteDelaiSecurite
,(select sum(sortie.t_acip) from twhinr120500 sortie where sortie.t_item = art.t_item and ((sortie.t_year = year(getdate()) and sortie.t_peri <= month(getdate())) or (sortie.t_year = year(getdate()) - 1 and sortie.t_peri > month(getdate())))) as SortieReelle12DerniersMois
,stkemp.t_loca as Emplacement
,stkemp.t_qhnd as StockPhysiqueEmplacement
,stkemp.t_qblk as StockBloqueEmplacement
,(stkemp.t_qhnd - stkemp.t_qblk) as StockPhysiqueLibre
,pr.t_ecpr_1 as PrixRevientEstime
,(select top 1 (select sum(pmpdet.t_mauc_1) from twhina137500 pmpdet where pmpdet.t_item = art.t_item and pmpdet.t_wvgr = pmp.t_wvgr and pmpdet.t_trdt = pmp.t_trdt and pmpdet.t_seqn = pmp.t_seqn) as PMP from twhina136500 pmp where pmp.t_item = art.t_item and substring(pmp.t_wvgr, 4, len(pmp.t_wvgr)) = concat('V', left(art.t_cwar, 2)) and pmp.t_trdt <= getdate() order by pmp.t_item,pmp.t_trdt desc, pmp.t_seqn desc) as PMP
,stkemp.t_idat as DateStockage
from twhwmd210500 art --Magasins - Données Articles
inner join tcprpd100500 artplan on left(art.t_cwar, 2) = left(artplan.t_cwar, 2) and substring(artplan.t_plni, 4, len(artplan.t_plni)) = art.t_item --Articles Planification
inner join twhwmd215500 magstok on magstok.t_cwar = art.t_cwar and magstok.t_item = art.t_item --Stock des Articles par magasin
left outer join ttccom001500 nomemp on artplan.t_plid = nomemp.t_emno --Employés
inner join ttcibd001500 artgen on art.t_item = artgen.t_item --Articles
inner join ttcmcs023500 grpart on grpart.t_citg = artgen.t_citg
left outer join twhinr140500 stkemp on stkemp.t_cwar = art.t_cwar and stkemp.t_item = art.t_item --Stock par Emplacement
left outer join tticpr007500 pr on pr.t_item = art.t_item --Données Etablissements des Prix de Revients
where stkemp.t_qhnd != 0--On ne prend pas les stocks à 0
and substring(art.t_item, 10, len(art.t_item)) between @art_f and @art_t --Bornage sur le numéro d'article sans code projet
and magstok.t_ltdt between @date_f and @date_t --Bornage sur la date de dernière transaction de stock
and art.t_cwar between @mag_f and @mag_t --Bornage sur le Magasin
and left(art.t_cwar, 2) between @ue_f and @ue_t --Bornage d'UE sur le Magasin
and artgen.t_citg in (@citg)