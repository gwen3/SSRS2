-----------------------------------
-- LOG21 - Analyse Sous Traitance
-----------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

(select 'Commande' as Source, 
lcde.t_orno as NumeroCommandeFabrication, 
lcde.t_pono as PositionCommandeFabrication, 
lcde.t_sqnb as SequenceCommandeFabrication, 
left(lcde.t_item, 9) as ProjetArticle, 
substring(lcde.t_item, 10, len(lcde.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle, 
lcde.t_ddte as DateCommandeDateFabrication, 
lcde.t_qoor as Quantite, 
(select sum(sortien.t_acip) from twhinr120500 sortien where sortien.t_item = lcde.t_item and sortien.t_year = year(getdate())) as SortieReelleAnneeN, 
(select sum(sortien.t_acip) from twhinr120500 sortien where sortien.t_item = lcde.t_item and sortien.t_year = year(dateadd("yyyy", -1, lcde.t_ddte))) as SortieReelleAnneeNmoins1, 
'' as CentreCharge, 
'' as DescriptionCentreCharge, 
'' as TempsPrepaMoyen, 
'' as TempsCycle, 
'' as TempsFabrication, 
achart.t_avpr as PrixAchatMoyenCoutStandard, 
'' as CoutsMatieres, 
'' as CoutsOperatoires, 
art.t_ctyp as TypeProduit 
from ttdpur401500 lcde --Lignes de Commandes Fournisseurs
inner join ttcibd001500 art on art.t_item = lcde.t_item --Articles
left outer join ttdipu100500 achart on achart.t_item = lcde.t_item --Données d'achat
where (art.t_ctyp = 'ST' or art.t_ctyp = 'STF') --On prend les articles de type sous-traités
and lcde.t_ddte between @date_f and @date_t --Bornage sur la date réelle de réception
and left(lcde.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par le numéro de commande
) union all
(select 'Fabrique' as Source, 
opof.t_pdno as NumeroCommandeFabrication, 
opof.t_opno as PositionCommandeFabrication, 
'' as SequenceCommandeFabrication, 
left(opof.t_item, 9) as ProjetArticle, 
substring(opof.t_item, 10, len(opof.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
dbo.convertenum('tc','B61C','a9','bull','kitm',art.t_kitm,'4') as TypeArticle, 
opof.t_ardt as DateCommandeDateFabrication, 
opof.t_qcmp as Quantite, 
(select sum(sortien.t_acip) from twhinr120500 sortien where sortien.t_item = opof.t_item and sortien.t_year = year(getdate())) as SortieReelleAnneeN, 
(select sum(sortien.t_acip) from twhinr120500 sortien where sortien.t_item = opof.t_item and sortien.t_year = year(dateadd("yyyy", -1, opof.t_cmdt))) as SortieReelleAnneeNmoins1, 
opof.t_cwoc as CentreCharge, 
cc.t_dsca as DescriptionCentreCharge, 
opof.t_sutm as TempsPrepaMoyen, 
opof.t_rutm as TempsCycle, 
opof.t_maho as TempsFabrication, 
prixrev.t_ecpr_1 as PrixAchatMoyenCoutStandard, 
prixrev.t_emtc_1 as CoutsMatieres, 
prixrev.t_eopc_1 as CoutsOperatoires, 
art.t_ctyp as TypeProduit 
from ttisfc010500 opof --Opérations des Ordres de Fabrication
inner join ttcibd001500 art on art.t_item = opof.t_item --Articles
left outer join tticpr007500 prixrev on prixrev.t_item = opof.t_item --Prix de Revient
left outer join ttcmcs065500 cc on cc.t_cwoc = opof.t_cwoc --Centre de Charge
where (art.t_ctyp = 'ST' or art.t_ctyp = 'STF') --On prend les articles de type sous-traités
and opof.t_ardt between @date_f and @date_t --Bornage sur la date de début réelle d'OF
and left(opof.t_pdno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par le OF
)