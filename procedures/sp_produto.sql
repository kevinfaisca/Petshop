If EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME = 'sp_produto')
BEGIN
	DROP PROCEDURE sp_produto
END
GO

Create Procedure dbo.sp_produto
	@vstr_tipoOper					char(3)			= null
	,@vint_numOper					int				= null
	,@id_produto					int				= null
	,@ds_nome						varchar(200)	= null
	,@nr_quantidade					bigint			= null
	,@ds_preco						varchar(200)	= null
	,@ds_marca						varchar(200)	= null
	,@id_usuarioinclusao			varchar(200)	= null
	,@dt_inclusao					date			= null
	,@id_usuarioAlteracao			int				= null
	,@dt_alteracao					date			= null

AS

--Inicializa Transação
Begin Transaction

--Declara variavel para tratamento de erro
Declare @vstr_msgErro	as varchar(4000),
--Declara variavel para exec SQL
		@vstr_cmd		as Nvarchar(4000),
		@vstr_descLog	as varchar(500)

--Procedimento para Select
if @vstr_tipoOper = 'SEL'
begin
	--login
	if @vint_numOper = 1
	begin
		select 
			ds_nome
			,nr_quantidade
			,ds_preco
			,ds_marca
		from
			tb_produto
		where
			1 = 1
	end
	
	--verifica se ocorreu algum erro durante a transação
	if @@ERROR > 0
	Begin
		--ir para rotina de erro
		set @vstr_msgErro = 'Erro durante a operação SELECT'
		Goto Erro
	end
END

if @vstr_tipoOper = 'INS'
begin
	if @vint_numOper = 1
	begin
		--if not exists (select 1 from tb_produto where nr_cpf = @nr_cpf)
		--begin
			--DECLARE @TEMP_TB_id_usuario_ID table (id_usuario int)
			insert into tb_produto(
				ds_nome
				,nr_quantidade
				,ds_preco
				,ds_marca
				,dt_inclusao		
			)--OUTPUT inserted.id_usuario INTO @TEMP_TB_id_usuario_ID
			values(
				@ds_nome
				,@nr_quantidade
				,@ds_preco
				,@ds_marca
				,getdate()
			)
			--SELECT id_usuario from @TEMP_TB_id_usuario_ID
		--end
		--else
		--begin
			--select top 1 id_usuario from tb_produto where nr_cpf = @nr_cpf
		--end
	end

	--verifica se ocorreu algum erro durante a transação
	if @@ERROR > 0
	begin
		--ir para rotina de erro
		set @vstr_msgErro = 'Erro durante a operação de INSERT'
		goto Erro
	end
end

if @vstr_tipoOper = 'UPD'
begin
	if @vint_numOper = 1
	begin
		update
			tb_produto
		set
			ds_nome					= @ds_nome
			,ds_marca				= @ds_marca
			,nr_quantidade			= @nr_quantidade
			,ds_preco				= @ds_preco
		where
			id_produto				= @id_produto
	end
	
	--verifica se ocorreu algum erro durante a transação
	if @@ERROR > 0
	begin
		--ir para rotina de erro
		set @vstr_msgErro = 'Erro durante a operação de UPDATE'
		goto Erro
	end
end

-- ir para rotina de finalização de operação
	goto Fim

-- Rotina para tratamento de erro
	Erro:
		select @vstr_msgErro
		RollBack Transaction

-- Rotina para finalização da operação
	Fim:
	Commit Transaction