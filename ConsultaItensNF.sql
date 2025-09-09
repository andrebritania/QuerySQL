SELECT TOP (1000)
    nf.[it-codigo],
    dim.[DescItem] AS [descricao-item],
    nf.[cod-estabel],
    nf.[serie],
    nf.[nr-nota-fis],
    nf.[peso-bruto],
    nf.[peso-liq-fat],
    nf.[nome-ab-cli],
    nf.[nr-seq-fat],
    nf.[baixa-estoq],
   
    
    FORMAT(nf.[qtFaturada], 'N2', 'pt-BR') AS [qtFaturada_BR],
FORMAT(nf.[vl-preuni], 'C2', 'pt-BR') AS [vl-preuni_BR],
FORMAT(nf.[vl-tot-item], 'C2', 'pt-BR') AS [vl-tot-item_BR],

    nf.[nr-pedcli],
    
    nf.[dtEmisNota],
    
    nf.[STATUS_REGISTRO],
    nf.[DATA_ALTERACAO]
    
FROM [STAGE].[tot].[ItNotaFisc] nf
LEFT JOIN [DW].[dbo].[Dim_Item] dim
    ON nf.[it-codigo] = dim.[CodItem]
WHERE nf.[nr-nota-fis] = '0025936'
and serie='75'
