WITH GW6_Filtrada AS (
    SELECT
        EMPRESA,
        GW6_EMIFAT,
        GW6_SERFAT,
        GW6_NRFAT,
        CAST(GW6_DTEMIS AS DATE) AS GW6_DTEMIS,
        CAST(GW6_DTVENC AS DATE) AS GW6_DTVENC,
        GW6_VLFATU,
        GW6_SITAPR,
        CAST(GW6_DTAPR AS DATE) AS GW6_DTAPR,
        GW6_HRAPR,
        GW6_USUAPR,
        GW6_SITFIN,
        CAST(GW6_DTFIN AS DATE) AS GW6_DTFIN,
        GW6_HRFIN,
        GW6_USUFIN,
        GW6_SITMLA,
        GW6_MOTMLA,
        GW6_USUIMP
    FROM [STAGE].[gfe].[GW6]
    WHERE GW6_DTEMIS > '2024-12-01'
),
EmitentesFiltrados AS (
    SELECT CodEmitente, NomeMatriz
    FROM [DW].[dbo].[Dim_Emitente]
    WHERE CodEmitente IN (SELECT DISTINCT GW6_EMIFAT FROM GW6_Filtrada)
)
SELECT
    GW6.GW6_EMIFAT AS CodEmissorFatura,
    DE.NomeMatriz AS TranspFatur,
    GW6.GW6_SERFAT AS SerieFatura,
    GW6.GW6_NRFAT AS NumeroFatura,
    GW6.GW6_DTEMIS AS DataEmissaoFatura,
    GW6.GW6_VLFATU AS ValorFatura,
    GW6.GW6_DTVENC AS DataVencimento,
    GW6.GW6_SITAPR AS SitAprovação,
    GW6.GW6_DTAPR AS DataAprovação,
    GW6.GW6_HRAPR AS HoraAprovação,
    GW6.GW6_USUAPR AS UsuarioAprovação,
    GW6.GW6_SITFIN AS SitFinanceiro,
    GW6.GW6_DTFIN AS DataFinanceiro,
    GW6.GW6_HRFIN AS HoraFinanceiro,
    GW6.GW6_USUFIN AS UsuarioFinanceiro,
    GW6.GW6_SITMLA AS SitMLA,
    GW6.GW6_MOTMLA AS MotivoMLA,
    GW6.GW6_USUIMP AS UsuarioImportacaoGW6,
    GW3.GW3_EMISDF AS EmissorCTE,
    GW3.GW3_SERDF AS SerieCTE,
    GW3.GW3_NRDF AS NumCTE,
    CAST(GW3.GW3_DTEMIS AS DATE) AS DataEmissaoCTE,
    GW3.GW3_TPDF AS TipoCTE,
    GW3.GW3_SIT AS SitCTE,
    GW3.GW3_VLDF AS ValorCTE,    
    GW3.GW3_QTVOL AS QtdeVolumes,
    GW3.GW3_PESOR AS PesoCTE,
    GW3.GW3_USUIMP AS UsuarioImportacao,
    GW3.GW3_MOTBLQ AS MotivoBloqueio,
    CAST(GW3.GW3_DTBLQ AS DATE) AS DataBloqueio,
    GW3.GW3_USUBLQ AS UsuarioBloqueio,
    GW3.GW3_MOTAPR AS MotivoAprovacao,
    CAST(GW3.GW3_DTAPR AS DATE) AS DataAprovacaoCTE,
    GW3.GW3_USUAPR AS UsuarioAprovacaoCTE,
    GW3.GW3_VLDIV AS ValorDivergente,
    GW3.GW3_SITDIV AS SitDivergencia,  
    GWM.GWM_CDTPDC AS TipoDOC,
    GWM.GWM_SERDC AS SerieNotaFiscal,
    GWM.GWM_NRDC AS NumeroNotaFiscal,
    GWM.GWM_ITEM AS CodItem,
    GWM.GWM_CCFRET AS CentroCusto,
    GWM.GWM_VLFRE1 AS ValorFreteNota
FROM GW6_Filtrada GW6
LEFT JOIN [DW].[dbo].[Dim_Emitente] DE
    ON GW6.GW6_EMIFAT = DE.CodEmitente
LEFT JOIN [STAGE].[gfe].[GW3] GW3
    ON GW6.EMPRESA     = GW3.EMPRESA
   AND GW6.GW6_EMIFAT  = GW3.GW3_EMIFAT
   AND GW6.GW6_SERFAT  = GW3.GW3_SERFAT
   AND GW6.GW6_NRFAT   = GW3.GW3_NRFAT
LEFT JOIN [STAGE].[gfe].[GWM] GWM
    ON GW3.EMPRESA     = GWM.EMPRESA
   AND GW3.GW3_FILIAL  = GWM.GWM_FILIAL
   AND GW3.GW3_SERDF   = GWM.GWM_SERDOC
   AND GW3.GW3_NRDF    = GWM.GWM_NRDOC
   AND GW3.GW3_EMISDF  = GWM.GWM_CDTRP
  WHERE GWM_NRDC='1328020';
