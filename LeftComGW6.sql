WITH GWM_FILTRADO AS (
    SELECT
        GWM_NRDC,
        GWM_SERDC,
        GWM_VLFRE1,
        GWM_TPDOC,
        GWM_CDESP,
        GWM_CDTRP,
        GWM_SERDOC,
        GWM_NRDOC,
        GWM_DTEMDC,
        GWM_DTEMIS,
        GWM_CDTPDC,
        GWM_EMISDC,
        GWM_CTFRET,
        GWM_CCFRET,
        EMPRESA,
        GWM_FILIAL,
        DataCarga
    FROM [STAGE].[gfe].[GWM] WITH (NOLOCK)
    WHERE 
        GWM_CCFRET = '23210'
        AND GWM_DTEMIS BETWEEN '2020-06-01' AND '2025-06-30'
        AND GWM_SERDC IN ('5','21')
        AND GWM_TPDOC = '2'
),
GWM_AGREGADO AS (
    SELECT 
        GWM_NRDC AS NumeroNF,
        MAX(GWM_SERDC) AS SerieNF,
        SUM(GWM_VLFRE1) AS FreteCobrado,
        CASE MAX(GWM_TPDOC)
            WHEN 1 THEN 'Calculado'
            WHEN 2 THEN 'Cobrado'
            ELSE 'Outro'
        END AS SitDocFrete,
        MAX(GWM_CDESP) AS EspecieDocCob,
        MAX(GWM_CDTRP) AS TranspCalculo,
        MAX(GWM_SERDOC) AS SerieCTE,
        MAX(GWM_NRDOC) AS NumeroCTE,
        MAX(GWM_DTEMDC) AS EmissaoNF,
        MAX(GWM_DTEMIS) AS EmissaoCTE,
        MAX(GWM_CDTPDC) AS TipoDocCarga,
        MAX(GWM_EMISDC) AS EmissorNF,
        MAX(GWM_CTFRET) AS ContaContabil,
        MAX(GWM_CCFRET) AS CentroCusto,
        MAX(EMPRESA) AS Empresa,
        MAX(GWM_FILIAL) AS Filial,
        MAX(DataCarga) AS DataCarga
    FROM GWM_FILTRADO
    GROUP BY GWM_NRDC
),
FATURAMENTO_AGREGADO AS (
    SELECT 
        NumeroNotaFiscal,
        SerieNotaFiscal,
        CAST(SUM(QuantidadeFaturada) AS INT) AS QuantidadeFaturada,
        MAX(TipoFrete) AS TipoFrete
    FROM [DW].[dbo].[Fato_Faturamento] WITH (NOLOCK)
    GROUP BY NumeroNotaFiscal, SerieNotaFiscal
),
GW6_BASE AS (
    SELECT 
        GW6_NRFAT,
        GW6_SERFAT,
        GW6_EMIFAT,
        GW6_VLFATU,
        GW6_SITFIN,
        GW6_DTVENC,
        GW6_DTFIN
    FROM [gfe].[GW6] WITH (NOLOCK)
    WHERE GW6_DTFIN BETWEEN '2025-06-01' AND '2025-06-30'
),
GW3_BASE AS (
    SELECT 
        GW3_NRDF,
        GW3_SERDF,
        GW3_EMISDF,
        GW3_USUIMP,
        GW3_VLDF,
        GW3_TAXAS,
        GW3_FRPESO,
        GW3_FRVAL,
        GW3_PEDAG,
        GW3_PESOR,
        GW3_VLIMP,
        GW3_MOTAPR,
        GW3_MOTBLQ,
        GW3_DTBLQ,
        GW3_USUBLQ,
        GW3_DTAPR,
        GW3_USUAPR,
        GW3_EMIFAT,
        GW3_SERFAT,
        GW3_NRFAT,
        GW3_DTEMFA,
        GW3_VLDIV,
        GW3_SIT,
        GW3_TPDF
    FROM [gfe].[GW3] WITH (NOLOCK)
)

SELECT 
    G6.GW6_VLFATU,
    CONVERT(VARCHAR(10), G6.GW6_DTVENC, 103) AS DtVencimento,
    G6.GW6_SITFIN,
    CONVERT(VARCHAR(10), G6.GW6_DTFIN, 103) AS DataFinanceiro,

    -- GW3
    W.GW3_EMISDF,
    W.GW3_SERDF,
    W.GW3_NRDF,
    W.GW3_USUIMP,
    W.GW3_VLDF AS ValorCTE,
    W.GW3_TAXAS,
    W.GW3_FRPESO,
    W.GW3_FRVAL,
    W.GW3_PEDAG,
    W.GW3_PESOR AS Peso,
    W.GW3_VLIMP,
    CAST(CAST(W.GW3_MOTAPR AS VARBINARY(MAX)) AS VARCHAR(MAX)) AS DescMotAprovacao,
    CAST(CAST(W.GW3_MOTBLQ AS VARBINARY(MAX)) AS VARCHAR(MAX)) AS DescMotBloqueio,
    W.GW3_DTBLQ,
    W.GW3_USUBLQ,
    CONVERT(VARCHAR(10), W.GW3_DTAPR, 103) AS DtAprovacaoFatura,
    W.GW3_USUAPR,
    W.GW3_EMIFAT,
    W.GW3_SERFAT,
    W.GW3_NRFAT,
    CONVERT(VARCHAR(10), W.GW3_DTEMFA, 103) AS DtEmissaoFatura,
    W.GW3_VLDIV,
    CASE W.GW3_SIT
        WHEN 1 THEN 'Recebido' 
        WHEN 2 THEN 'Bloqueado'
        WHEN 3 THEN 'Aprov.Sistema'
        WHEN 4 THEN 'Aprov.Usuario'
        WHEN 5 THEN 'BloqueadoEntrega'
        ELSE 'check' 
    END AS SituacaoFatura,
    CASE W.GW3_TPDF
        WHEN 1 THEN 'Frete Normal' 
        WHEN 2 THEN 'Complementar Valor'
        WHEN 3 THEN 'Complementar Imposto'
        WHEN 4 THEN 'Reentrega'
        WHEN 5 THEN 'Devolucao'
        WHEN 6 THEN 'Redespacho'
        ELSE 'Servico' 
    END AS TipoServico,

    -- GWM
    G.*,

    -- Nota
    N.[qt-volumes],
    CASE WHEN N.[qt-volumes] IS NULL THEN 'COMPLEMENTO' ELSE 'MASTER' END AS TipoNota,
    NF.[cidade],
    NF.[estado],
    NF.[cdd-embarq],
    FORMAT(NF.[vl-tot-nota], 'C', 'pt-BR') AS [vl-tot-nota-R$],

    -- Faturamento
    F.QuantidadeFaturada,
    F.TipoFrete,

    -- Embarque
    E.[peso-bru-tot],
    E.[peso-liq-tot],

    -- Transportadora
    T.NomeAbrev AS Transportadora,
    TR.[cod-transp]

FROM GW6_BASE G6
LEFT JOIN GW3_BASE W
    ON G6.GW6_NRFAT = W.GW3_NRFAT
   AND G6.GW6_SERFAT = W.GW3_SERFAT
   AND G6.GW6_EMIFAT = W.GW3_EMIFAT

LEFT JOIN GWM_AGREGADO G
    ON G.NumeroCTE = W.GW3_NRDF
   AND G.SerieCTE = W.GW3_SERDF
   AND G.TranspCalculo = W.GW3_EMISDF

LEFT JOIN [tot].[Notaembal] N WITH (NOLOCK)
    ON N.[nr-nota-fis] = G.NumeroNF AND N.[serie] = G.SerieNF

LEFT JOIN [tot].[notafiscal] NF WITH (NOLOCK)
    ON NF.[nr-nota-fis] = G.NumeroNF AND NF.[serie] = G.SerieNF

LEFT JOIN [tot].[Embarque] E WITH (NOLOCK)
    ON E.[cdd-embarq] = NF.[cdd-embarq]

LEFT JOIN FATURAMENTO_AGREGADO F
    ON F.NumeroNotaFiscal = G.NumeroNF AND F.SerieNotaFiscal = G.SerieNF

LEFT JOIN dw..Dim_Emitente T WITH (NOLOCK)
    ON T.CodEmitente = W.GW3_EMIFAT

LEFT JOIN [tot].[Transporte] TR WITH (NOLOCK)
    ON T.Cgc = TR.Cgc

WHERE 
    G.CentroCusto = '23210'
    AND G.SerieNF IN ('5','21')
