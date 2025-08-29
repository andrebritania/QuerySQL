SELECT TOP (1000) 
    [GWM_SERDOC] AS SerieCTE,
    [GWM_NRDOC] AS NumeroCTE,
    FORMAT(CONVERT(DATE, [GWM_DTEMIS], 103), 'dd/MM/yyyy') AS DataEmissao,
    [GWM_CDTPDC] AS TipoDOC,
    [GWM_SERDC] AS SerieNotaFiscal,
    [GWM_NRDC] AS NumeroNotaFiscal,
    [GWM_ITEM] AS CodItem,
    [GWM_CCFRET] AS CentroCusto,
    [GWM_VLFRE1] AS ValorFrete
FROM [STAGE].[gfe].[GWM]
WHERE GWM_CCFRET='23210'


