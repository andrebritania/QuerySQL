SELECT TOP (10)
    F.[SerieNotaFiscal],
    F.[NumeroNotaFiscal],
    F.[DataEmissaoNotaFiscal],
    F.[SituacaoNota],
    N.[NatOperacao],
    N.[Denominacao],
    F.[IdDataSaida],
    F.[IdDataEntrega],
    F.[IdDataCancelamento],
    R.[NomeAbrev] AS Representante, 
    F.[TipoFrete],
    F.[CidadeDestino],
    F.[EstadoDestino],
    F.[VlFretePrevisto],
    F.[VlFretePago],
    F.[TotalNota],
    F.[QuantidadeFaturada],
    F.[QuantidadeDevolvida],
    F.[QuantidadeAbatida],
    F.[ValorFreteReentrega],
    F.[ValorFreteDevolucao],
    F.[NumeroRomaneio],
    F.[SituacaoCalculo],
    F.[UsuarioCalculo],
    F.[VolumeM3] * 167 AS PesoCubico,
    F.[PesoBruto],
    F.[Ocorrencia],
    F.[ObservacaoCarga],
    F.[ChaveNFe],
    F.[NomeTransportadoraNF],
    F.[IdDataPrevisEntrega],
    F.[DataCarga],
    F.[NomeMatrizTransportador],
    F.[CodigoFrete],
    F.[DataEnvioFinanceiro],
    PDB.[NumeroPedido],
    PDB.[NomeMatriz],
    PDB.[NumeroOS]
FROM [DW].[auditoria].[Fato_CustosFrete_Faturamento] F
LEFT JOIN [DW].[dbo].[Dim_Natureza] N
    ON F.[IdNatureza] = N.[IdNatureza]
LEFT JOIN [DW].[dbo].[Dim_Representante] R
    ON F.[IdRepresentante] = R.[Id]
LEFT JOIN (
    SELECT 
        SerieNotaFiscal,
        NotaFiscal,
        STRING_AGG(NumeroPedido, ' / ') AS NumeroPedido,
        MIN(NomeMatriz) AS NomeMatriz,
        STRING_AGG(NumeroOS, ' / ') AS NumeroOS
    FROM [DW].[logistica].[Fato_PDB381]
    GROUP BY SerieNotaFiscal, NotaFiscal
) PDB
    ON F.SerieNotaFiscal = PDB.SerieNotaFiscal AND F.NumeroNotaFiscal = PDB.NotaFiscal
WHERE F.[IdEstab] = '8'
  AND F.[SerieNotaFiscal] IN (5, 21)
  AND F.[SituacaoNota] = 'Faturada'
  AND F.[DataEmissaoNotaFiscal] BETWEEN '2025-09-01' AND GETDATE()
