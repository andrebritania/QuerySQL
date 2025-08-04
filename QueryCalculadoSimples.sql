WITH GWM_FILTRADO AS (
    SELECT *
    FROM [STAGE].[gfe].[GWM] WITH (NOLOCK)
    WHERE 
        GWM_CCFRET = '23210'
        AND GWM_DTEMIS BETWEEN '2024-06-01' AND '2025-06-30'
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
        CONVERT(VARCHAR(10), MAX(CAST(GWM_DTEMDC AS DATE)), 103) AS EmissaoNF,
        CONVERT(VARCHAR(10), MAX(CAST(GWM_DTEMIS AS DATE)), 103) AS EmissaoCTE,
        MAX(GWM_CDTPDC) AS TipoDocCarga,
        MAX(GWM_EMISDC) AS EmissorNF,
        MAX(GWM_CTFRET) AS ContaContabil,
        MAX(GWM_CCFRET) AS CentroCusto,
        -- [Demais colunas de agregação omitidas aqui por brevidade]
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
)


SELECT 
    G.*,
    N.[qt-volumes],
    CASE 
        WHEN N.[qt-volumes] IS NULL THEN 'COMPLEMENTO'
        ELSE 'MASTER'
    END AS TipoNota,
    NF.[cidade],
    NF.[estado],
    NF.[cdd-embarq],
    FORMAT(NF.[vl-tot-nota], 'C', 'pt-BR') AS [vl-tot-nota-R$],
	F.QuantidadeFaturada,
    F.TipoFrete,


    -- Colunas da tabela GW3
    W.[GW3_EMISDF],
    W.[GW3_SERDF],
    W.[GW3_NRDF],
    W.[GW3_USUIMP],
    W.[GW3_VLDF] AS ValorCTE,
    W.[GW3_TAXAS],
    W.[GW3_FRPESO],
    W.[GW3_FRVAL],
    W.[GW3_PEDAG],
    W.[GW3_PESOR],
    W.[GW3_VLIMP],
    CAST(CAST(W.[GW3_MOTAPR] AS VARBINARY(MAX)) AS VARCHAR(MAX)) AS DescMotAprovacao,
    CAST(CAST(W.[GW3_MOTBLQ] AS VARBINARY(MAX)) AS VARCHAR(MAX)) AS DescMotBloqueio,
    W.[GW3_DTBLQ],
    W.[GW3_USUBLQ],
    W.[GW3_DTAPR],
    W.[GW3_USUAPR],
    W.[GW3_EMIFAT],
    W.[GW3_SERFAT],
    W.[GW3_NRFAT],
    W.[GW3_DTEMFA],
    W.[GW3_VLDIV],
    CASE 
        WHEN W.GW3_SIT = 1 THEN 'Recebido' 
        WHEN W.GW3_SIT = 2 THEN 'Bloqueado'
        WHEN W.GW3_SIT = 3 THEN 'Aprov.Sistema'
        WHEN W.GW3_SIT = 4 THEN 'Aprov.Usuario'
        WHEN W.GW3_SIT = 5 THEN 'BloqueadoEntrega'
        ELSE 'check' 
    END AS SituacaoFatura,
	case 
when w.GW3_TPDF = 1 then 'Frete Normal' 
when w.GW3_TPDF = 2 then 'Complementar Valor'
when w.GW3_TPDF = 3 then 'Complementar Imposto'
when w.GW3_TPDF = 4 then 'Reentrega'
when w.GW3_TPDF = 5 then 'Devolucao'
when w.GW3_TPDF = 6 then 'Redespacho'
else 'Servico' end as 'TipoServico',

    -- Colunas da tabela Embarque
    E.[peso-bru-tot],
    E.[peso-liq-tot],

    -- Colunas da tabela GW6
    G6.GW6_DTVENC,
    G6.GW6_VLFATU,
    G6.GW6_SITFIN,
    CONVERT(VARCHAR(10), (CAST(G6.GW6_DTFIN AS DATE)), 103) AS DataFinanceiro

FROM 
    GWM_AGREGADO G
LEFT JOIN 
    [tot].[Notaembal] N WITH (NOLOCK)
    ON N.[nr-nota-fis] = G.NumeroNF
   AND N.[serie] = G.SerieNF
LEFT JOIN 
    [tot].[notafiscal] NF WITH (NOLOCK)
    ON NF.[nr-nota-fis] = G.NumeroNF
   AND NF.[serie] = G.SerieNF
LEFT JOIN 
    [gfe].[gw3] W WITH (NOLOCK)
    ON W.[GW3_NRDF] = G.NumeroCTE
   AND W.[GW3_SERDF] = G.SerieCTE
   AND W.[GW3_EMISDF] = G.TranspCalculo
LEFT JOIN 
    [tot].[Embarque] E WITH (NOLOCK)
    ON E.[cdd-embarq] = NF.[cdd-embarq]
LEFT JOIN 
    [gfe].[GW6] G6 WITH (NOLOCK)
    ON G6.GW6_NRFAT = W.GW3_NRFAT
   AND G6.GW6_SERFAT = W.GW3_SERFAT
   AND G6.GW6_EMIFAT = W.GW3_EMIFAT
LEFT JOIN FATURAMENTO_AGREGADO F
    ON F.NumeroNotaFiscal = G.NumeroNF
   AND F.SerieNotaFiscal = G.SerieNF


WHERE 
    G.CentroCusto = '23210'
    AND G.SerieNF IN ('5','21')
    AND G6.GW6_DTFIN BETWEEN '2025-06-01' AND '2025-06-30'
