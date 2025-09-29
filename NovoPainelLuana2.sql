SELECT TOP (10)
    F.[SerieNotaFiscal],
    F.[NumeroNotaFiscal],
    F.[DataEmissaoNotaFiscal],
    F.[SituacaoNota],
    N.[NatOperacao],
    N.[Denominacao],
    DS.[Data] AS DataSaida,
    DE.[Data] AS DataEntrega,
    DC.[Data] AS DataCancelamento,
    DP.[Data] AS DataPrevisEntrega,
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
    F.[DataCarga],
    F.[NomeMatrizTransportador],
    F.[CodigoFrete],
    F.[DataEnvioFinanceiro],
    PDB.[NumeroPedido],
    PDB.[NomeMatriz],
    PDB.[NumeroOS],
    GV6.GV6_QTPRAZ AS TransTime
FROM [DW].[auditoria].[Fato_CustosFrete_Faturamento] F
LEFT JOIN [DW].[dbo].[Dim_Natureza] N
    ON F.[IdNatureza] = N.[IdNatureza]
LEFT JOIN [DW].[dbo].[Dim_Representante] R
    ON F.[IdRepresentante] = R.[Id]
LEFT JOIN [DW].[dbo].[Dim_Data] DS
    ON F.[IdDataSaida] = DS.[Id]
LEFT JOIN [DW].[dbo].[Dim_Data] DE
    ON F.[IdDataEntrega] = DE.[Id]
LEFT JOIN [DW].[dbo].[Dim_Data] DC
    ON F.[IdDataCancelamento] = DC.[Id]
LEFT JOIN [DW].[dbo].[Dim_Data] DP
    ON F.[IdDataPrevisEntrega] = DP.[Id]
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
LEFT JOIN STAGE.gfe.GWH nrclc
    ON F.SerieNotaFiscal = nrclc.GWH_SERDC AND F.NumeroNotaFiscal = nrclc.GWH_NRDC
LEFT JOIN STAGE.gfe.GWG gwgchv
    ON nrclc.GWH_NRCALC = gwgchv.GWG_NRCALC
LEFT JOIN STAGE.gfe.GV6 GV6
    ON gwgchv.GWG_NRTAB = GV6.GV6_NRTAB
    AND gwgchv.GWG_NRNEG = GV6.GV6_NRNEG
    AND gwgchv.GWG_CDFXTV = GV6.GV6_CDFXTV
    AND gwgchv.GWG_NRROTA = GV6.GV6_NRROTA
    AND gwgchv.GWG_CDEMIT = GV6.GV6_CDEMIT
WHERE F.[IdEstab] = 8
  AND F.[SerieNotaFiscal] IN (5, 21)
  AND F.[DataEmissaoNotaFiscal] BETWEEN '2025-09-01' AND GETDATE()
  AND F.[SituacaoNota] = 'Faturada'
  AND F.[IdDataCancelamento] IS NULL
  AND nrclc.D_E_L_E_T_ = ''
  AND GV6.D_E_L_E_T_ = ''