WITH FaturamentoDetalhado AS (
    SELECT 
        f.[SerieNotaFiscal],
        f.[NumeroNotaFiscal],
        f.NomeMatrizTransportador AS TransportadoraRomaneio,
        f.[CidadeDestino],
        f.[EstadoDestino],
        f.[VlFretePago],
        f.[TotalNota],
        f.[DataEmissaoNotaFiscal],
        f.[PesoBruto],
        f.[DataEnvioFinanceiro],        
        CASE 
            WHEN ne.[qt-volumes] IS NULL OR ne.[qt-volumes] = 0 THEN 'COMPLEMENTO'
            ELSE 'MASTER'
        END AS TipoNota,

        nf.[cdd-embarq],
        gw4.[GW4_NRDF] AS NumCTE,
        gw3.[GW3_VLDF] AS ValorCTE,
        gw3.[GW3_NRFAT] AS NumFatura,
        gw3.[GW3_EMIFAT] AS EmpresaFatura,
        FORMAT(CONVERT(DATE, gw3.[GW3_DTEMFA]), 'dd/MM/yyyy') AS DataFatura,
        gw3.[GW3_PESOR] AS PesoReal,
        gw3.[GW3_EMISDF] AS CodigoEmissor,
        gw3.[GW3_EMIFAT] AS CodigoCentroFaturamento,       
        emit.NomeAbrev AS TransportadoraFatura,
        CASE 
            WHEN nf.[cdd-embarq] IS NOT NULL AND nf.[cdd-embarq] <> 0 THEN 
                (SELECT COUNT(*) 
                 FROM [stage].[tot].[NotaFiscal] nf2
                 WHERE nf2.[cdd-embarq] = nf.[cdd-embarq])
            ELSE NULL
        END AS [NF/Embarque]

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
    LEFT JOIN [DW].[dbo].[Dim_Emitente] emit
        ON emit.[CodEmitente] = gw3.[GW3_EMIFAT]

    WHERE f.[CodigoFrete] = '23210'
      AND f.[DataEmissaoNotaFiscal] BETWEEN '2025-01-01' AND '2025-12-31'      
)
SELECT 
    SerieNotaFiscal,
    NumeroNotaFiscal,
    TransportadoraRomaneio,
    CidadeDestino,
    EstadoDestino,
    VlFretePago,
    TotalNota,
    DataEmissaoNotaFiscal,
    PesoBruto,
    DataEnvioFinanceiro,
    TipoNota,
    [cdd-embarq],
    NumCTE,
    ValorCTE,
    NumFatura,
    EmpresaFatura,
    TransportadoraFatura,
    DataFatura
FROM FaturamentoDetalhado
WHERE [NF/Embarque] > 1
ORDER BY NumeroNotaFiscal ASC;
