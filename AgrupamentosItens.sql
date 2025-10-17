SELECT 
    Item,
    Descricao,
    FORMAT(SUM(Disponivel), 'N0', 'pt-BR') AS Total_Disponivel,
    COUNT(DISTINCT Endereco) AS Total_Enderecos_Distintos
FROM 
    logistica.Fato_ESWM9022
WHERE 
    Local = 'AAT'
GROUP BY 
    Item,
    Descricao
order by Total_Enderecos_Distintos DESC
