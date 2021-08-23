------------------------
-- Planning Carrossier
------------------------

select lcde.*, 
substring(lcde.t_item,10,37) as [item], 
substring(lcde.t_item,1,9) as [cprj], 
cde.t_sotp as [ttdsls400500 t_sotp], 
cde.t_cofc as [ttdsls400500 t_cofc], 
cde.t_odat as [ttdsls400500 t_odat], 
cde.t_ofbp as [ttdsls400500 t_ofbp], 
cde.t_crep as [ttdsls400500 t_crep], 
cde.t_refa as [ttdsls400500 t_refa], 
cde.t_corn as [ttdsls400500 t_corn], 
art.t_kitm as [art t_kitm], 
art.t_dsca as [art t_dsca], 
art.t_dfit as [art t_dfit], 
mag.t_dicl as [ttcemm112500 t_dicl], 
dalcc.t_citg as [ttdsls411500 t_citg], 
prj.t_psta as [ttipcs030500 t_psta], 
tiers.t_nama as [ttccom100500 t_nama], 
emp.t_nama as [ttccom001500 t_nama], 
grpart.t_dsca as [ttcmcs023500 t_dsca], 
dbo.textnumtotext(lcde.t_txta,'4') as 'txta lov', 

(case
when (lcde.t_serl <> '' 
	and lcde.t_item <> @item_chassis 
	and exists 
		(select tete.t_pdno 
		from ttimfc010500 tete 
		where (lcde.t_item = tete.t_mitm 
		and lcde.t_serl = tete.t_mser))) 
	then (select top 1 tete.t_pdno 
		from ttimfc010500 tete 
		where (lcde.t_item = tete.t_mitm 
		and lcde.t_serl = tete.t_mser)) 
when (lcde.t_serl <> '' 
	and lcde.t_item <> @item_chassis 
	and not exists 
		(select tete.t_pdno 
		from ttimfc010500 tete 
		where (lcde.t_item = tete.t_mitm 
		and lcde.t_serl = tete.t_mser))) 
	then (select top 1 ofab.t_pdno 
		from ttisfc001500 ofab 
		where lcde.t_item = ofab.t_mitm)
when (lcde.t_serl = ''  and lcde.t_item <>@item_chassis) then (select top 1 ofab.t_pdno from ttisfc001500 ofab where lcde.t_item = ofab.t_mitm)
end) as OrdreFabrication, 

case 
when (lcde.t_serl <> '' and lcde.t_item <> @item_chassis and exists (select tete.t_pdno from ttimfc010500 tete 
		where (lcde.t_item = tete.t_mitm and lcde.t_serl = tete.t_mser))) then 
   (select  ofab.t_prdt
	from ttisfc001500 ofab
	where ofab.t_pdno = 
	(select top 1 tete.t_pdno from ttimfc010500 tete where tete.t_mitm = lcde.t_item and tete.t_mser = lcde.t_serl))
when (lcde.t_serl <> '' and lcde.t_item <> @item_chassis and not exists (select tete.t_pdno from ttimfc010500 tete 
		where (lcde.t_item = tete.t_mitm and lcde.t_serl = tete.t_mser))) then 
   (select  ofab.t_prdt
	from ttisfc001500 ofab
	where ofab.t_pdno = 
	(select top 1 tete.t_pdno from ttisfc001500 tete where tete.t_mitm = lcde.t_item))
when (lcde.t_serl = '' and lcde.t_item <> @item_chassis) then 
	(select  ofab.t_prdt
	from ttisfc001500 ofab
	where ofab.t_pdno = 
	(select top 1 tete.t_pdno from ttisfc001500 tete where tete.t_mitm = lcde.t_item)
		)
end as of_prdt
,case 
when (lcde.t_serl <> '' and lcde.t_item <> @item_chassis and exists (select tete.t_pdno from ttimfc010500 tete 
		where (lcde.t_item = tete.t_mitm and lcde.t_serl = tete.t_mser))) then 
   (select  ofab.t_pldt
	from ttisfc001500 ofab
	where ofab.t_pdno = 
	(select top 1 tete.t_pdno from ttimfc010500 tete where tete.t_mitm = lcde.t_item and tete.t_mser = lcde.t_serl))
when (lcde.t_serl <> '' and lcde.t_item <> @item_chassis and not exists (select tete.t_pdno from ttimfc010500 tete 
		where (lcde.t_item = tete.t_mitm and lcde.t_serl = tete.t_mser))) then 
   (select  ofab.t_pldt
	from ttisfc001500 ofab
	where ofab.t_pdno = 
	(select top 1 tete.t_pdno from ttisfc001500 tete where tete.t_mitm = lcde.t_item))
when (lcde.t_serl = '' and lcde.t_item <> @item_chassis) then 
	(select  ofab.t_pldt
	from ttisfc001500 ofab
	where ofab.t_pdno = 
	(select top 1 tete.t_pdno from ttisfc001500 tete where tete.t_mitm = lcde.t_item)
		)
end as of_pldt       
,case 
when (lcde.t_serl <> '' and lcde.t_item <> @item_chassis and exists (select tete.t_pdno from ttimfc010500 tete 
		where (lcde.t_item = tete.t_mitm and lcde.t_serl = tete.t_mser))) then 
   (select  ofab.t_cmdt
	from ttisfc001500 ofab
	where ofab.t_pdno = 
	(select top 1 tete.t_pdno from ttimfc010500 tete where tete.t_mitm = lcde.t_item and tete.t_mser = lcde.t_serl))
when (lcde.t_serl <> '' and lcde.t_item <> @item_chassis and not exists (select tete.t_pdno from ttimfc010500 tete 
		where (lcde.t_item = tete.t_mitm and lcde.t_serl = tete.t_mser))) then 
   (select  ofab.t_cmdt
	from ttisfc001500 ofab
	where ofab.t_pdno = 
	(select top 1 tete.t_pdno from ttisfc001500 tete where tete.t_mitm = lcde.t_item))	
when (lcde.t_serl = '' and lcde.t_item <> @item_chassis) then 
	(select  ofab.t_cmdt
	from ttisfc001500 ofab
	where ofab.t_pdno = 
	(select top 1 tete.t_pdno from ttisfc001500 tete where tete.t_mitm = lcde.t_item)
		)
end as of_cmdt 

,(case
when (lcde.t_serl <> '' and lcde.t_item =  @item_chassis) 
	then (select dbo.convertlistcdf('wh','b61c','a9','grup','mar',e.t_cdf_marq,'4') from twhltc500500 e
		where (lcde.t_item = e.t_item and lcde.t_serl = e.t_serl and lcde.t_cwar = e.t_cwar)) 
        else (select dbo.convertlistcdf('wh','b61c','a9','grup','mar',e.t_cdf_marq,'4') from twhltc500500 e
		where (lcde.t_item = e.t_item and lcde.t_serl = e.t_serl and lcde.t_cwar = e.t_cwar))
end) as marque

,(case
when (lcde.t_serl <> '' and lcde.t_item =  @item_chassis) 
	then (select e.t_rdat from twhltc500500 e
		where (lcde.t_item = e.t_item and lcde.t_serl = e.t_serl and lcde.t_cwar = e.t_cwar)) 
end) as arrivee_chassis

,(case
-- gamme standard
when gamme.t_stor = 1 then 
	(select sum ((h.t_sutm*h.t_most)/60 + (h.t_rutm*h.t_mopr)/60) from ttirou102500 h
		where (h.t_mitm = '' and h.t_opro = gamme.t_strc))
 -- game non standard
when gamme.t_stor = 2 then
	(select sum ((h.t_sutm*h.t_most)/60 + (h.t_rutm*h.t_mopr)/60) from ttirou102500 h
		where (lcde.t_item = h.t_mitm and lcde.t_item <>@item_chassis and ltrim(rtrim(h.t_opro)) = '0'))
-- par défaut
else
	0.0
end) as ta_global

, (select top 1 ttdsls406500.t_dldt
	from ttdsls406500
	where (lcde.t_orno = ttdsls406500.t_orno 
    			and lcde.t_pono = ttdsls406500.t_pono 
    			and lcde.t_sqnb = ttdsls406500.t_sqnb)
  ) as  date_liv

, (select top 1 ttdsls406500.t_shpm
	from ttdsls406500
	where (lcde.t_orno = ttdsls406500.t_orno 
    			and lcde.t_pono = ttdsls406500.t_pono 
    			and lcde.t_sqnb = ttdsls406500.t_sqnb)
  ) as  shpm

, (select twhinh430500.t_pdat
	from twhinh430500
	where twhinh430500.t_shpm = (select top 1 ttdsls406500.t_shpm
	from ttdsls406500
	where (lcde.t_orno = ttdsls406500.t_orno 
    			and lcde.t_pono = ttdsls406500.t_pono 
    			and lcde.t_sqnb = ttdsls406500.t_sqnb)
  ) 
  )
  as  bl_pdat

from ttdsls401500 lcde --Lignes de Commandes Clients
inner join ttdsls400500 cde on lcde.t_orno = cde.t_orno --Commandes 
inner join ttcibd001500 art on art.t_item = lcde.t_item --Articles
left outer join ttcemm112500 mag on (mag.t_loco = 500 and mag.t_waid = lcde.t_cwar) --Magasins
inner join ttdsls411500 dalcc on (lcde.t_orno = dalcc.t_orno and lcde.t_pono = dalcc.t_pono and lcde.t_sqnb = dalcc.t_sqnb) --Données Article de la ligne de Commande Client
left outer join ttipcs030500 prj on prj.t_cprj = substring(lcde.t_item,1,9) --Projet
left outer join ttccom100500 tiers on cde.t_ofbp = tiers.t_bpid --Tiers
left outer join ttccom001500 emp on cde.t_crep = emp.t_emno --Employés
left outer join ttcmcs023500 grpart on grpart.t_citg = dalcc.t_citg --Groupe Article
left outer join ttirou101500 gamme on gamme.t_mitm = lcde.t_item and ltrim(rtrim(gamme.t_opro)) = '0' and lcde.t_item <>@item_chassis --Gamme Par Article
where lcde.t_orno between @orno_f and @orno_t
and lcde.t_clyn <> 1
and	cde.t_sotp between @sotp_f and @sotp_t
and	cde.t_cofc between @cofc_f and @cofc_t
and	cde.t_odat between @odat_f and @odat_t
and	dalcc.t_citg between @citg_f and @citg_t
and (@facture=1 or (not exists 
 (select ttdsls406500.t_orno
	from ttdsls406500
	where (lcde.t_orno = ttdsls406500.t_orno 
    			and lcde.t_pono = ttdsls406500.t_pono 
    			and lcde.t_sqnb = ttdsls406500.t_sqnb)
  )
  or
  exists 
 (select ttdsls406500.t_orno
	from ttdsls406500
	where (lcde.t_orno = ttdsls406500.t_orno 
    			and lcde.t_pono = ttdsls406500.t_pono 
    			and lcde.t_sqnb = ttdsls406500.t_sqnb)
  and ttdsls406500.t_invn = 0
  )
  ))
and (art.t_kitm = 1 or art.t_kitm = 2 or art.t_kitm = 3)