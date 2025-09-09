SELECT 
    NF.[cod-estabel],
    NF.[SERIE],
    NF.[nr-nota-fis],
    NF.[dt-emis-nota],
    NF.[idi-sit-nf-eletro],
    NF.[cod-chave-aces-nf-eletro],
    NF.[vl-tot-nota],
    NF.[nome-transp],
    NF.[cod-emitente],
    NF.[nome-ab-cli],
    NF.[nat-operacao],
    NF.[dt-saida],
    NF.[dt-entr-cli],
    NF.[cidade],
    NF.[estado],    
    NF.[ind-tip-nota],
    NF.[esp-docto],
    NF.[cod-cond-pag],
    CP.[descricao],
    NF.[observ-nota],     
    NF.[ind-sit-nota],
    NF.[emite-duplic],         
    NF.[vl-frete],
    NF.[ind-tp-frete],
    NF.[DataCarga]     
FROM [STAGE].[tot].[NotaFiscal] NF
LEFT JOIN [STAGE].[tot].[CondPagto] CP
    ON NF.[cod-cond-pag] = CP.[codCondpag]
WHERE NF.[cod-estabel] = '15'
  AND NF.[SERIE] = '6'
