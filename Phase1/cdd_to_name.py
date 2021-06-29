import sys

CDD_TO_NAME = {
    "CDD:129701": "recQ_fam",
    "CDD:197757": "HELICc",
    "CDD:214692": "DEXDc",
    "CDD:223588": "RecQ",
    "CDD:238005": "DEXDc",
    "CDD:238034": "HELICc",
    "CDD:273594": "recQ",
    "CDD:278688": "DEAD",
    "CDD:278689": "Helicase_C",
    "CDD:271175": "DNA_BRE_C",
    "CDD:271180": "INT_Cre_C",
    "CDD:278986": "Phage_integrase",
    "CDD:280975": "Peptidase_C48",
    "CDD:176653": "WRN_exo",
    "CDD:279057": "rve",
    "CDD:282753": "DUF659",
    "CDD:283379": "Dimer_Tnp_hAT",
    "CDD:290989": "DUF4371",
    "CDD:291070": "DUF4413",
    "CDD:119203": "DBD_Tnp_Hermes",
    "CDD:286647": "YqaJ",
    "CDD:129701": "recQ_fam",
    "CDD:176648": "DEDDh",
    "CDD:197757": "HELICc",
    "CDD:214692": "DEXDc",
    "CDD:223588": "RecQ",
    "CDD:238034": "HELICc",
    "CDD:273594": "recQ",
    "CDD:278688": "DEAD",
    "CDD:278689": "Helicase_C",
    "CDD:222853": "PHA02517",
    "CDD:222879": "PHA02563",
    "CDD:279057": "rve",
    "CDD:281206": "DNA_pol_B_2",
    "CDD:289528": "DDE_Tnp_IS1595",
    "CDD:280975": "Peptidase_C48",
    "CDD:287515": "MULE",
    "CDD:225865": "IS285",
    "CDD:279244": "Transposase_mut",
    "CDD:281149": "DBD_Tnp_Mut",
    "CDD:257152": "Tnp_P_element_C",
    "CDD:288840": "Tnp_P_element",
    "CDD:203098": "Plant_tran",
    "CDD:279886": "DDE_Tnp_1",
    "CDD:290096": "DDE_Tnp_4",
    "CDD:286647": "YqaJ",
    "CDD:139967": "rnhA",
    "CDD:178927": "rnhA",
    "CDD:197306": "EEP",
    "CDD:197307": "ExoIII_AP-endo",
    "CDD:197310": "L1-EN",
    "CDD:197311": "R1-I-EN",
    "CDD:197317": "EEP-1",
    "CDD:197320": "ExoIII-like_AP-endo",
    "CDD:223405": "RnhA",
    "CDD:238185": "RT_like",
    "CDD:238823": "RT_Rtv",
    "CDD:238824": "RT_Bac_retron_I",
    "CDD:238827": "RT_nLTR_like",
    "CDD:238828": "RT_G2_intron",
    "CDD:239569": "RT_Bac_retron_II",
    "CDD:239685": "RT_ZFREV_like",
    "CDD:259998": "RNase_H_like",
    "CDD:260005": "RNase_HI_RT_Bel",
    "CDD:260008": "Rnase_HI_RT_non_LTR",
    "CDD:260009": "RNase_HI_bacteria_like",
    "CDD:260010": "RNase_HI_prokaryote_like",
    "CDD:260011": "RNase_HI_like",
    "CDD:260012": "RNase_HI_eukaryote_like",
    "CDD:260014": "RNase_H_Dikarya_like",
    "CDD:275209": "group_II_RT_mat",
    "CDD:278503": "RNase_H",
    "CDD:278506": "RVT_1",
    "CDD:281380": "Exo_endo_phos",
    "CDD:290192": "RVT_3",
    "CDD:291213": "Exo_endo_phos_2",
    "CDD:238141": "SGNH_hydrolase",
    "CDD:238866": "sialate_O-acetylesterase_like2",
    "CDD:238870": "SGNH_hydrolase_like_1",
    "CDD:239945": "SGNH_hydrolase_like_4",
    "CDD:239946": "SGNH_hydrolase_like_7",
    "CDD:223780": "XthA",
    "CDD:238826": "TERT",
    "CDD:197318": "EEP-2",
    "CDD:197319": "Mth212-like_AP-endo",
    "CDD:197336": "Nape_like_AP-endo",
    "CDD:223780": "XthA",
    "CDD:226098": "ElsH",
    "CDD:238826": "TERT",
    "CDD:273186": "xth",
    "CDD:281052": "Transposase_22",
    "CDD:223780": "XthA",
    "CDD:225881": "YkfC",
    "CDD:238141": "SGNH_hydrolase",
    "CDD:281052": "Transposase_22",
    "CDD:198389": "GIY-YIG_PLEs",
    "CDD:198390": "GIY-YIG_HE_Tlr8p_PBC-V_like",
    "CDD:238826": "TERT",
    "CDD:280975": "Peptidase_C48",
    "CDD:197319": "Mth212-like_AP-endo",
    "CDD:197336": "Nape_like_AP-endo",
    "CDD:223780": "XthA",
    "CDD:238866": "sialate_O-acetylesterase_like2",
    "CDD:280496": "OTU",
    "CDD:238871": "XynB_like",
    "CDD:133136": "retropepsin_like",
    "CDD:224117": "Smc",
    "CDD:225361": "Tra5",
    "CDD:238185": "RT_like",
    "CDD:238823": "RT_Rtv",
    "CDD:238825": "RT_LTR",
    "CDD:239569": "RT_Bac_retron_II",
    "CDD:239684": "RT_DIRS1",
    "CDD:239685": "RT_ZFREV_like",
    "CDD:259998": "RNase_H_like",
    "CDD:260008": "Rnase_HI_RT_non_LTR",
    "CDD:278506": "RVT_1",
    "CDD:279057": "rve",
    "CDD:290406": "rve_3",
    "CDD:274008": "SMC_prok_B",
    "CDD:274009": "SMC_prok_A",
    "CDD:260006": "RNase_HI_RT_Ty3",
    "CDD:279957": "Cauli_VI",
    "CDD:280345": "Peptidase_A3",
    "CDD:225382": "Tra8",
    "CDD:260004": "RNase_HI_RT_Ty1",
    "CDD:285028": "RVT_2",
    "CDD:290669": "DUF4219",
    "CDD:290683": "gag_pre-integrs",
    "CDD:290923": "UBN2",
    "CDD:279057": "rve",
    "CDD:278503": "RNase_H",
    "CDD:290927": "UBN2_2",
    "CDD:290943": "UBN2_3",
    "CDD:238822": "RT_pepA17",
    "CDD:260006": "RNase_HI_RT_Ty3",
    "CDD:260007": "RNase_HI_RT_DIRS1",
    "CDD:271180": "INT_Cre_C",
    "CDD:271188": "INT_RitA_C_like",
    "CDD:271194": "INT_C_like_4",
    "CDD:274043": "recomb_XerD",
    "CDD:283515": "Dam",
    "CDD:271175": "DNA_BRE_C",
    "CDD:271180": "INT_Cre_C",
    "CDD:278986": "Phage_integrase",
    "CDD:280972": "Phage_int_SAM_1",
    "CDD:290192": "RVT_3",
    "CDD:290230": "Phage_int_SAM_4",
    "CDD:133146": "RP_DDI",
    "CDD:133148": "retropepsin_like_LTR_1",
    "CDD:133150": "retropepsin_like_bacteria",
    "CDD:133151": "retropepsin_like_LTR_2",
    "CDD:133158": "RP_Saci_like",
    "CDD:133159": "RP_RTVL_H_like",
    "CDD:139967": "rnhA",
    "CDD:180903": "PRK07238",
    "CDD:214605": "CHROMO",
    "CDD:223405": "RnhA",
    "CDD:237991": "CHROMO",
    "CDD:238822": "RT_pepA17",
    "CDD:254125": "Gypsy",
    "CDD:260006": "RNase_HI_RT_Ty3",
    "CDD:260007": "RNase_HI_RT_DIRS1",
    "CDD:260010": "RNase_HI_prokaryote_like",
    "CDD:260011": "RNase_HI_like",
    "CDD:260012": "RNase_HI_eukaryote_like",
    "CDD:260014": "RNase_H_Dikarya_like",
    "CDD:274008": "SMC_prok_B",
    "CDD:274009": "SMC_prok_A",
    "CDD:278503": "RNase_H",
    "CDD:278505": "RVP",
    "CDD:278797": "Chromo",
    "CDD:282101": "Transposase_28",
    "CDD:285484": "RVP_2",
    "CDD:287502": "PMD",
    "CDD:290377": "Asp_protease_2",
    "CDD:290682": "gag-asp_proteas",
    "CDD:260006": "RNase_HI_RT_Ty3",
    "CDD:260007": "RNase_HI_RT_DIRS1",
    "CDD:271180": "INT_Cre_C",
    "CDD:238822": "RT_pepA17",
    "CDD:274008": "SMC_prok_B",
    "CDD:283123": "Peptidase_A17",
    "CDD:223581": "RecD",
    "CDD:253483": "PIF1",
    "CDD:290914": "Helitron_like_N",
    "CDD:290555": "DDE_Tnp_1_7",
    "CDD:197828": "CENPB",
    "CDD:225872": "COG3335",
    "CDD:225949": "COG3415",
    "CDD:281213": "DDE_1",
    "CDD:290095": "DDE_3",
    "CDD:250558": "Transposase_1",
    "CDD:292705": "DUF4817",
    "CDD:281050": "Transposase_21",
    "CDD:290668": "DUF4218",
    "CDD:290671": "Transpos_assoc",
    "CDD:290661": "DUF4216",
    "CDD:251669": "Transposase_24"
}

for line in sys.stdin:
    lst = line.split()
    if len(lst) > 1 and lst[1] != "unique":
        domains = list()
        for i in range(1, len(lst)):
            dom = CDD_TO_NAME.get(lst[i][:-1])
            if dom:
                domains.append(dom)
            else:
                domains.append("MIA")
        print(lst[0], ", ".join(domains))
