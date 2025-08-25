SELECT [IdEstab]
      ,[SerieNotaFiscal]
      ,[NumeroNotaFiscal]
     
      ,[SituacaoNota]
      ,[IdNatureza]
      ,[IdEmitente]
      ,[IdDataEmissao]
      ,[IdDataSaida]
      ,[IdDataEntrega]
      ,[IdDataCancelamento]
      ,[IdHierarquia]
     
      ,[CidadeDestino]
      ,[EstadoDestino]
      ,[VlFretePrevisto]
      ,[VlFretePago]
      ,[TotalNota]
     
      ,[QuantidadeFaturada]
      
      ,[DataEmissaoNotaFiscal]
     
      
      
      ,[PesoBruto]
      ,[Ocorrencia]
      
      ,[NomeMatrizTransportador]
      
      ,[CodigoFrete]
      ,[Descricao]
      ,[DataEnvioFinanceiro]
  FROM [DW].[auditoria].[Fato_CustosFrete_Faturamento]
  where SerieNotaFiscal in ('5','21')
  and IdDataEmissao > '6392'
  and IdEstab='8'