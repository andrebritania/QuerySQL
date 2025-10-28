SELECT 
    YEAR(F.[DataEmissaoNotaFiscal]) AS AnoReferencia,
    FORMAT(F.[DataEmissaoNotaFiscal], 'MMM', 'pt-BR') AS MesReferencia,
    
    FORMAT(SUM(CASE 
        WHEN UPPER(LEFT(LTRIM(I.[DescItem]), CHARINDEX(' ', LTRIM(I.[DescItem]) + ' ') - 1)) = 'DISPLAY' THEN ITNF.[qtFaturada]
        ELSE 0
    END), 'N0', 'pt-BR') AS QtdeDisplay,

    FORMAT(SUM(CASE 
        WHEN LEFT(ITNF.[it-codigo], 2) IN ('03', '05', '06', '09', '10') THEN ITNF.[qtFaturada]
        ELSE 0
    END), 'N0', 'pt-BR') AS QtdeProdutoAcabado,

    FORMAT(SUM(CASE 
        WHEN UPPER(LEFT(LTRIM(I.[DescItem]), CHARINDEX(' ', LTRIM(I.[DescItem]) + ' ') - 1)) <> 'DISPLAY'
             AND LEFT(ITNF.[it-codigo], 2) NOT IN ('03', '05', '06', '09', '10') THEN ITNF.[qtFaturada]
        ELSE 0
    END), 'N0', 'pt-BR') AS QtdePeca

FROM [DW].[auditoria].[Fato_CustosFrete_Faturamento] F
LEFT JOIN [STAGE].[tot].[ItNotaFisc] ITNF
    ON F.[SerieNotaFiscal] = ITNF.[serie]
    AND F.[NumeroNotaFiscal] = ITNF.[nr-nota-fis]
LEFT JOIN [DW].[dbo].[Dim_Item] I
    ON ITNF.[it-codigo] = I.[CodItem]
WHERE F.[IdEstab] = 8
  AND F.[SerieNotaFiscal] IN (5, 21)
  AND F.[DataEmissaoNotaFiscal] >= '2022-01-01'
  AND F.[SituacaoNota] = 'Faturada'
  AND F.[IdDataCancelamento] IS NULL
  AND F.TipoFrete='1 - CIF'
   AND (
        F.NomeMatrizTransportador NOT LIKE '%Correio%' 
        AND F.NomeMatrizTransportador NOT LIKE '%J.J. SUL SC%'
      )
GROUP BY 
    YEAR(F.[DataEmissaoNotaFiscal]),
    FORMAT(F.[DataEmissaoNotaFiscal], 'MMM', 'pt-BR'),
    DATEPART(MONTH, F.[DataEmissaoNotaFiscal])
ORDER BY AnoReferencia, DATEPART(MONTH, F.[DataEmissaoNotaFiscal]);