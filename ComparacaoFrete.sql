SELECT 
    f.[IdEstab],
    f.[SerieNotaFiscal],
    f.[NumeroNotaFiscal],
    f.[SituacaoNota],
    f.[IdDataSaida],
    f.[IdDataEntrega],
    f.[IdDataCancelamento],
    f.[CidadeDestino],
    f.[EstadoDestino],
    f.[VlFretePrevisto],
    f.[VlFretePago],
    FORMAT(f.[VlFretePrevisto] - f.[VlFretePago], 'C', 'pt-BR') AS DiferencaFrete,   
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
    END AS [NF/Embarque]
FROM [DW].[auditoria].[Fato_CustosFrete_Faturamento] f
LEFT JOIN [stage].[tot].[NotaEmbal] ne
    ON f.[NumeroNotaFiscal] = ne.[nr-nota-fis]
   AND f.[SerieNotaFiscal] = ne.[serie]
LEFT JOIN [stage].[tot].[NotaFiscal] nf
    ON f.[NumeroNotaFiscal] = nf.[nr-nota-fis]
   AND f.[SerieNotaFiscal] = nf.[serie]
WHERE f.[CodigoFrete] = '23210'
  AND f.[DataEmissaoNotaFiscal] > '2025-01-01'
ORDER BY f.[DataEmissaoNotaFiscal] DESC;