SELECT 
    [NumeroPedido],
    [CodEmitente],
    [NomeMatriz],
    COUNT(DISTINCT [Embarque]) AS TotalEmbarquesDistintos
FROM [DW].[logistica].[Fato_PDB381]
WHERE [DataImplantacao] > '2025-11-01'
GROUP BY 
    [NumeroPedido],
    [CodEmitente],
    [NomeMatriz]
ORDER BY TotalEmbarquesDistintos DESC;