WITH FaturamentoDetalhado AS (
    SELECT 
        f.[IdEstab],
        f.[SerieNotaFiscal],
        f.[NumeroNotaFiscal],
        f.[SituacaoNota],
        CAST(ds.[Data] AS DATE) AS DataSaida,
        CAST(de.[Data] AS DATE) AS DataEntrega,
        CAST(dc.[Data] AS DATE) AS DataCancelamento,

        f.[CidadeDestino],
        f.[EstadoDestino],
        
        f.[VlFretePago],
        f.[TotalNota],
        f.[TotalDevolvido],
        f.[TotalDevolvidoSemSt],
        f.[QuantidadeFaturada],
        f.[QuantidadeDevolvida],
        f.[ValorFreteDevolucao],
        f.[DataEmissaoNotaFiscal],
        f.[PesoBruto],
        f.[NomeTransportadoraNF],
        f.[NomeMatrizTransportador],
        f.[CodigoFrete],
        f.[DataEnvioFinanceiro],
        
        dn.[NatOperacao],
        dn.[Denominacao],
        CASE 
            WHEN dn.[Denominacao] LIKE '%VENDA%' THEN 'VENDA'
            WHEN dn.[Denominacao] LIKE '%GARANTIA%' THEN 'GARANTIA'
            ELSE 'OUTROS'
        END AS TipoOperacao,

        ne.[qt-volumes],
        CASE 
            WHEN ne.[qt-volumes] IS NULL OR ne.[qt-volumes] = 0 THEN 'COMPLEMENTO'
            ELSE 'MASTER'
        END AS TipoNota,
        nf.[cdd-embarq],
        CASE 
            WHEN nf.[cdd-embarq] IS NOT NULL AND nf.[cdd-embarq] <> 0 THEN 
                (SELECT COUNT(*) 
                 FROM [stage].[tot].[NotaFiscal] nf2
                 WHERE nf2.[cdd-embarq] = nf.[cdd-embarq])
            ELSE NULL
        END AS [NF/Embarque],
        gw4.[GW4_NRDF] AS NumCTE,
        gw3.[GW3_VLDF] AS ValorCTE,
        gw3.[GW3_NRFAT] AS NumFatura,
        gw3.[GW3_EMIFAT] AS EmpresaFatura,
        gw3.[GW3_SERFAT] AS SerieFatura,
        gw3.[GW3_DTEMFA] AS DataFatura,
        gw3.[GW3_PESOR] AS PesoReal,
        gw3.[GW3_VLDIV] AS ValorDiverg
    FROM [DW].[auditoria].[Fato_CustosFrete_Faturamento] f
    LEFT JOIN [stage].[tot].[NotaEmbal] ne
        ON f.[NumeroNotaFiscal] = ne.[nr-nota-fis]
       AND f.[SerieNotaFiscal] = ne.[serie]
    LEFT JOIN [stage].[tot].[NotaFiscal] nf
        ON f.[NumeroNotaFiscal] = nf.[nr-nota-fis]
       AND f.[SerieNotaFiscal] = nf.[serie]
    LEFT JOIN [gfe].[gw4] gw4
        ON f.[NumeroNotaFiscal] = gw4.[GW4_NRDC]
       AND f.[SerieNotaFiscal] = gw4.[GW4_SERDC]
    LEFT JOIN [gfe].[gw3] gw3
        ON gw4.EMPRESA    = gw3.EMPRESA
       AND gw4.GW4_FILIAL = gw3.GW3_FILIAL
       AND gw4.GW4_EMISDF = gw3.GW3_EMISDF
       AND gw4.GW4_SERDF  = gw3.GW3_SERDF
       AND gw4.GW4_NRDF   = gw3.GW3_NRDF
       AND gw4.GW4_DTEMIS = gw3.GW3_DTEMIS
    LEFT JOIN [DW].[dbo].[Dim_Natureza] dn
        ON f.[IdNatureza] = dn.[IdNatureza]
    LEFT JOIN [DW].[dbo].[Dim_Data] ds
        ON f.[IdDataSaida] = ds.[ID]
    LEFT JOIN [DW].[dbo].[Dim_Data] de
        ON f.[IdDataEntrega] = de.[ID]
    LEFT JOIN [DW].[dbo].[Dim_Data] dc
        ON f.[IdDataCancelamento] = dc.[ID]
    WHERE f.[CodigoFrete] = '23210'
      AND f.[DataEmissaoNotaFiscal] BETWEEN '2025-06-01' AND '2025-12-31' 
      AND f.[SerieNotaFiscal] = '5'
      AND dn.[Denominacao] LIKE '%VENDA%'
      AND f.[VlFretePago] <> 0
     
)
SELECT *
FROM FaturamentoDetalhado
ORDER BY NumeroNotaFiscal ASC;
