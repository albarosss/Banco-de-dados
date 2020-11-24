create database prep2
go

use prep2

create table autores(
cod int not null,
nome varchar(100) null,
pais varchar(100) null,
biografica varchar(300) null 
primary key (cod)
)
go
create table clientes (
cod int not null,
nome varchar(100) null,
logradouro varchar(200) null,
numero int null,
telefone char(9) null
primary key (cod)
)
go

create table corredores(
cod int not null,
tipo varchar(100)
primary key (cod)
)
go

create table livros (
cod int not null,
cod_autor int not null,
cod_corredores int not null,
nome varchar(100) null,
pag int null,
idioma varchar(100) null
primary key (cod)
foreign key (cod_autor) references autores(cod),
foreign key (cod_corredores) references corredores(cod)
)
go
create table emprestimo( 
cod_cli int not null,
data datetime null,
cod_livro int not null
primary key(cod_cli,cod_livro)
foreign key (cod_livro) references livros(cod),
foreign key (cod_cli) references clientes(cod)
)


select c.nome , convert(char(10), e.data, 103) as data_emprestimo
from clientes c, emprestimo e
where c.cod = e.cod_cli

select 

case when (len(a.nome) > 25)
then
	substring(a.nome, 1, 13)
else
	a.nome
		end as nome_autor,
		count(l.cod) as livros_escritos
from autores a, livros l
where a.cod = l.cod_autor
group by a.cod, a.nome
order by livros_escritos


select a.cod, a.nome, a.pais
from livros l, autores a
where l.cod_autor = a.cod
	and l.pag in(
		select max(l.pag)
		from livros l
		)

select distinct c.nome, concat(c.logradouro, ',nº',c.numero) as end_conc
from clientes c, emprestimo e
where c.cod = e.cod_cli

select distinct c.nome,

	case when (((c.logradouro is null) and (c.numero is null) ) and (c.telefone is not null))
	then
		substring (c.telefone, 1, 5)+ '-' + substring (c.telefone, 6, 9)
	else
		case when(((c.logradouro is not null) and (c.numero is not null) ) and (c.telefone is null))
		then
			c.logradouro + ', nº ' + cast(c.numero as char(5))
			else
				c.logradouro + ', nº ' + cast(c.numero as char(5)) + ' - tel: ' + substring(c.telefone, 1, 5) + '-' + substring (c.telefone, 6, 9)
	end
end as endereco_telefone


from clientes c left outer join emprestimo e
on c.cod = e.cod_cli
where e.cod_cli is null

SELECT COUNT (l.cod) AS livros_nao_emprestados
FROM livros l LEFT OUTER JOIN emprestimo e
ON l.cod = e.cod_livro
WHERE e.cod_livro IS NULL 

SELECT a.nome, c.tipo, COUNT(l.cod) AS qtd_livros
FROM autores a, corredores c, livros l
WHERE a.cod = l.cod_autor
	AND l.cod_corredores = c.cod
GROUP BY c.cod, c.tipo, a.nome
ORDER BY qtd_livros

SELECT c.nome, l.nome, DATEDIFF(DAY, e.data, '2012-05-18') AS dias_emprestimo,
	CASE WHEN ((DATEDIFF(DAY, e.data, '2012-05-18')) > 4)
	THEN
		'Atrasado'
	ELSE 
		'No Prazo'
	END AS status_emprestimo
FROM clientes c, livros l, emprestimo e
WHERE c.cod = e.cod_cli
	AND e.cod_livro = l.cod
	AND e.data <=  '2012-05-18'


	SELECT c.cod, c.tipo, COUNT(l.cod) AS qtd_livros
FROM corredores c, livros l
WHERE c.cod = l.cod_corredores
GROUP BY c.cod, c.tipo

SELECT a.nome
FROM autores a, livros l
WHERE a.cod = l.cod_autor
GROUP BY a.cod, a.nome
HAVING COUNT(l.cod) >= 2

SELECT c.nome, l.nome
FROM clientes c, livros l, emprestimo e
WHERE c.cod = e.cod_cli
	AND e.cod_livro = l.cod
	AND e.data <=  '2012-05-18'
GROUP BY c.nome, l.nome, e.data
HAVING (DATEDIFF(DAY, e.data, '2012-05-18')) >= 7
