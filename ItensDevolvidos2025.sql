SELECT 
    fcff.[ChaveNFe],
    ff.[DataEmissaoNotaFiscal],
    ff.[IdEstab],    
    di.[CodItem],
    di.[DescItem],
    ff.[NumeroNotaFiscal],
    ff.[SerieNotaFiscal],    
    ff.[DataSaida],     
    ff.[QuantidadeDevolvida],   
    dd.[CodigoDeposito]    
FROM [DW].[dbo].[Fato_Faturamento] ff
LEFT JOIN [DW].[dbo].[Dim_Item] di
    ON ff.[IdItem] = di.[Id]
LEFT JOIN [DW].[dbo].[Dim_Deposito] dd
    ON ff.[IdDeposito] = dd.[IdDeposito]
LEFT JOIN [DW].[auditoria].[Fato_CustosFrete_Faturamento] fcff
    ON ff.[NumeroNotaFiscal] = fcff.[NumeroNotaFiscal]
   AND ff.[SerieNotaFiscal] = fcff.[SerieNotaFiscal]
   AND ff.[IdEstab] = fcff.[IdEstab]
WHERE ff.[DataEmissaoNotaFiscal] > '2025-01-01'
  AND ff.[QuantidadeDevolvida] > 0
  AND ff.[IdEstab] = '8'
  AND ff.[SerieNotaFiscal] IN ('5', '21');
