------------------------------------
-- MDM06 - Ecart de Stocks Bloqués
------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select stkartmag.t_cwar as Magasin, 
stkartmag.t_item as Article, 
art.t_dsca as DescriptionArticle, 
stkartmag.t_qblk as QuantiteBloqueStock, 
stkprj.t_qblk as QuantiteBloqueProjet 
from twhwmd215500 stkartmag --Stock des Articles par Magasin
inner join twhwmd260500 stkprj on stkprj.t_cwar = stkartmag.t_cwar and stkprj.t_item = stkartmag.t_item and stkprj.t_cprj = left(stkartmag.t_item, 9) --Stock rattaché au Projet
inner join ttcibd001500 art on art.t_item = stkartmag.t_item --Articles
where stkartmag.t_qblk != stkprj.t_qblk --On prend les enregistrements dont les stocks bloqués sont différents