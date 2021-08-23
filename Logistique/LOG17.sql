---------------------------------------
-- LOG17 - X82Navette - Version
---------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select ver.t_egdt as DateIntegrationVersion, 
	   cont.t_cono as Contrat, 
       cont.t_cdes as LibContrat,
	   ver.t_bfbp as TiersVendeur, 
	   ligver.t_schn as ProgrammeAchat, 
	   dbo.convertenum('td','B61C','a9','bull','pur.hstat',prog.t_stat,'4') as 'Statut prog', 
	   ver.t_rlno as Version,
	   ver.t_rlrv as NumVersion, 
	   ligver.t_rpon as PositionVer, 
	   detligver.t_posd as PositionVerDet,
	   dbo.convertenum('tc','B61C','a9','bull','edi.stat',ligver.t_stat,'4') as 'Statut ligne ver', 
	   detligver.t_sdat as Date,
	   detligver.t_qoor as Qté, 
	   detligver.t_cuqp as Unite,
	   dbo.convertenum('td','B61C','a9','bull','pur.rtyp',detligver.t_rqtp,'4') as TypeBesoin, 
	   prog.t_aitc as ArticleFour, 
  	   prog.t_item as Article, 
	   art.t_dsca as DescriptionArticle
	   

from ttdpur322500 detligver 
left outer join ttdpur320500 ver on ver.t_rlno = detligver.t_rlno and ver.t_rlrv = detligver.t_rlrv
left outer join ttdpur321500 ligver on ligver.t_rlno = detligver.t_rlno and ligver.t_rlrv = detligver.t_rlrv and ligver.t_rpon = detligver.t_rpon
left outer join ttdpur310500 prog on prog.t_schn = ligver.t_schn and prog.t_styp = ligver.t_styp and prog.t_stat <= 2 
left outer join ttdpur300500 cont on cont.t_cono = prog.t_cono 
left outer join ttcibd001500 art on art.t_item = prog.t_item 
where detligver.t_rlrv = (select max(t_rlrv) from ttdpur320500 where t_rlno = detligver.t_rlno)
  and ver.t_bfbp between @tiers_f and @tiers_t