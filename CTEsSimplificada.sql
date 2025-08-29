SELECT TOP 10 
    [GW3_EMISDF] AS EmissorCTE,
    [GW3_SERDF] AS SerieCTE,
    [GW3_NRDF] AS NumCTE,
    FORMAT(CONVERT(DATE, [GW3_DTEMIS], 103), 'dd/MM/yyyy') AS DataEmissãoCTE,
    [GW3_TPDF] AS TipoCTE,
    [GW3_SIT] AS SitCTE,
    [GW3_USUIMP] AS UsuárioImportação,
    [GW3_VLDF] AS ValorCTE,
    [GW3_QTVOL] AS QtdeVolumes,
    [GW3_PESOR] AS PesoCTE,
    [GW3_MOTBLQ] AS MotivoBloqueio,
    FORMAT(CONVERT(DATE, [GW3_DTBLQ], 103), 'dd/MM/yyyy') AS DataBloqueio,
    [GW3_USUBLQ] AS UsuárioBloqueio,
    [GW3_MOTAPR] AS MotAprovação,
    FORMAT(CONVERT(DATE, [GW3_DTAPR], 103), 'dd/MM/yyyy') AS DataAprovação,
    [GW3_USUAPR] AS UsuárioAprovação,
    [GW3_EMIFAT] AS EmissorFatura,
    [GW3_SERFAT] AS SerieFatura,
    [GW3_NRFAT] AS NumFatura,
    FORMAT(CONVERT(DATE, [GW3_DTEMFA], 103), 'dd/MM/yyyy') AS DataEmissãoFatura,
    [GW3_VLDIV] AS ValorDivergente,
    [GW3_SITDIV] AS SitDivergência
FROM [STAGE].[gfe].[GW3]
WHERE GW3_EMISDF <> GW3_EMIFAT
  AND GW3_EMIFAT = '12136'
