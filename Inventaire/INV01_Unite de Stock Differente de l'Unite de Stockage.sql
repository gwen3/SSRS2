----------------------------------------------------------
-- INV01 - Unite de Stock Differente de l'Unite Stockage
----------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select left(stk.t_item, 9) as Projet, 
substring(stk.t_item, 10, len(stk.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
stk.t_cwar as Magasin, 
stk.t_loca as Emplacement, 
stk.t_cuni as UniteStockage, 
art.t_cuni as UniteStock, 
stk.t_qhds as StockPhysiqueUniteStockage,
stk.t_qhnd as StockPhysiqueUniteStock, 
stk.t_qals as StockAffecteUniteStockage, 
stock.t_qlal as StockAffecteUniteStock, 
faconv.t_conv as FacteurConversion, --Création d'une formule sur SSRS pour choisir le bon facteur de conversion
faconv2.t_conv as FacteurConversionGenerique --Formule : =IIf(CStr(Fields!FacteurConversion.Value) = "", Fields!FacteurConversionGenerique.Value, Fields!FacteurConversion.Value)
from twhinr150500 stk --Structure de Stock
inner join ttcibd001500 art on art.t_item = stk.t_item --Articles
left outer join ttcibd003500 faconv on faconv.t_basu = art.t_cuni and faconv.t_unit = stk.t_cuni and faconv.t_item = stk.t_item --On cherche le facteur de conversion en prenant en référence l'unité de stockage et en cherchant l'unité de stock
left outer join ttcibd003500 faconv2 on faconv2.t_basu = art.t_cuni and faconv2.t_unit = stk.t_cuni and faconv2.t_item = ' ' --On cherche le facteur de conversion générique
left outer join twhinr140500 stock on stock.t_item = stk.t_item and stock.t_loca = stk.t_loca and stock.t_cwar = stk.t_cwar and stock.t_clot = stk.t_clot and stock.t_idat = stk.t_idat --Gestion de Stock
where left(stk.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'UE définie par le Magasin
and stk.t_cuni != art.t_cuni --On ne prend que les unité différentes
and concat(stk.t_cuni, art.t_cuni) != 'PCEPI' --On ne prend pas les PCE et PI
and concat(stk.t_cuni, art.t_cuni) != 'PIPCE' --On ne prend pas les PI et PCE
