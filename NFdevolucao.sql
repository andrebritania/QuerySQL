SELECT [GWM_CDTRP] AS CodigoTransp
      ,[GWM_SERDOC] AS SerieCTE
      ,[GWM_NRDOC] AS NumeroCTE
      ,[GWM_DTEMIS] AS EmissaoCTE
      ,[GWM_CDTPDC] AS TipoNF
      ,[GWM_EMISDC] AS EmissorNF
      ,[GWM_SERDC] AS SerieNF
      ,[GWM_NRDC] AS NumeroNF
      ,[GWM_DTEMDC] AS EmissaoNF
      ,[GWM_ITEM]   AS CodItem  
      ,[GWM_CTFRET] AS ContaContabil
      ,[GWM_CCFRET] AS CentroCusto
      ,[GWM_VLFRE1] AS TotalFrete      
  FROM [STAGE].[gfe].[GWM]
  where GWM_CCFRET='23121'
  AND GWM_DTEMDC > '20250101'
