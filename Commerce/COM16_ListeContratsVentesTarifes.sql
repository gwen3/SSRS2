-------------------------------------------------
-- COM16 - Liste des Contrats de Ventes Tarifés
-------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select contven.t_ofbp as TiersAcheteur, 
tiersach.t_nama as NomTiersAcheteur, 
contven.t_stbp as TiersDestinataire, 
tiersdes.t_nama as NomTiersDestinataire, 
contven.t_cono as NumeroContratVente, 
contven.t_cdes as DescriptionContratVente, 
lcontven.t_pono as PositionContratVente, 
contven.t_corn as CommandeClient, 
substring(lcontven.t_item, 10, len(lcontven.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
lcontven.t_citm as ArticleClient, 
dbo.convertenum('tc','B61C','a9','bull','icap',lcontven.t_icap,'4') as StatutLigneContrat, 
prix.t_revn as LigneDesPrixDeContrat, 
prix.t_efdt as DateApplication, 
dbo.convertenum('tc','B61C','a9','bull','icap',prix.t_icap,'4') as StatutPrixContrat, 
infoprix.t_pric as Prix, 
infoprix.t_cupr as UnitePrix 
from ttdsls301500 lcontven --Lignes de Contrats de Ventes
inner join ttdsls300500 contven on contven.t_cono = lcontven.t_cono --Contrats de Ventes
inner join ttcibd001500 art on art.t_item = lcontven.t_item --Articles
left outer join ttdsls303500 prix on prix.t_cono = lcontven.t_cono and prix.t_pono = lcontven.t_pono and prix.t_cofc = lcontven.t_cofc --Prix de Contrat de Vente
left outer join ttdpcg100500 infoprix on infoprix.t_prid = prix.t_prid --Informations sur les Prix
left outer join ttccom100500 tiersach on tiersach.t_bpid = contven.t_ofbp --Tiers Acheteur
left outer join ttccom100500 tiersdes on tiersdes.t_bpid = contven.t_stbp --Tiers Destinataire
where contven.t_icap = 2 --On ne prend que les Contrats Actifs
and contven.t_ofbp between @tiers_f and @tiers_t --Bornage sur le Tiers Acheteur