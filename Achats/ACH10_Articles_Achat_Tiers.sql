-----------------------------------------
-- Extraction ARTICLES ACHATS TIERS
-----------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
substring(a.t_item, 10, len(a.t_item)) as Article,
art.t_dsca as DescriptionArticle,
a.t_otbp as Fournisseur,
tiers.t_nama as NomFournisseur,
dbo.convertenum('td','B61C','a9','bull','ipu.pref',a.t_pref,'4') as Recommande
FROM ttdipu010500 a -- Articles - Achat Tiers
inner join ttccom100500 tiers on tiers.t_bpid = a.t_otbp --Tiers
inner join ttcibd001500 art on art.t_item = a.t_item --Articles
WHERE 
a.t_efdt <= getdate() and -- Date application
a.t_exdt > getdate() and -- Date expiration
left(a.t_item, 9) = '' and -- Partie projet de l'article vide
a.t_ibps = '1' and -- Statut du tiers "Approuvé"
-- Récupération 1 fournisseur actif par article (préférence "Source unique" par défaut)
a.t_otbp = (select top 1 f.t_otbp from ttdipu010500 f inner join ttccom100500 t on f.t_otbp = t.t_bpid where f.t_item = a.t_item and t.t_prst = '2' order by f.t_pref DESC, f.t_efdt DESC) 