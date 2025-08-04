WITH GWM_FILTRADO AS (
    SELECT *
    FROM [STAGE].[gfe].[GWM] WITH (NOLOCK)
    WHERE 
        GWM_CCFRET = '23210'
        AND GWM_DTEMIS BETWEEN '2025-06-01' AND '2025-06-30'
        AND GWM_SERDC IN ('5','21')
		AND GWM_TPDOC='1'
)

, GWM_AGREGADO AS (
    SELECT 
        GWM_NRDC AS NumeroNF,
        MAX(GWM_SERDC) AS SerieNF, -- necessário para o join

        -- Demais colunas fixas
        
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
        
        MAX(GWM_CTFRET) AS  ContaContabil,
        MAX(GWM_CCFRET) AS CentroCusto,
        
       

        -- Somatórios
        SUM(GWM_VLINAU) AS VLINAU,
        SUM(GWM_VLINEM) AS VLINEM,
        SUM(GWM_VLIRRF) AS VLIRRF,
        SUM(GWM_VLSEST) AS VLSEST,
        SUM(GWM_VLISS) AS VLISS,
        SUM(GWM_VLICMS) AS VLICMS,
        SUM(GWM_VLPIS) AS VLPIS,
        SUM(GWM_VLCOFI) AS VLCOFI,
        SUM(GWM_VLFRET) AS VLFRET,
        SUM(GWM_VLINA1) AS VLINA1,
        SUM(GWM_VLINE1) AS VLINE1,
        SUM(GWM_VLIRR1) AS VLIRR1,
        SUM(GWM_VLSES1) AS VLSES1,
        SUM(GWM_VLISS1) AS VLISS1,
        SUM(GWM_VLICM1) AS VLICM1,
        SUM(GWM_VLPIS1) AS VLPIS1,
        SUM(GWM_VLCOF1) AS VLCOF1,
        SUM(GWM_VLFRE1) AS FreteCobrado,
        SUM(GWM_VLINA2) AS VLINA2,
        SUM(GWM_VLINE2) AS VLINE2,
        SUM(GWM_VLIRR2) AS VLIRR2,
        SUM(GWM_VLSES2) AS VLSES2,
        SUM(GWM_VLISS2) AS VLISS2,
        SUM(GWM_VLICM2) AS VLICM2,
        SUM(GWM_VLPIS2) AS VLPIS2,
        SUM(GWM_VLCOF2) AS VLCOF2,
        SUM(GWM_VLFRE2) AS VLFRE2,
        SUM(GWM_VLINA3) AS VLINA3,
        SUM(GWM_VLINE3) AS VLINE3,
        SUM(GWM_VLIRR3) AS VLIRR3,
        SUM(GWM_VLSES3) AS VLSES3,
        SUM(GWM_VLISS3) AS VLISS3,
        SUM(GWM_VLICM3) AS VLICM3,
        SUM(GWM_VLPIS3) AS VLPIS3,
        SUM(GWM_VLCOF3) AS VLCOF3,
        SUM(GWM_VLFRE3) AS VLFRE3,
        SUM(GWM_PCRAT) AS PCRAT,
        SUM(GWM_PEDAG) AS PEDAG,
        SUM(GWM_PEDAG1) AS PEDAG1,
        SUM(GWM_PEDAG2) AS PEDAG2,
        SUM(GWM_PEDAG3) AS PEDAG3,
		MAX(GWM_UNINEG) AS GWM_UNINEG,
        MAX(GWM_GRP1) AS GWM_GRP1,
        MAX(GWM_GRP3) AS GWM_GRP3,
        MAX(GWM_GRP4) AS GWM_GRP4,
        MAX(GWM_GRP5) AS GWM_GRP5,
        MAX(GWM_GRP6) AS GWM_GRP6,
        MAX(GWM_GRP7) AS GWM_GRP7,
        MAX(GWM_CTINAU) AS GWM_CTINAU,
        MAX(GWM_CCINAU) AS GWM_CCINAU,
        MAX(GWM_CTINEM) AS GWM_CTINEM,
        MAX(GWM_CCINEM) AS GWM_CCINEM,
        MAX(GWM_CTIRRF) AS GWM_CTIRRF,
        MAX(GWM_CCIRRF) AS GWM_CCIRRF,
        MAX(GWM_CTSEST) AS GWM_CTSEST,
        MAX(GWM_CCSEST) AS GWM_CCSEST,
        MAX(GWM_CTISS) AS GWM_CTISS,
        MAX(GWM_CCISS) AS GWM_CCISS,
        MAX(GWM_CTICMS) AS GWM_CTICMS,
        MAX(GWM_CCICMS) AS GWM_CCICMS,
        MAX(GWM_CTPIS) AS GWM_CTPIS,
        MAX(GWM_CCPIS) AS GWM_CCPIS,
        MAX(GWM_CTCOFI) AS GWM_CTCOFI,
        MAX(GWM_CCCOFI) AS GWM_CCCOFI,
		MAX(GWM_SDOCDC) AS GWM_SDOCDC,
		MAX(EMPRESA) AS Empresa,
        MAX(GWM_FILIAL) AS Filial,
        MAX(DataCarga) AS DataCarga

    FROM GWM_FILTRADO
    GROUP BY GWM_NRDC
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
	case 
		when w.GW3_SIT = 1 then 'Recebido' 
		when w.GW3_SIT = 2 then 'Bloqueado'
		when w.GW3_SIT = 3 then 'Aprov.Sistema'
		when w.GW3_SIT = 4 then 'Aprov.Usuario'
		when w.GW3_SIT = 5 then 'BloqueadoEntrega'
		else 'check' end as 'SituacaoFatura',

    -- Colunas da tabela Embarque
    E.[peso-bru-tot],
    E.[peso-liq-tot]

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