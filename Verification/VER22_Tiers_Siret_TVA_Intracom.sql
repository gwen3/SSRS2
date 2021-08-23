--------------------------------------------------------
-- VER22 Tiers : doublons SIRET/TVA Intracom 
--------------------------------------------------------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

(select 
'Code_Siret' as Controle,
newtiers.t_crdt as DateCréation,
newtiers.t_usid as CreePar,
convert(varchar,newtiers.t_lgid) as Siret_Tva_Intracom,
newtiers.t_bpid as Tiers,
newtiers.t_nama as NomTiers,
dbo.convertenum('tc','B61C','a9','bull','com.prst',newtiers.t_prst,'4') as StatutTiers,
oldtiers.t_bpid as TiersDouble,
oldtiers.t_nama as NomTiersDouble,
oldtiers.t_crdt as DateCreationDouble,
oldtiers.t_usid as CreeParDouble,
dbo.convertenum('tc','B61C','a9','bull','com.prst',oldtiers.t_prst,'4') as StatutTiersDouble,
case
	when adresse.t_namd > '' then concat(adresse.t_namc, ' ', adresse.t_namd)
	else adresse.t_namc
end as Rue,
adresse.t_pstc as CP,
adresse.t_ccit as CodeVille,
ville.t_dsca as Ville
from ttccom100500 newtiers
inner join ttccom100500 as oldtiers on oldtiers.t_lgid = newtiers.t_lgid
left outer join ttccom130500 as adresse on adresse.t_cadr = oldtiers.t_cadr
left outer join ttccom139500 as ville on ville.t_city = adresse.t_ccit and ville.t_cste = adresse.t_cste and ville.t_ccty = adresse.t_ccty
where '1' in (@typectrl)
and newtiers.t_prst = '2' --Statut actif
and newtiers.t_crdt >= DATEADD(day,-convert(REAL,@jcreation),getdate())
and newtiers.t_lgid != 'NA'
and (select count(*) from ttccom100500 tiers where tiers.t_lgid = newtiers.t_lgid and tiers.t_bpid != newtiers.t_bpid) > 1)
union all
(select
'Code TVA Intracom' as Controle,
newtiers.t_crdt as DateCréation,
newtiers.t_usid as CreePar,
newtax.t_fovn as Siret_Tva_Intracom,
newtiers.t_bpid as Tiers,
newtiers.t_nama as NomTiers,
dbo.convertenum('tc','B61C','a9','bull','com.prst',newtiers.t_prst,'4') as StatutTiers,
oldtiers.t_bpid as TiersDouble,
oldtiers.t_nama as NomTiersDouble,
oldtiers.t_crdt as DateCreationDouble,
oldtiers.t_usid as CreeParDouble,
dbo.convertenum('tc','B61C','a9','bull','com.prst',oldtiers.t_prst,'4') as StatutTiersDouble,
case
	when adresse.t_namd > '' then concat(adresse.t_namc, ' ', adresse.t_namd)
	else adresse.t_namc
end as Rue,
adresse.t_pstc as CP,
adresse.t_ccit as CodeVille,
ville.t_dsca as Ville
from ttccom100500 newtiers -- Tiers 
inner join ttctax400500 newtax on newtax.t_bpid = newtiers.t_bpid --N° TVA par tiers
inner join ttctax400500 oldtax on oldtax.t_fovn = newtax.t_fovn and oldtax.t_efdt <=  getdate() and (oldtax.t_exdt = '01/01/1970' or oldtax.t_exdt > getdate())
inner join ttccom100500 oldtiers on oldtiers.t_bpid = oldtax.t_bpid
left outer join ttccom130500 as adresse on adresse.t_cadr = newtiers.t_cadr
left outer join ttccom139500 as ville on ville.t_city = adresse.t_ccit and ville.t_cste = adresse.t_cste and ville.t_ccty = adresse.t_ccty
where '2' in (@typectrl)
and newtiers.t_prst = '2' --Statut actif
and newtiers.t_crdt >= DATEADD(day,-convert(REAL,@jcreation),getdate())
and newtax.t_efdt <= getdate()
and (newtax.t_exdt = '01/01/1970' or newtax.t_exdt > getdate())
and (select count(*) from ttctax400500 tax inner join ttccom100500 tiers on tax.t_bpid = tiers.t_bpid
					where tax.t_fovn = newtax.t_fovn and tax.t_bpid != newtiers.t_bpid and tax.t_efdt <=  getdate() and (tax.t_exdt = '01/01/1970' or tax.t_exdt > getdate())) > 1)
order by 1,newtiers.t_bpid, oldtiers.t_bpid