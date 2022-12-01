create table Igrediente(
    id number(5) not null,
    nome varchar2(25) not null,
    preco decimal(5,2),
    quantidade number(5)
);

create table Produto(
    id number(5) not null,
    nome varchar2(25) not null,
    preco decimal(10,2),
    quantidade number(3),
    descricao varchar2(250),
    categoria number(5) not null,
    desconto decimal (1,1)
);

create table Venda(
    id number(5) not null,
    idProduto number(5) not null,
    idCliente number(5) not null,
    data_venda date,
    valor_venda decimal(10,2)
);



create  table Cliente(
    id number(5) not null,
    nome varchar2(20),
    telefone number(11),
    email varchar2(40)
);


create table Fabricacao_produto(
    id number(5) not null,
    idProduto number(5) not null,
    idIgrediente number(5) not null,
    quantidade number(2),
    preco decimal(3,2)
);

create table Categoria(
    id number(5) not null,
    nome varchar2(20)
);

-- Primary keys
alter table Igrediente
add constraint pk_igrediente_id primary key(id);

alter table Produto
add constraint pk_produto_id primary key(id);

alter table Venda
add constraint pk_venda_id primary key(id);

alter table Cliente
add constraint pk_cliente_id primary key(id);

alter table Fabricacao_produto 
add constraint pk_fabricacao_produto_id primary key(id);


alter table Venda
add constraint fk_venda_produto foreign key(idProduto) references Produto

alter table Venda
add constraint fk_venda_cliente foreign key(idCliente) references Cliente

alter table Fabricacao_produto
add constraint fk_fabricaoProduto_produto foreign key(idProduto) references Produto

alter table Fabricacao_produto
add constraint fk_fabricaoProduto_igrediente foreign key(idIgrediente) references Igrediente;

alter table Categoria 
add constraint pk_categoria primary key(id);

alter table Produto
add constraint fk_produto_categoria foreign key(categoria) references Categoria;



insert into Igrediente values (5,'açucar', 003.29, 30);
insert into Igrediente values (1,'farinha', 004.50, 10);
insert into Igrediente values (3,'sal', 003.59, 50);
insert into Igrediente values (10,'oleo', 004.00, 20);
insert into Igrediente values (6,'fermento', 006.20, 30);
insert into Igrediente values (15,'manteiga', 03.50, 50);

insert into Cliente values (1,'Eduardo', 15981705102, 'eduardosantanavidal@gmail.com');
insert into Cliente values (2,'Leonardo', 1598274532, 'leo212@email.com');
insert into Cliente values (4,'Sandro', 15988705141, 'sandrosilva21@email.com');
insert into Cliente values (14,'alexia', 15981732102, 'Alexia3@gmail.com');

insert into Categoria values (1, 'bolo');
insert into Categoria values (2, 'pao');
insert into Categoria values(3, 'doce');

select * from categoria

insert into Produto values (2,'bolo de fuba', 5.99,  12, 'Bolo de fu', 1, 0);
insert into Produto values (41,'Pao de queijo',1.50,  4, 'Pao de queijo mineiro', 2, 0);
insert into Produto values (21,'bolo de chocolate', 1.99,  10, 'Bolo ', 1, 0);
insert into Produto values (232,'Sonho',2.99,  11, 'Sonho', 3, 0);
insert into Produto values (200,'cocada',2.99,  11, 'cocada', 3, 0);
insert into Produto values (210,'cocada branca',2.99,  0, 'cocada branca', 3, 0);

insert into Venda values(10, 2, 1, '30-NOV-2022', 12.21);
insert into Venda values(5, 41, 2, '20-NOV-2022', 10.00);
insert into Venda values(1, 23, 4, '30-DEC-2021', 10.21);
insert into Venda values(30, 21, 4, '11-JAN-2022', 10.99);
insert into Venda values(14, 232, 2, '30-NOV-2022', 10.21);
insert into venda values(17,  41, 1, '30-nov-2022', 10.21);
insert into venda values(16,  41, 1, '30-nov-2022', 10.21);


-- a) R:  Usado para listar a quantidade de produto de cada venda
select  cliente.nome, cliente.id as clienteId,  count(produto.id) as quantidade, produto.nome as produto
from venda inner join cliente on cliente.id = venda.idCliente
inner join produto on produto.id = venda.idProduto
group by  cliente.nome, produto.id, cliente.id, produto.nome

-- b) R: Consulta o valor total de vendas em um dia especifico
select sum(valor_venda)
from venda
where data_venda = '30-nov-22' 

-- d) R: Selecio todos o produtos que tem a categoria igual a doce ou bolo
select produto.id, produto.nome, categoria.nome as categoria  from categoria 
inner join produto on produto.categoria = categoria.id
where categoria.nome = 'Bolo' 
union
select produto.id, produto.nome, categoria.nome  from categoria 
inner join produto on produto.categoria = categoria.id
where categoria.nome = 'doce'

--e) R: Seleciona todos os produtos que não foram vendidos
select nome, id from produto 
minus
select produto.nome, produto.id from produto 
inner join venda on venda.idProduto = produto.id

--F) R: Seleciona todos os produto que tiveram mais de duas vendas e pertencem a categoria de paes
select id from produto where categoria = 2
intersect
select idProduto
from venda
having count(idProduto) > 2
group by idProduto

--4)

--a)
 select id from produto
 where id in (select idProduto from venda)

--b) 
select id from produto 
where id not in (select idProduto from venda)

--c) R: Da um desconto de 20% para os produto que não tiveram vendas 
update produto
set desconto = 0.2
where id not in (select idProduto from venda);

--d) R: Deleta todos os produtos que nao tem mais estoque.
delete produto
where id not in (select id from produto where quantidade > 0)


-- Delete produto que nao tem estoque
create or replace  procedure deleteProduto(p_id number) 
as 
v_quantidade produto.quantidade%type;
begin
 select quantidade into v_quantidade  from produto where id = p_id;
    if v_quantidade = 0 then
    delete produto
    where id = p_id;
    end if;
end;

insert into Produto values (303,'cocada branca',2.99,  0, 'cocada branca', 3, 0.3);

exec deleteProduto(300);

select desconto from produto where desconto > 0;

Create or replace Function produto_desconto(idproduto  produto.id%type)
return varchar2
as
v_desconto produto.desconto%type;
Begin
    Select desconto into v_desconto
    From produto
    Where produto.id = idproduto;
    Return (v_desconto);
End produto_desconto;

select idProduto, produto_desconto(idProduto) "desconto" from venda

create table logteste
(nrlog number primary key, 
 Dttrans date not null, 
 Usuario varchar2(20) not null, 
 Tabela varchar2(30),
 Opera char(1) check (opera in('I','A','E')),
 Linhas Number(5) not Null check(linhas >=0));
 
 
 Create or Replace trigger deleteProduto
before delete on produto
for each row
begin
  insert into logteste values(seqlog.nextval,sysdate,user,'produto','E',1);
end Eliminaproduto;

delete tb_produto
where codproduto = 6;
 
  