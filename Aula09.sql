CREATE DATABASE aula9
GO 
USE aula9

-- Uma empresa vende produtos aliment�cios
-- A empresa d� pontos, para seus clientes, que podem ser revertidos em pr�mios

-- Tabela Cliente (Codigo | Nome)
CREATE TABLE cliente (
codigo INT PRIMARY KEY,
nome VARCHAR(100)
)

INSERT cliente VALUES (1, 'Bia')
INSERT cliente VALUES (2, 'Deyse')
INSERT cliente VALUES (3, 'Debira')


-- Tabela Venda (Codigo_Venda | Codigo_Cliente | Valor_Total)
CREATE TABLE venda (
codigo_venda INT PRIMARY KEY,
codigo_cliente INT,
valor_total DECIMAL(7,2)
FOREIGN KEY (codigo_cliente) REFERENCES cliente(codigo)
)

-- Tabela Pontos (Codigo_Cliente | Total_Pontos)
CREATE TABLE pontos (
codigo_cliente INT PRIMARY KEY,
total_pontos INT
FOREIGN KEY (codigo_cliente) REFERENCES cliente(codigo)
)

/*
- Para n�o prejudicar a tabela venda, nenhum produto pode ser deletado, mesmo que n�o venha mais a ser vendido
- Para n�o prejudicar os relat�rios e a contabilidade, a tabela venda n�o pode ser alterada. 
- Ao inv�s de alterar a tabela venda deve-se exibir uma tabela com o nome do �ltimo cliente que comprou e o valor da �ltima compra
*/
GO 
CREATE TRIGGER t_alterVenda ON venda
INSTEAD OF UPDATE, DELETE
AS
BEGIN
	SELECT TOP(1) v.codigo_venda, c.nome, v.valor_total
	FROM venda v, cliente c
	WHERE v.codigo_cliente = c.codigo
	ORDER BY v.codigo_venda DESC 
END
GO 

/*
- Ap�s a inser��o de cada linha na tabela venda, 10% do total dever� ser transformado em pontos.
- Se o cliente ainda n�o estiver na tabela de pontos, deve ser inserido automaticamente ap�s sua primeira compra
- Se o cliente atingir 1 ponto, deve receber uma mensagem dizendo que ganhou
*/
GO 
CREATE TRIGGER t_insertVenda ON venda
AFTER INSERT
AS
BEGIN
	DECLARE @valor_total DECIMAL(7,2),
			@cliente INT,
			@pontos INT 
	
	SET @valor_total = (SELECT valor_total FROM INSERTED)
	
	SET @cliente = (SELECT codigo_cliente FROM INSERTED)
	SET @pontos = (SELECT total_pontos FROM pontos WHERE codigo_cliente = @cliente) 

	IF (@pontos IS NULL)
	BEGIN 
		SET @pontos = @valor_total * 0.10 
		INSERT INTO pontos VALUES (@cliente, @pontos)
	END 
	ELSE
	BEGIN 
		SET @pontos = @valor_total * 0.10 
		UPDATE pontos 
		SET total_pontos = total_pontos + @pontos
		WHERE codigo_cliente = @cliente 
	END 
END
GO 

INSERT venda VALUES (123, 1, 279.93)
INSERT venda VALUES (124, 2, 197.95)
INSERT venda VALUES (125, 3, 221.94)
INSERT venda VALUES (126, 3, 221.94)

SELECT * FROM venda 
SELECT * FROM pontos
SELECT * FROM cliente 

DELETE venda 
DELETE pontos 

UPDATE venda 
SET valor_total = 2