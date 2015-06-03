clear all
*cd "G:\2007-2014"
cd "G:\PCA_MIDIS\SERVICIOS"

global bases2014 "G:\PCA_MIDIS\BASE DE DATOS\base final\con 2014\"

use "G:\BASES DE DATOS\ENAHO\2014\enaho01-2014-200"
merge m:1 conglome vivienda hogar  using "G:\BASES DE DATOS\ENAHO\2014\sumaria-2014", nogen

rename aÑo a_o
destring conglome vivienda hogar a_o, replace
drop mes
merge m:1 conglome vivienda hogar a_o using "$bases2014\base_unificada.dta"


keep if _m==3

gen edad65=0
replace edad65=1 if p208a>=65 & p208a<=98
sort conglome vivienda hogar
drop _m

*Gasto autónomo
*===============

gen factor07pob=factor07*mieperho

gen gashog2dautonomo=gasto_total-ingtpu01- gru13hd1- gru23hd1- gru33hd1- gru43hd1- gru53hd1- gru63hd1- gru73hd1- gru83hd1
replace gashog2dautonomo=0 if gashog2dautonomo<0

gen gastopcautonomo=gashog2dautonomo/(mieperho*12)
label var gastopcautonomo "gasto pc mensual sin incluir juntos o donaciones publ en especie"

gen px_gast_aut=(gastopcautonomo<linpe)
gen np_gast_aut=(linea<gastopcautonomo & gastopcautonomo>linpe)

gen pobreza_gast_aut=2
replace pobreza_gast_aut=1 if px_gast_aut==1
replace pobreza_gast_aut=3 if np_gast_aut==1


*estrato  geograficop

gen GEO_dominio=dominio
gen GEO_estrato=estrato
gen GEO_DomEst=dominio*10+estrato

gen GEO_area=1
replace GEO_area=2 if (estrato>=6)
replace GEO_area=1 if (GEO_dominio==8)

gen GEO_DomArea=GEO_dominio*10+GEO_area

label define quince	11 "11Costa Norte-urbano"   12 "12Costa Norte-rural" ///
                    21 "21Costa Centro-urbano"  22 "22Costa Centro-rural" ///
					31 "31Costa Sur-urbano"     32 "32Costa Sur-rural" ///
					41 "41Sierra Norte-urbano"  42 "42Sierra Norte-rural" ///
					51 "51Sierra Centro-urbano" 52 "52Sierra Centro-rural" ///
					61 "61Sierra Sur-urbano"    62 "62Sierra Sur-rural" ///
					71 "71Selva-urbano"         72 "72Selva-rural" ///
					81 "81Lima Metropolitana-urbano", modify
label values GEO_DomArea quince

recode pobreza (3=0) (2=1) (1=1),gen (pobre)

*datos de la pizarra
tab GEO_DomArea pobre [aw=factor07pob] if a_o==2014,row nofreq
recode pobreza_gast_aut (3=0) (2=1) (1=1),gen (pobre_gast_aut)

tab GEO_DomArea pobre_gast_aut [aw=factor07pob] if a_o==2014,row nofreq

tab pobreza_gast_aut a_o [aw=factor07pob],row nofreq
tab pobreza a_o [aw=factor07pob],row nofreq

*brechas de pobreza

tab pobreza_gast_aut a_o [aw=factor07pob],row nofreq

tabstat pobreza_gast_aut a_o [aw=factor07pob]

tabstat edad65 [aw=factor07pob], by(pobreza_gast_aut)

tab pobreza_gast_aut edad65 [aw=factor07pob],col







