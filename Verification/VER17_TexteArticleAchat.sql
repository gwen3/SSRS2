--------------------------------
-- VER17 - Texte Article Achat
--------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select acharttier.t_citg as GroupeArticle, 
left(acharttier.t_item, 9) as ProjetArticle, 
substring(acharttier.t_item, 10, len(acharttier.t_item)) as Article, 
acharttier.t_otbp as Fournisseur, 
acharttier.t_sfbp as Expediteur, 
acharttier.t_efdt as DateApplication, 
acharttier.t_txta as NumeroTexteArticleAchatTier, 
dbo.textnumtotext(acharttier.t_txta,'4') as TexteArticleAchatTierFR, 
dbo.textnumtotext(acharttier.t_txta,'2') as TexteArticleAchatTierEN, 
acharttier.t_txtb as NumeroTexteArticleAchatTier2, 
dbo.textnumtotext(acharttier.t_txtb,'4') as TexteArticleAchatTierFR2, 
dbo.textnumtotext(acharttier.t_txtb,'2') as TexteArticleAchatTierEN2, 
achart.t_txtp as NumeroTexteAchat, 
dbo.textnumtotext(achart.t_txtp,'4') as TexteAchatFR, 
dbo.textnumtotext(achart.t_txtp,'2') as TexteAchatEN 
from ttdipu010500 acharttier 
inner join ttdipu001500 achart on achart.t_item = acharttier.t_item 
inner join ttccom120500 tier on tier.t_otbp = acharttier.t_otbp 
where (achart.t_txtp != 0 or acharttier.t_txta != 0 or acharttier.t_txtb != 0)
and tier.t_clan != '01' 
and ((dbo.textnumtotext(acharttier.t_txta,'4') != dbo.textnumtotext(acharttier.t_txta,'2')) 
or (dbo.textnumtotext(acharttier.t_txtb,'4') != dbo.textnumtotext(acharttier.t_txtb,'2')) 
or (dbo.textnumtotext(achart.t_txtp,'4') != dbo.textnumtotext(achart.t_txtp,'2')))