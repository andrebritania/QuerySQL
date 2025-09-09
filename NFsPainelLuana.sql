DECLARE @RangeStart DATETIME = '2025-08-01';
DECLARE @RangeEnd DATETIME = GETDATE();

DECLARE @Capitais TABLE (Cidade VARCHAR(50));
INSERT INTO @Capitais (Cidade) VALUES 
    ('RIO BRANCO'), ('MACEIO'), ('MACAPA'), ('MANAUS'), ('SALVADOR'), ('FORTALEZA'), 
    ('BRASILIA'), ('VITORIA'), ('GOIANIA'), ('SAO LUIS'), ('CUIABA'), ('CAMPO GRANDE'), 
    ('BELO HORIZONTE'), ('BELEM'), ('JOAO PESSOA'), ('CURITIBA'), ('RECIFE'), ('TERESINA'), 
    ('RIO DE JANEIRO'), ('NATAL'), ('PORTO ALEGRE'), ('PORTO VELHO'), ('BOA VISTA'), 
    ('FLORIANOPOLIS'), ('SAO PAULO'), ('ARACAJU'), ('PALMAS');

WITH DadosLimpos AS (
    SELECT  
        ff.NumeroNotaFiscal,
        ff.SerieNotaFiscal,
        ff.DataEmissaoNotaFiscal,
        nf.[dt-saida] AS DataSaida,  
        ff.DataEntregaCliente,       
        ff.DataProgEntrega,
        UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ff.Cidade, 
            'á', 'a'), 'é', 'e'), 'í', 'i'), 'ó', 'o'), 'ú', 'u'), 
            'â', 'a'), 'ê', 'e'), 'î', 'i'), 'ô', 'o'), 'û', 'u'), 
            'ã', 'a'), 'õ', 'o'), 'ç', 'c'), 
            'Á', 'A'), 'É', 'E'), 'Í', 'I'), 'Ó', 'O'), 'Ú', 'U'), 
            'Â', 'A'), 'Ê', 'E'), 'Î', 'I'), 'Ô', 'O'), 'Û', 'U'), 
            'Ã', 'A'), 'Õ', 'O'), 'Ç', 'C')) AS CidadeSemAcentos,
        UPPER(ff.Estado) AS Estado,
        ff.ObservacaoExpedicao,
        acf.NomeTransportadoraNF AS Transportadora,
        pdb.NomeMatriz,
        ff.NumeroPedido,
        ff.TipoFrete,
        pdb.NumeroOS,
        COUNT(*) AS Total_Item,
        SUM(ff.QuantidadeFaturada) AS Total_Pecas_Fat,
        SUM(ff.QuantidadeDevolvida) AS Total_Pecas_Dev,
        COUNT(DISTINCT pdb.NumeroOS) AS Total_OS,
        MAX(acf.TotalNota) AS TotalNota,
        acf.ObservacaoCarga,
        acf.Ocorrencia,
        acf.PesoBruto AS PesoBruto
    FROM  
        dbo.Fato_Faturamento ff
    LEFT JOIN  
        logistica.Fato_PDB381 pdb ON ff.NumeroNotaFiscal = pdb.NotaFiscal AND ff.SerieNotaFiscal = pdb.SerieNotaFiscal
    LEFT JOIN  
        auditoria.Fato_CustosFrete_Faturamento acf ON ff.NumeroNotaFiscal = acf.NumeroNotaFiscal AND ff.SerieNotaFiscal = acf.SerieNotaFiscal
    LEFT JOIN  
        [STAGE].[tot].[NotaFiscal] nf ON ff.NumeroNotaFiscal = nf.[nr-nota-fis] AND ff.SerieNotaFiscal = nf.[serie]
    WHERE  
        ff.DataEmissaoNotaFiscal BETWEEN @RangeStart AND @RangeEnd
        AND ff.SerieNotaFiscal IN (5, 21)
        AND ff.Cancelado = 0
        AND ff.IdEstab = '8'
        AND NOT (ff.NumeroNotaFiscal = 1276335 AND ff.SerieNotaFiscal = 5)
        AND NOT (ff.NumeroNotaFiscal = 195563 AND ff.SerieNotaFiscal = 21)
    GROUP BY  
        ff.NumeroNotaFiscal, ff.SerieNotaFiscal, ff.DataEmissaoNotaFiscal,
        nf.[dt-saida],  
        ff.DataProgEntrega,
        ff.Cidade, ff.Estado, ff.ObservacaoExpedicao,
        acf.NomeTransportadoraNF, pdb.NomeMatriz, ff.NumeroPedido,
        ff.TipoFrete, pdb.NumeroOS, acf.ObservacaoCarga, acf.Ocorrencia, ff.DataEntregaCliente, acf.PesoBruto
)

SELECT DISTINCT
    NumeroNotaFiscal,
    SerieNotaFiscal,
    PesoBruto,
    DataEmissaoNotaFiscal,
    DataSaida,  
    DataEntregaCliente,
    DataProgEntrega,
    CidadeSemAcentos,
    Estado,
    ObservacaoExpedicao,
    Transportadora,
    NomeMatriz,
    NumeroPedido,
    TipoFrete,
    NumeroOS,
    FORMAT(Total_Item, 'N0', 'pt-BR') AS Total_Item,
    FORMAT(Total_Pecas_Fat, 'N0', 'pt-BR') AS Total_Pecas_Fat,
    FORMAT(Total_Pecas_Dev, 'N0', 'pt-BR') AS Total_Pecas_Dev,
    FORMAT(Total_OS, 'N0', 'pt-BR') AS Total_OS,
    TotalNota,
    ObservacaoCarga,
    Ocorrencia,
    CASE  
        WHEN Total_Pecas_Fat = Total_Pecas_Dev THEN 'Total'  
        WHEN Total_Pecas_Dev > 0 AND Total_Pecas_Dev < Total_Pecas_Fat THEN 'Parcial'  
        WHEN Total_Pecas_Dev = 0 THEN 'Sem Devolução'  
    END AS StatusDevolucao,
    CASE  
        WHEN CidadeSemAcentos IN (SELECT Cidade FROM @Capitais) THEN 'CAPITAL ' + Estado  
        ELSE 'INTERIOR ' + Estado  
    END AS Região_Geográfica,
    Transportadora + 
    CASE  
        WHEN CidadeSemAcentos IN (SELECT Cidade FROM @Capitais) THEN 'CAPITAL ' + Estado  
        ELSE 'INTERIOR ' + Estado  
    END AS Chave_Transp,
    CASE 
        WHEN ISNULL(LTRIM(RTRIM(NumeroOS)), '') <> '' THEN 'OS' 
        ELSE 'NOS' 
    END AS StatusOS
FROM DadosLimpos
where DataEntregaCliente is null