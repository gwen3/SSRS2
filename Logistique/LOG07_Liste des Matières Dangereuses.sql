---------------------------------------
-- LOG07 - Liste Matières Dangereuses
---------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select stk.t_cwar as Magasin, 
stk.t_loca as Emplacement, 
emp.t_zone as ZoneStockage, 
left(stk.t_item, 9) as Projet, 
substring(stk.t_item, 10, len(stk.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
art.t_cuni as Unite, 
stk.t_qhnd as StockPhysique, 
stk.t_qblk as StockBloque, 
art.t_cwun as UnitePoids, 
art.t_wght as Poids, 
mag.t_risk as ClasseRisque, 
mag.t_hght as Hauteur, 
mag.t_wdth as Largeur, 
mag.t_dpth as Profondeur, 
mag.t_hght * mag.t_wdth * mag.t_dpth as Volume 
from twhinr140500 stk --Gestion de Stock
left join ttcibd001500 art on art.t_item = stk.t_item --Articles
left join twhwmd400500 mag on mag.t_item = stk.t_item --Données Magasin des Articles
left join twhwmd300500 emp on emp.t_cwar = stk.t_cwar and emp.t_loca = stk.t_loca --Gestion d'Emplacements
where mag.t_risk <> '               ' --On prend uniquement les lignes qui ont un risque
and left(stk.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'UE définie par le Magasin
order by stk.t_cwar, mag.t_risk