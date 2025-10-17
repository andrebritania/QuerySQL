SELECT 
    NF.[SERIE] AS SerieNF,
    NF.[nr-nota-fis] AS NumeroNF,
    NF.[dt-emis-nota] AS EmissaoNF,
    NF.[idi-sit-nf-eletro],
    NF.[cod-chave-aces-nf-eletro] AS ChaveAcesso,
    NF.[vl-tot-nota] AS ValorCobrado,
    NF.[cod-emitente] AS CodTransportadora,
    NF.[nome-ab-cli] AS Transportadora,
    NF.[nat-operacao] AS NaturezaOperacao,
    NF.[dt-saida] AS DataSaida,
    NF.[dt-entr-cli] AS DataEntregaCliente,
    NF.[cidade] AS Cidade,
    NF.[estado] AS Estado,    
    NF.[ind-tip-nota],
    NF.[esp-docto],
    NF.[cod-cond-pag],
    CP.[descricao] AS TipoPagamento,
    NF.[observ-nota] AS Observacoes,     
    NF.[ind-sit-nota],
    NF.[emite-duplic],         
    NF.[vl-frete],
    NF.[ind-tp-frete],
    NF.[DataCarga],
    NF.[nome-transp],
    IT.[it-codigo] AS CodItem
FROM [STAGE].[tot].[NotaFiscal] NF
LEFT JOIN [STAGE].[tot].[CondPagto] CP
    ON NF.[cod-cond-pag] = CP.[codCondpag]
LEFT JOIN [STAGE].[tot].[ItNotaFisc] IT
    ON NF.[cod-estabel] = IT.[cod-estabel]
    AND NF.[SERIE] = IT.[serie]
    AND NF.[nr-nota-fis] = IT.[nr-nota-fis]
WHERE NF.[cod-estabel] = '15'
  
  AND NF.[dt-cancela] IS NULL
  AND NF.[dt-emis-nota] > '2025-01-01'
  AND NF.[cod-cond-pag] = '11'
  AND (NF.[nome-transp] IS NULL OR LTRIM(RTRIM(NF.[nome-transp])) = '')
