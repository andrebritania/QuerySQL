SELECT TOP (1000) 
    [GW6_EMIFAT] AS TranspFatura,
    [GW6_SERFAT] AS SerieFatura,
    [GW6_NRFAT] AS NumeroFatura,
    FORMAT(CONVERT(DATE, [GW6_DTEMIS], 103), 'dd/MM/yyyy') AS DataEmissaoFatura,
    [GW6_VLFATU] AS ValorFatura,
    FORMAT(CONVERT(DATE, [GW6_DTVENC], 103), 'dd/MM/yyyy') AS DataVencimento,
    [GW6_SITAPR] AS SitAprovação,
    FORMAT(CONVERT(DATE, [GW6_DTAPR], 103), 'dd/MM/yyyy') AS DataAprovação,
    [GW6_HRAPR] AS HoraAprovação,
    [GW6_USUAPR] AS UsuarioAprovação,
    [GW6_SITFIN] AS SitFinanceiro,
    FORMAT(CONVERT(DATE, [GW6_DTFIN], 103), 'dd/MM/yyyy') AS DataFinanceiro,
    [GW6_HRFIN] AS HoraFinanceiro,
    [GW6_USUFIN] AS UsuarioFinanceiro,
    [GW6_SITMLA] AS SitMLA,
    [GW6_MOTMLA] AS MotivoMLA,
    [GW6_USUIMP] AS UsuárioImportação
FROM [STAGE].[gfe].[GW6]
WHERE D_E_L_E_T_ <> '*'

